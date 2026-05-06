//
//  calculatedParams.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 25.11.2025.
//
// MARK: - Вычисляемые физические параметры вещества

import Foundation
extension NavierStokesSolver {
        
    /// α - температуропроводность - thermal diffusivity [m²/s]
    @inline(__always)
    var alpha: Double { params.currentProperties.thermalDiffusivity }

    var alpha_solid: Double {
        switch substance {
        case .water, .eicosane, .docosane, .wax56, .air:
            return params.currentProperties.lambda_solid / (params.currentProperties.rho_solid * params.currentProperties.Cp_solid)
        case .custom:
            return params.customFluidProperties.lambda_solid / (params.customFluidProperties.rho_solid * params.customFluidProperties.Cp_solid)
        }
    }

    @inline(__always) func alpha(_ T: Double) -> Double {
        switch substance {
        case .water: return 1.33E-7 + 4.75E-10 * T
        case .eicosane: return 8.86e-8 - 2.375e-9 * (T - 36)
        case .docosane: return 8.49e-8 - 2.22e-9 * (T - 44)
        case .wax56: return 7.15e-8 - 2.1e-9 * (T - 55)
        case .air: return 18.6e-6 - 0.128e-6 * T
        case .custom: return alpha
        }
    }
    
    /// коэффициент объемного теплового  расширения
    /// β - volumetric thermal expansion coefficient (expansionCoefficient) [K⁻¹]
    @inline(__always)
    var beta: Double { params.currentProperties.expansionCoefficient }
    /// β - volumetric thermal expansion coefficient (expansionCoefficient) [K⁻¹]
    @inline(__always) func beta(_ T: Double) -> Double {
        switch substance {
        case .water: return ///  (0-40ºC)
            -(0.0064e-3 - 0.017e-3 * T + 0.000204e-3 * T * T)
        case .eicosane: return 0.85e-3 - 2.5e-6 * (T-36)
        case .docosane: return 0.82e-3 - 2.5e-6 * (T-44)
        case .wax56: return 0.8e-3 - 0.003e-3 * (T-56)
        case .air: return 1/(T + 273.15) /// [K⁻¹]
        case .custom: return beta
        }
    }
    
    /// ν - кинематическая вязкость - kinematic viscosity [m²/s]
    @inline(__always) var nu: Double {params.customFluidProperties.viscosity}
    @inline(__always) func nu(_ T: Double) -> Double {
        switch substance {
//        case .water: return 1.787e-6 * exp(-0.033 * T) ///  (0-40ºC)
        case .water: return 1.787e-6 - 0.028e-6 * T ///  (0-40ºC)
        case .eicosane: return 4.49e-6 - 8.35e-8 * (T - 36)
        case .docosane: return 5.16e-6 - 9.3e-8 * (T - 44)
        case .wax56: return 5.77e-6 - 1.08e-7 * (T - 56)
        case .air: return 13.28e-6 + 0.094e-6 * T /// (0 - 100°C)
        case .custom: return nu
        }
    }
    
    /// λ - теплопроводность - thermal сonductivity [W/m•K]
    @inline(__always) var lambda: Double { params.customFluidProperties.thermalConductivity }
    @inline(__always) func lambda(_ T: Double) -> Double {
        switch substance {
        case .water: return  0.561 + 0.013 * T ///  (0-40ºC)
        case .eicosane: return 0.152 - 0.00019 * T
        case .docosane: return 0.148 - 0.00018 * T
        case .wax56: return 0.145 - 0.0002 * T
        case .air: return params.currentProperties.thermalConductivity
        case .custom: return lambda
        }
    }
    
    /// μ - динамическая вязкость при 5ºC [Pa•s = kg//m•s] = ν•ρ
    var mu: Double {nu * rho}
    
    /// ρ -  плотность  [kg/m³]
    @inline(__always) var rho: Double {
        switch substance {
        case .water, .eicosane, .docosane, .wax56, .air:
            return params.currentProperties.density
        case .custom: return params.customFluidProperties.density
        }
    }
    
    /// Cp -  теплоемкость  - specific нeat  [W•s/kg•K]
    @inline(__always) var Cp: Double {
        switch substance {
        case .water, .eicosane, .docosane, .wax56, .air: return params.currentProperties.specificHeat
        case .custom: return params.customFluidProperties.specificHeat
        }
    }
    
    /// скрытая теплота плавления  [W•s/kg]
    @inline(__always) var latentHeat: Double {
        switch substance {
        case .water, .eicosane, .docosane, .wax56, .air:
            return params.currentProperties.latentHeat
        case .custom: return params.customFluidProperties.latentHeat
        }
    }
    
    // Для твердой фазы
    @inline(__always) var rho_solid: Double {
        switch substance {
        case .water, .eicosane, .docosane, .wax56, .air:
            return params.currentProperties.rho_solid
        case .custom: return params.customFluidProperties.rho_solid
        }
    }
    @inline(__always) var lambda_solid: Double {
        switch substance {
        case .water, .eicosane, .docosane, .wax56, .air:
            return params.currentProperties.lambda_solid
        case .custom: return params.customFluidProperties.lambda_solid
        }
    }
    @inline(__always) var Cp_solid: Double {
        switch substance {
        case .water, .eicosane, .docosane, .wax56, .air:
            return params.currentProperties.Cp_solid
        case .custom: return params.customFluidProperties.Cp_solid
        }
    }


    //MARK: - Вычисление чисел подобия
    
    var Ra: Double { gMagnitude * beta * deltaT * L*L*L / (nu * alpha) }
    var Pr: Double { nu / alpha }
    var Re: Double { maxVelocityValue * rho * L / mu }
    var Ste: Double { Cp * deltaT / latentHeat }
    var Fo: Double { alpha * time / (L*L) }

}
