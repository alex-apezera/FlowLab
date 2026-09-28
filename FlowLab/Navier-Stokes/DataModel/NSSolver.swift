//
//  NSSolver.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 06.07.2025.
//
// MARK: - Solver. Data model.

import SwiftUI
import Combine

/// Реализация решения уравнений
final class NavierStokesSolver: ObservableObject {
    
    /// Сохраняемые в историю параметры задачи
    @Published var params = SimulationParameters()
    ///Состояние процесса решения на текущем шаге
    @Published var state = SimulationState()
    /// Таймер: дата и время запуска, время расчетов
    @ObservedObject var timerManager = TimeCounterManager()

    // Координаты и шаги сетки [m]
    
    /// вычисляемый единый шаг сетки [m]
    @Published var h: Double = 0.01
    /// координаты узлов по горизонтали
    @Published var x: [Double] = []
    /// координаты узлов по вертикали
    @Published var y: [Double] = []
    /// Шаги по x: dx[i] = x[i+1] - x[i]
    @Published var dx: [Double] = []
    /// Шаги по y; dy[j] = y[j+1] - y[j]
    @Published var dy: [Double] = []
    
    // Поля переменных (ALE + EPM)
    
    /// горизонтальная скорость [m/s]
    @Published var u: [Double] = []
    /// вертикальная скорость [m/s]
    @Published var v: [Double] = []
    /// давление [Pa]
    @Published var p: [Double] = []
    /// температура [ºC]
    @Published var T: [Double] = []
    /// доля жидкой фазы 0÷1
    @Published var liquidFraction: [Double] = []
    /// 0 - любое тело, 1 - только "камень"
    @Published var isStone: [UInt8] = []
    /// маска твердого тела
    @Published var solidMask: [UInt8] = []
    /// функция тока ψ, ω
    @Published var psi: [Double] = []
    
    // Фазовый переход  -> frontState, addToStatistics, coldWallState
    
    /// толщина расплава по высоте  ( ALE )
    @Published var rx: [Double] = []
    /// относительный объём расплава W/W₀
    @Published var rx_avg: Double = 1.0
    /// W/W₀ на предыдущем шаге
    @Published var rx_avg_old: Double = 1.0
    /// продвижение фронта (ALE) [m/s]
    @Published var V_melt: [Double] = []
    /// приращение  объёма [1/s]
    @Published var V_melt_avg: Double = 0
    
    // Время
    
    ///  время, соответсвующее приращению dt [s]
    @Published var t: Double = 0.0
    /// начальный шаг по времени [s]
    @Published var dt: Double = 0.001
    /// итерация (шаг) по решению всех уравнений
    @Published var step: Int = 0
        
    // Массивы для отслеживания параметров решения
    
    /// <q>  на горячей стенке
    @Published var q_hotWall: [Double] = []
    /// <q>  на холодной стенке
    @Published var q_coldWall: [Double] = []
    /// <Δq/q> на стенках от step
    @Published var q_residual: [Double] = []
    /// maxVelocity(step)
    @Published var maxVelocity: [Double] = []
    /// зависимость dt от step
    @Published var deltaTime: [Double] = []
    /// зависимость dTime от step
    @Published var timeStep: [Double] = []
    /// число Куранта от step
    @Published var stabilityParams: [Double] = []
    /// невязка p от step
    @Published var pressureResiduals: [Double] = []
    /// <Т_hot(step)>
    @Published var T_avg_hotWall: [Double] = []
    /// <Т_vol(step)>
    @Published var T_avg_volume: [Double] = []
    ///точки добавления в историю
    @Published var timePoints: [Double] = []
    
    // Свойства для отслеживания сходимости и решения
    
    /// допустимая погрешность
    @Published var maxPressureResidual = 0.0
    ///  лимит итераций для давления
    @Published var maxIterations = 250
    /// коэф релаксации для давления
    @Published var relaxationFactor = 0.55
    /// вычисленное число итераций для p в  шаге
    @Published var iterations = 0
    /// средне-объёмная температура расплава [ºC]
    @Published var avgTemp = 0.0
    /// вычислять avgTemp?
    @Published var showAvgTemp = true
    /// погрешность при вычислении ω
    @Published var tolerancePsi = 1e-6
    /// вычисленное число итераций для  ω
    @Published var iterationsPsi = 0
    /// cсостояние загрузки ω
    @Published var isCalculatingStream = false
    
    // Стабилизация хода решения
    
    /// коэф учета диффузии
    @Published var d_Factor = 1.0
    /// переключатель схемы
    @Published var useHybridScheme = false

    // Переключатели и переменные для метода EPM
    
    /// установить  градиент Т для начала расчетов
    @Published var useInitialGradientT = true
    /// запрет плавления (камень)
    @Published var makeSolid = false
    /// Режим "заморозки" скоростей
    @Published var isFrozen: Bool = false

    // Параметры активного объекта (тело твердой фазы, EPM)
    
    @Published var activeObjectPos = CGPoint(x: 20, y: 20)
    @Published var activeObjectSize = CGSize(width: 10, height: 10)
    @Published var activeObjectType: EditorTool = .circle
    
    // Новые вычисляемые диагностические параметры (EPM)
    
    /// тепловой поток на плавление [W/m²]
    var qMelt: Double = 0.0
    /// адаптивный шаг при плавлении [s]
    var adaptiveDtMelt = 0.001
    /// адаптивный шаг (предварительная оценка) [s]
    var adaptiveDt = 0.001
    /// предыдущий объём расплава [m³]
    var prevTotalLiquidVol: Double = 0.0
    
    // Очередь последних стабильных состояний для возобновления расчетов
    var stateBuffer: [SolverState] = []
    let bufferLimit = 10
    @Published var statusMessage: String = ""
    var stableStepCount = 0
    let accelerationThreshold = 30 // Шагов до ускорения
    
    /// Количество активных ядер процессора (он же шаг распараллеливания)
    @Published var workerCount = ProcessInfo.processInfo.activeProcessorCount
    
    /// малая константа для предотвращения деления на ноль
    var tiny = 1e-16
    
    /// активность системы
    @Published var simulationActivity: NSObjectProtocol?

    // Исходное состояние
    init() { reset() }
   
}
