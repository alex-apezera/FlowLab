//
//  SimulationParameters.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 13.11.2025.
//

// MARK: - Модели данных

/// Параметры, необходимые для решения задачи
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
    var heatingValue: Double = 10.0 /// [ºC] for ΔT, [W/m²] for heatFlux
    
    /// Реальное вещество (c вычисляемыми неизменяемыми свойства)
    var substance: Substance = .custom  /// по умолчанию
    /// Виртуальное вещество (с произвольными изменяемыми свойствами)
    var customFluidProperties: FluidProperties = .custom
    /// Свойства вещества
    var currentProperties: FluidProperties {
        switch substance {
        case .custom: return customFluidProperties
        case .water: return .water
        case .eicosane: return .eicosane
        case .docosane: return .docosane
        case .wax56: return .wax56
        case .air: return .air
        }
    }
    
    // Параметры управления временем
    var maxTime: Double = 60 /// ограничение по времени моделирования [s]
    var timeStep: Double = 0.001 /// временной шаг  в уравнениях  Δt [s]
    var timeGap: Double = 0.2 /// шаг занесения результатов в историю [s] > Δt
    var timeScale: Double = 1.0 /// масштабирование времени при плавлении
    
    // Управление итерациями для давления
    var maxIterations: Int = 250 /// для давления
    var relaxationFactor: Double = 0.5 /// для давления
    var criticalError: Double = 1e-4 /// критическая ошибка

    // Диагностика и история
    var countsLimit: Int = 2000 /// лимит шагов для диагностики
    var maxHistorySteps: Int = 1000 /// лимит кадров  истории

    // Число Куранта
    var hiStabLimit: Double = 0.38 /// верхний лимит для CFL
    var lowStabLimit: Double = 0.28 /// нижний лимит для числа  CFL

    // Управление процессом плавления
    var allowMelt = false /// ВКЛ/ВЫКЛ  режим расчета плавления
    var startMeltingStep: Int = 1000_000 /// шаг начала процесса плавления
    var initMeltWidthRatio = 1.0 /// начальная толщина расплава (EPM)
    
    // Опции решения уравнений (переключатели)
    var useAdaptiveRelax = false /// градиентная коррекция второго порядка
    var useEnthalpyMethod = false /// использовать метод EPM
    var useConcurrence = false /// многопоточность для остальных функций
    var useParallelDiffusion = false /// многопоточность для диффузии
    var useParallelPressure = false /// многопоточность для давления
    var useStephanScheme = false ///  схема расчета теплового потока через границу
    var useNeiman = false /// ГУ для Т при касании фронта правого края области
    
    /// Комментарий к решению, включается в  файл истории
    var comment: String = ""

    /// Интервал плавления [K] 0.01 ÷ 0.1
    var dTm = 0.01 /// T melt - T cold [K] - для метода EPM
    
    /// Управление вынужденной конвекцией
    var useWind: Bool = false /// использовать входящий поток
    var windSpeed: Double = 0.03/// скорость входящего потока [m/s]
    var windAngle: Double = 0.0/// угол входящего потока [degrees]
    var y_start = 0.4, y_end = 0.6 /// границы вдува относительно высоты области
    var windDeltaTemp: Double = 10.0 /// температурный напор (Tin - Twall) [℃]
    var leftSink: Bool = false /// сток  влево (true) или верх/низ (false)
}
