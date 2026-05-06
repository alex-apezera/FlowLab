//
//  FluidProperties.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 05.12.2025.
//
// MARK: - Физические свойства вещества

import SwiftUI

struct FluidProperties: Codable, Sendable {
    // Набор свойств для произвольного вещества (= eicosane)
    var name: String = "Custom" /// название вщества/жидкости
    var density: Double = 780 /// ρ₀, опорная плотность [kg/m³]
    var viscosity: Double = 2.85e-5 /// ν, кинематическая вязкость  [m²/s]
    var thermalDiffusivity: Double = 1.12e-7 /// α, температуропроводность  [m²/s]
    var thermalConductivity: Double = 0.15 /// λ, теплопроводность [W/m·K]
    var specificHeat: Double = 2300 /// Cp, изобарная теплоемкость [W·s/kg·K]
    var expansionCoefficient: Double = 0.00085 /// β, объёмное расширение [K⁻¹]
    var T_melt: Double = 36 /// T₀, температура плавления [℃]
    var latentHeat: Double = 247_000 /// Lh,  теплота плавления [W·s/kg] ([J/kg])
    var rho_solid: Double = 820.0 /// ρ₁,  плотность тв.фазы [kg/m³]
    var lambda_solid: Double = 0.425 /// λ₁, теплопроводность тв.фазы [W/m·K]
    var Cp_solid: Double = 1900 /// Cp₁, изобарная теплоемкость тв.фазы [W·s/kg·K]
    
    // Статические переменные, которые возвращают набор свойств
 
    static var water: FluidProperties { /// 0 ÷ 40°C
        return FluidProperties(
            name: "Water",
            density: 1000,
            viscosity: 1.306e-6,
            thermalDiffusivity: 1.42e-7,
            thermalConductivity: 0.6, /// зависит от температуры (calculatedVars)
            specificHeat: 4217,/// Cp =  4217[0°]÷ 4178[40°C]
            expansionCoefficient: 8.8e-5,
            T_melt: 0.0, /// [°C]
            latentHeat: 333000, ///  [W•s/kg]
            rho_solid: 917.0,
            lambda_solid: 2.2,
            Cp_solid: 2100
        )
        
    }
    static var eicosane: FluidProperties {  /// +40°C
        return FluidProperties(
            name: "Eicosane",
            density: 780,///780→750 кг/м³
            viscosity: 2.85e-5, /// 23°C
            thermalDiffusivity: 1.12e-7,
            thermalConductivity: 0.15, ///  ~0,15→0,14 Вт/(м·К)
            specificHeat: 2300, ///2200→2400 Дж/(кг·К).
            expansionCoefficient: 0.00085,
            T_melt: 36.0, /// [°C]
            latentHeat: 247000, ///  [W•s/kg]
            rho_solid: 820,
            lambda_solid: 0.425,
            Cp_solid: 1900
        )
    }
    static var docosane: FluidProperties {
        return FluidProperties(
            name: "Docosane",
            density: 765,///~775→745 кг/м³.
            viscosity: 2.84e-5,
            thermalDiffusivity: 1.12e-7,
            thermalConductivity: 0.14,
            specificHeat: 2400, /// ~2250→2500 Дж/(кг·К).
            expansionCoefficient: 0.00082,
            T_melt: 44.0, /// [°C]
            latentHeat: 230000, ///  [W•s/kg]
            rho_solid: 810,
            lambda_solid: 0.37,
            Cp_solid: 1900
        )
    }
    static var wax56: FluidProperties {
        return FluidProperties(
            name: "Wax",
            density: 770,
            viscosity: 2.82e-5,
            thermalDiffusivity: 1.12e-7,
            thermalConductivity: 0.14,
            specificHeat: 2700, /// ~2600→2800 Дж/(кг·К)
            expansionCoefficient: 0.0008,
            T_melt: 56.0, /// [°C]
            latentHeat: 220000, ///  [W•s/kg]
            rho_solid: 900,
            lambda_solid: 0.25,
            Cp_solid: 2000
        )
    }
    static var air: FluidProperties { /// 0 - 100°C
        return FluidProperties(
            name: "Air",
            density: 1.248,
            viscosity: 14.2e-6,
            thermalDiffusivity: 19.88e-6,
            thermalConductivity: 0.026,
            specificHeat: 1006,
            expansionCoefficient: 0.0035317,
            T_melt: 0.0, /// условная температура
            latentHeat: 1e10, ///  [W•s/kg] (запрет плавления)
            rho_solid: 810, /// not used
            lambda_solid: 0.27,/// not used
            Cp_solid: 1900/// not used
        )
    }
    /// This properties may edited in Settings/Object/Substance
    static var custom: FluidProperties {
        return FluidProperties( /// =  eicosane, ρ, λ, Cp: solid = liquid
            name: "Custom",
            density: 780,
            viscosity: 2.85e-5,
            thermalDiffusivity: 1.12e-7,
            thermalConductivity: 0.15,
            specificHeat: 2300,
            expansionCoefficient: 0.00085,
            T_melt: 36.0,/// [°C]
            latentHeat: 247000, /// свыше 1е6 - плавления нет
            rho_solid: 820,
            lambda_solid: 0.425,
            Cp_solid: 1900
        )
    }
}
