//
//  SimulationParameters.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 13.11.2025.
//

// MARK: - Модели данных

// Параметры, необходимые для решения задачи
struct SimulationParameters: Codable, Sendable {
    //Геометрия
    var nx: Int = 100 /// число узлов по ширине
    var ny: Int = 100 /// число узлов по высоте
    var Lx: Double = 0.15 /// ширина [m]
    var Ly: Double = 0.15 /// высота [m]
    var stretch_x: Double = 0.0 /// коэф растяжения сетки от центра к границе по x
    var stretch_y: Double = 0.0 /// коэф растяжения сетки от центра к границе по y
    var Rx: Double = 3.0 /// ограничение по ширине расплава ( > 1 )
    
    // Гравитация
    var gravityRotationVelocity: Double = 0.0 /// cкорость вращения вектора [º/h]
    var gravityInitialAngle: Double = 0.0 /// начальный угол 0 = 0º ( ↓ ), 90 = 90º ( ← )
    var isGravitySynchronized: Bool = false /// синхронизация угла с вычислениями
    
    // Подвод тепла к левой горячей стенке
    var heatingType: HeatingType = .temperature /// or .heatFlux
    var heatingValue: Double = 30.0 /// [ºC] for ΔT, [W/m²] for heatFlux
    
    // Вещество (вычисляемые неизменяемые свойства)
    var substance: Substance = .wax23  /// по умолчанию
    var customFluidProperties: FluidProperties = .custom///может редактироваться
    var currentProperties: FluidProperties {
        switch substance {
        case .custom: return customFluidProperties
        case .water: return .water
        case .wax23: return .wax23
        case .wax33: return .wax33
        case .wax56: return .wax56
        case .air: return .air
        }
    }
    
    // Параметры управления временем
    var maxTime: Double = 60 /// ограничение по времени моделирования [s]
    var timeStep: Double = 0.001 /// временной шаг  в уравнениях  Δt [s]
    var timeGap: Double = 0.2 /// шаг занесения результатов в историю [s] > Δt
    var timeScale: Double = 1.0 /// масштабирование времени при плавлении
    
    // Управление ходом вычислений
    var maxIterations: Int = 250 /// для давления
    var relaxationFactor: Double = 0.5 /// для давления
    var criticalError: Double = 1e-4 /// критическая ошибка
    var countsLimit: Int = 4000 /// лимит шагов для диагностики
    var maxHistorySteps: Int = 4000 /// лимит шагов для истории
    var hiStabLimit: Double = 0.38 /// максимальный предел для числа Куранта
    var lowStabLimit: Double = 0.28 /// минимальный предел для числа Куранта

    // Управление процессом плавления
    var allowMelt = false /// ВКЛ/ВЫКЛ  режим расчета плавления
    var startMeltingStep: Int = 1000_000 /// шаг начала процесса плавления
    var initMeltWidthRatio = 1.0 /// начальная толщина расплава (EPM)
    var useGradientCorrection = false /// градиентная коррекция второго порядка
    
    // Опции решения уравнений (переключатели)
    var useEnthalpyMethod = false /// использовать метод EPM
    var useConcurrence = false /// многопоточность
    var useParallelPressure = false /// многопоточность для давления в ALE
    
    // Комментарий к решению
    var comment: String = ""

    // Интервал плавления [K] 0.01 ÷ 0.1
    var dTm = 0.01 /// T melt - T cold [K] - для метода EPM
}
