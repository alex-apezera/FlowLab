//
//  NSSolver.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 06.07.2025.
//
// MARK: - Solver. Модели данных

import SwiftUI
import Combine

/// Реализация решения уравнений
final class NavierStokesSolver: ObservableObject {
    
    /// Сохраняемые в историю параметры задачи - в отдельной структуре
    @Published var params = SimulationParameters()
    /// Состояние процесса решения на текущем шаге (сохраняется в истории)
    @Published var state = SimulationState()
    /// Таймер: дата и время запуска, время расчетов
    @ObservedObject var timerManager = TimeCounterManager()

    // Координаты и шаги сетки [m]
    @Published var h: Double = 0.01 /// вычисляемый единый шаг сетки [m]
    @Published var x: [Double] = [] /// координаты узлов по горизонтали
    @Published var y: [Double] = [] /// координаты узлов по вертикали
    @Published var dx: [Double] = [] /// Шаги по x: dx[i] = x[i+1] - x[i]
    @Published var dy: [Double] = [] /// Шаги по y; dy[j] = y[j+1] - y[j]
    
    // Поля переменных (ALE + EPM)
    @Published var u: [Double] = [] /// горизонтальная скорость [m/s]
    @Published var v: [Double] = [] /// вертикальная скорость [m/s]
    @Published var p: [Double] = [] /// давление [Pa]
    @Published var T: [Double] = [] /// температура [ºC]
    @Published var liquidFraction: [Double] = []/// доля жидкой фазы 0÷1
    @Published var isStone: [UInt8] = [] /// 0 - любое тело, 1 - только "камень"
    @Published var solidMask: [UInt8] = [] /// маска твердого тела
    @Published var psi: [Double] = [] /// функция тока ψ, ω
    
    // Фазовый переход  -> frontState, addToStatistics, coldWallState
    @Published var rx: [Double] = [] /// толщина расплава по высоте  ( ALE )
    @Published var rx_avg: Double = 1.0  /// относительный объём расплава V/V₀
    @Published var rx_avg_old: Double = 1.0  /// V/V₀ на предыдущем шаге
    @Published var V_melt: [Double] = [] /// продвижение фронта (ALE) [m/s]
    @Published var V_melt_avg: Double = 0 /// приращение  объёма [1/s]
    
    // Время
    @Published var t: Double = 0.0 ///  время, соответсвующее приращению dt [s]
    @Published var dt: Double = 0.001 /// начальный шаг по времени [s]
    @Published var step: Int = 0 /// итерация (шаг) по решению всех уравнений
    @Published var meltVolumeLimit = 1.25 /// лимит приращения объёма V𝗆/V₀

    // Гравитация
    @Published var gMagnitude = 9.81 /// ускорение свободного падения [m/s²]
        
    // Массивы для отслеживания параметров решения (для диагностики)
    @Published var q_hotWall: [Double] = [] /// <q>  на горячей стенке
    @Published var q_coldWall: [Double] = [] /// <q>  на холодной стенке
    @Published var q_residual: [Double] = [] /// <Δq/q> на стенках от step
    @Published var maxVelocity: [Double] = [] /// maxVelocity(step)
    @Published var deltaTime: [Double] = [] /// зависимость dt от step
    @Published var timeStep: [Double] = [] /// зависимость dTime от step
    @Published var stabilityParams: [Double] = []/// число Куранта от step
    @Published var pressureResiduals: [Double] = []/// невязка p от step
    @Published var T_avg_hotWall: [Double] = [] /// <Т_hot(step)> 
    @Published var T_avg_volume: [Double] = [] /// <Т_vol(step)>
    @Published var timePoints: [Double] = [] ///точки добавления в историю
    
    // Свойства для отслеживания параметров сходимости и решения
    @Published var maxPressureResidual = 0.0///допустимая погрешность
    @Published var maxIterations = 250 ///  лимит итераций для давления
    @Published var relaxationFactor = 0.55 /// коэф релаксации для давления
    @Published var iterations = 0 ///вычисленное число итераций для p в  шаге
    @Published var avgTemp = 0.0 ///средне-объёмная температура расплава [ºC]
    @Published var showAvgTemp = true /// вычислять avgTemp?
    @Published var tolerancePsi = 1e-6///погрешность при вычислении ω
    @Published var iterationsPsi = 0 ///вычисленное число итераций для  ω
    @Published var isCalculatingStream = false /// cсостояние загрузки ω
    
    // Стабилизация хода решения (гибридная схема = конвекция + диффузия)
    @Published var d_Factor = 1.0 /// коэф учета диффузии
    @Published var useHybridScheme = false /// переключатель схемы

    // Переключатели и переменные для метода энтальпии-пористости (EPM)
    @Published var useInitialGradientT = true /// установить  градиент Т
    @Published var makeSolid = false /// запрет плавления (камень))

    // Параметры активного объекта (тело твердой фазы, EPM)
    @Published var activeObjectPos = CGPoint(x: 20, y: 20)
    @Published var activeObjectSize = CGSize(width: 10, height: 10)
    @Published var activeObjectType: EditorTool = .circle
    
    // Новые вычисляемые диагностические параметры (EPM)
    var qMelt: Double = 0.0 /// тепловой поток на плавление [W/m²]
    var adaptiveDtMelt = 0.001 /// адаптивный шаг при плавлении [s]
    var adaptiveDt = 0.001 /// адаптивный шаг (предварительная оценка) [s]
    var prevTotalLiquidVol: Double = 0.0 /// предыдущий объём расплава [m³]
    var total_heat_entered_EPM = 0.0 /// [J]
    
    // Очередь последних стабильных состояний для возобновления расчетов
    var stateBuffer: [SolverState] = []
    let bufferLimit = 10
    @Published var statusMessage: String = "" /// Для всплывающего окна
    var stableStepCount = 0
    let accelerationThreshold = 30 // Шагов до ускорения

    @Published var isFrozen: Bool = false // Режим "заморозки" скоростей
    
    // Количество активных ядер процессора (он же шаг распараллеливания)
    @Published var workerCount = ProcessInfo.processInfo.activeProcessorCount
    
    var tiny = 1e-14 /// малая константа для предотвращения деления на ноль
    
    @Published var simulationActivity: NSObjectProtocol?/// активность системы

    // Исходное состояние
    init() { reset() }
   
}
