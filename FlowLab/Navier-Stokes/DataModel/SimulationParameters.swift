//
//  SimulationParameters.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 13.11.2025.
//

// MARK: - Simulation Parameters Data model.

/// Параметры, необходимые для решения задачи
struct SimulationParameters: Codable, Sendable {
    
    //Геометрия
    var nx: Int = 100 /// число узлов по ширине (>1)
    var ny: Int = 100 /// число узлов по высоте (>1)
    var Lx: Double = 0.15 /// ширина [m] (>0)
    var Ly: Double = 0.15 /// высота [m] (>0)
    /// коэффициенты  растяжения сетки от центра к границам для метода ALE (≥0)
    var stretch_x: Double = 0.0
    var stretch_y: Double = 0.0
    /// ограничение по ширине расплава для метода ALE ( > 1 )
    var Rx: Double = 3.0
    
    // Гравитация
    /// cкорость вращения вектора [º/h]
    var gravityRotationVelocity: Double = 0.0
    /// начальный угол вектора  0 = 0º ( ↓ ), 90 = 90º ( ← )
    var gravityInitialAngle: Double = 0.0
    /// синхронизация угла вектора с тепловыми картами полей
    var isGravitySynchronized: Bool = false
    /// ускорение свободного падения [m/s²]
    var gMagnitude = 9.81
    
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
    var relaxationFactor: Double = 0.55 /// для давления
    var criticalError: Double = 1e-4 /// критическая ошибка

    // Диагностика и история
    var countsLimit: Int = 3000 /// лимит шагов для диагностики
    var maxHistorySteps: Int = 1000 /// лимит кадров  истории

    // Число Куранта (CFL)
    var hiStabLimit: Double = 0.38 /// верхний лимит для CFL
    var lowStabLimit: Double = 0.28 /// нижний лимит для числа  CFL

    // Управление процессом плавления
    var allowMelt = false /// ВКЛ/ВЫКЛ  режим расчета плавления
    var startMeltingStep: Int = 1_000_000 /// шаг начала плавления
    var initMeltWidth = 0.15 /// начальная толщина расплава [m]
    var meltVolumeLimit = 1.25 /// лимит приращения объёма W/W₀
    
    // Опции решения уравнений (переключатели)
    var useAdaptiveRelax = false /// настраиваемая релаксация для p
    var useEnthalpyMethod = false /// использовать метод EPM
    var useConcurrence = false /// многопоточность для остального
    var useParallelDiffusion = false /// многопоточность для дифф.
    var useParallelPressure = false /// многопоточность для давления
    var useStephanScheme = false /// схема расчета теплового потока
    var useNeiman = false /// ГУ для Т при касании фронта правого края
    var zeroStoneConductivity = false /// использовать α = 0  в камне
    
    /// Комментарий к решению, включается в  файл истории
    var comment: String = ""

    /// Интервал плавления  для метода EPM (T melt - T cold) ≈ 0.01÷0.1  [K]
    var dTm = 0.01
    
    // Управление вынужденной конвекцией
    var useWind: Bool = false /// использовать входящий поток
    var windSpeed: Double = 0.03/// скорость входящего потока [m/s]
    var windAngle: Double = 0.0/// угол входящего потока [degrees]
    /// границы вдува относительно высоты области
    var y_start = 0.4, y_end = 0.6
    /// температурный напор (Tin - Twall)  [℃]
    var windDeltaTemp: Double = 10.0
    var leftSink: Bool = false /// сток  влево (true) или верх/низ (false)
}
