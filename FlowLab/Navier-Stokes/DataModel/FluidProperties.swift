//
//  FluidProperties.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 05.12.2025.
//

//
//  FluidProperties.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 13.11.2025.
//

import SwiftUI

// MARK: - Физические свойства вещества

struct FluidProperties: Codable, Sendable {
    // Набор свойств для произвольного вещества
    var name: String = "Псевдо" /// название вщества/жидкости
    var density: Double = 500 /// ρ₀, опорная плотность [kg/m³]
    var viscosity: Double = 1e-5 /// ν, кинематическая вязкость  [m²/s]
    var thermalDiffusivity: Double = 1e-7 /// α, температуропроводность  [m²/s]
    var thermalConductivity: Double = 0.5 /// λ, теплопроводность [W/(m·K)]
    var specificHeat: Double = 2000 /// Cp, изобарная теплоемкость [J/(kg·K)]
    var expansionCoefficient: Double = 0.0001 /// β, объёмное расширение [K⁻¹]
    var T_melt: Double = 0 /// T₀, температура плавления [℃]
    var latentHeat: Double = 150000 /// Lh,  теплота плавления [W·s/kg] ([J/kg])
  
    // Статические переменные, которые возвращают набор свойств
 
    static var water: FluidProperties { /// 0 ÷ 40°C
        return FluidProperties(
            name: "Вода",
            density: 1000,
            viscosity: 1.306e-6,
            thermalDiffusivity: 1.42e-7,
            thermalConductivity: 0.6, /// зависит от температуры (calculatedVars)
            specificHeat: 4218,
            expansionCoefficient: 8.8e-5,
            T_melt: 0.0, /// [°C]
            latentHeat: 333000 ///  [W•s/kg]
        )
    }
    static var wax23: FluidProperties {  /// +40°C
        return FluidProperties(
            name: "н-Эйкозан",
            density: 780,
            viscosity: 2.85e-5, /// 23°C
            thermalDiffusivity: 1.12e-7,
            thermalConductivity: 0.2,
            specificHeat: 2300,
            expansionCoefficient: 0.00009,
            T_melt: 23.0, /// [°C]
            latentHeat: 240000 ///  [W•s/kg]
        )
    }
    static var wax33: FluidProperties {
        return FluidProperties(
            name: "н-Докозан",
            density: 785,
            viscosity: 2.84e-5,
            thermalDiffusivity: 1.12e-7,
            thermalConductivity: 0.2,
            specificHeat: 2400,
            expansionCoefficient: 0.00009,
            T_melt: 33.0, /// [°C]
            latentHeat: 230000 ///  [W•s/kg]
        )
    }
    static var wax56: FluidProperties {
        return FluidProperties(
            name: "Парафин",
            density: 800,
            viscosity: 2.82e-5,
            thermalDiffusivity: 1.12e-7,
            thermalConductivity: 0.2,
            specificHeat: 2500,
            expansionCoefficient: 0.00009,
            T_melt: 56.0, /// [°C]
            latentHeat: 200000 ///  [W•s/kg]
        )
    }
    static var air: FluidProperties { /// 0 - 100°C
        return FluidProperties(
            name: "Воздух",
            density: 1.248,
            viscosity: 14.6e-6,
            thermalDiffusivity: 19.88e-6,
            thermalConductivity: 0.026,
            specificHeat: 1006,
            expansionCoefficient: 0.0035317,
            T_melt: 0.0, /// условная температура
            latentHeat: 1e10 ///  [W•s/kg] (запрет плавления)
        )
    }
  
    static var custom: FluidProperties {
        return FluidProperties(
            name: "Псевдо",
            density: 500,
            viscosity: 5e-7,
            thermalDiffusivity: 1e-7,
            thermalConductivity: 0.5,
            specificHeat: 2000,
            expansionCoefficient: 0.0001,
            T_melt: 0.0,/// [°C]
            latentHeat: 150000 /// свыше 1е6 - плавления нет
        )
    }
}
