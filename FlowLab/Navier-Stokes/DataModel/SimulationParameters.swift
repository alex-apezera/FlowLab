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
    var nx: Int = 100
    var ny: Int = 100
    var Lx: Double = 0.15 /// [m]
    var Ly: Double = 0.15 /// [m]
    var stretch_x: Double = 2.0
    var stretch_y: Double = 2.0
    var Rx: Double = 3.0
    
    // Гравитация
    var gravityRotationVelocity: Double = 0.0 /// Cкорость вращения вектора [º/h]
    var gravityInitialAngle: Double = 0.0 /// 0 = 0º ( ↓ ), 90 = 90º ( ← )
    var isGravitySynchronized: Bool = false
    
    // Подвод тепла к левой стенке
    var heatingType: HeatingType = .temperature
    var heatingValue: Double = 30.0 /// [ºC] for ΔT, [W/m²] for heatFlux
    
    // Вещество
    var substance: Substance = .wax23
    /// Вычисляемые свойства для доступа к актуальным данным
    var customFluidProperties: FluidProperties = .custom
    var currentProperties: FluidProperties {
        switch substance {
        case .custom: return customFluidProperties /// Возвращаем измененные данные
        case .water: return .water
        case .wax23: return .wax23
        case .wax33: return .wax33
        case .wax56: return .wax56
        case .air: return .air
        }
    }
    // Параметры управления временем
    var maxTime: Double = 60 /// максимальное вычмслительное время [s]
    var timeStep: Double = 0.001 /// вычислительный временной шаг [s] Δt
    var timeGap: Double = 0.15 /// шаг занесения результатов в историю [s] > Δt
    var timeScale: Double = 1.0 /// масштабирование времени при плавлении
    
    // Управление ходом вычислений
    var maxIterations: Int = 250 /// для давления
    var relaxationFactor: Double = 0.5 /// для давления
    var criticalError: Double = 1e-4 /// критическая ошибка
    var countsLimit: Int = 4000 /// лимит шагов для диагностики
    var maxHistorySteps: Int = 4000 /// лимит шагов для истории
    var hiStabLimit: Double = 0.38 /// максимальный предел для числа Куранта
    var lowStabLimit: Double = 0.28 /// минимальный предел для числа Куранта

    var allowMelt = false /// ВКЛ/ВЫКЛ  режим расчета плавления
    var startMeltingStep: Int = 0 /// шаг начала процесса плавления
    var initMeltWidthRatio = 1.0 /// относительная начальная толщина расплава для EPM
    
    var useEnthalpyMethod = false /// использовать метод EPM
    var useParallelDiffuse = false /// использовать паралл.вычисл.дифф. в ALE
    var dTm = 0.01 /// T melt - T cold [K] - для метода EPM
}
