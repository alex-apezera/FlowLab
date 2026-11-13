//
//  calculatedParams.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 25.11.2025.
//
// MARK: - Calculable physical parameters of a substance.

import Foundation
extension NavierStokesSolver {
    
    // Вычисляемые физические свойства вещества, зависящие от T [ºC]
                
    /// α - температуропроводность, thermal diffusivity [m²/s]
    ///
    /// Референсное значение (при T ref)
    @inline(__always) var alpha: Double {
        switch substance {
        case .water, .eicosane, .docosane, .wax56, .air: return alpha(T_ref)
        case .custom: return params.customFluidProperties.thermalDiffusivity
        }
    }
 
    /// α(T) - температуропроводность - thermal diffusivity [m²/s]
    ///
    /// Зависимость  от температуры (в диапазоне T melt + 40℃)
    @inline(__always) func alpha(_ T: Double) -> Double {
        switch substance {
        case .water: return params.currentProperties.thermalDiffusivity
            + 4.75E-10 * T
        case .eicosane: return params.currentProperties.thermalDiffusivity
            - 2.375e-9 * (T - 36)
        case .docosane: return params.currentProperties.thermalDiffusivity
            - 2.22e-9 * (T - 44)
        case .wax56: return params.currentProperties.thermalDiffusivity
            - 2.1e-9 * (T - 55)
        case .air: return params.currentProperties.thermalDiffusivity - 0.128e-6 * T
        case .custom: return alpha
        }
    }

    /// α - температуропроводность  для твердого тела
    var alpha_solid: Double {
        switch substance {
        case .water, .eicosane, .docosane, .wax56, .air:
            return params.currentProperties.lambda_solid / (params.currentProperties.rho_solid * params.currentProperties.Cp_solid)
        case .custom:
            return params.customFluidProperties.lambda_solid / (params.customFluidProperties.rho_solid * params.customFluidProperties.Cp_solid)
        }
    }
    
    /// β - коэффициент объемного теплового  расширения,
    ///  volumetric thermal expansion coefficient (expansionCoefficient) [K⁻¹]
    ///
    /// Референсное значение (при T ref)
    @inline(__always)
    var beta: Double {
        switch substance {
        case .water, .eicosane, .docosane, .wax56, .air: return beta(T_ref)
        case .custom: return params.customFluidProperties.expansionCoefficient
        }
    }

    /// β(T) - коэффициент объемного теплового  расширения,
    ///  volumetric thermal expansion coefficient (expansionCoefficient) [K⁻¹]
    ///
    /// Зависимость  от температуры (в диапазоне T melt + 40℃)
    @inline(__always) func beta(_ T: Double) -> Double {
        switch substance {
        case .water: return ///  (0÷40ºC)
            params.currentProperties.expansionCoefficient
            + 0.017e-3 * T - 0.000204e-3 * T * T
        case .eicosane: return params.currentProperties.expansionCoefficient
            - 2.5e-6 * (T-36)
        case .docosane: return  params.currentProperties.expansionCoefficient
            - 2.5e-6 * (T-44)
        case .wax56: return params.currentProperties.expansionCoefficient
            - 0.003e-3 * (T-56)
        case .air: return 1/(T + 273.15) /// (0÷>100ºC)
        case .custom: return beta
        }
    }
    
    /// ν - кинематическая вязкость - kinematic viscosity [m²/s]
    ///
    /// Референсное значение (при T ref)
    @inline(__always) var nu: Double {
        switch substance {
        case .water, .eicosane, .docosane, .wax56, .air: return nu(T_ref)
        case .custom: return params.customFluidProperties.viscosity
        }
    }
    /// ν(T) - кинематическая вязкость - kinematic viscosity [m²/s]
    ///
    /// Зависимость  от температуры (в диапазоне T melt + 40℃)
    @inline(__always) func nu(_ T: Double) -> Double {
        switch substance {
//        case .water: return 1.787e-6 * exp(-0.033 * T) ///  (0÷40ºC)
        case .water: return ///  (0÷40ºC)
            params.currentProperties.viscosity - 0.028e-6 * T
        case .eicosane: return params.currentProperties.viscosity
            - 8.35e-8 * (T - 36)
        case .docosane: return params.currentProperties.viscosity
            - 9.3e-8 * (T - 44)
        case .wax56: return params.currentProperties.viscosity
            - 1.08e-7 * (T - 56)
        case .air: return params.currentProperties.viscosity
            + 0.094e-6 * T /// (0 - 100°C)
        case .custom: return nu
        }
    }
    
    /// λ - теплопроводность - thermal сonductivity [W/m•K]
    ///
    /// Референсное значение (при T ref)
    @inline(__always) var lambda: Double {
        switch substance {
        case .water, .eicosane, .docosane, .wax56, .air: return lambda(T_ref)
        case .custom: return params.customFluidProperties.thermalConductivity
        }
}

    
    @inline(__always) func lambda(_ T: Double) -> Double {
        switch substance {
        case .water: return ///  (0÷40ºC)
            params.currentProperties.thermalConductivity + 0.013 * T
        case .eicosane: return params.currentProperties.thermalConductivity - 0.00019 * T
        case .docosane: return params.currentProperties.thermalConductivity - 0.00018 * T
        case .wax56: return params.currentProperties.thermalConductivity - 0.0002 * T
        case .air: return params.currentProperties.thermalConductivity
        case .custom: return lambda
        }
    }
        
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
        
    /// μ - динамическая вязкость [Pa•s = kg//m•s] = ν•ρ
    var mu: Double {nu * rho}

    var Ra: Double { params.gMagnitude * beta * deltaT * L*L*L / (nu * alpha) }
    var Pr: Double { nu / alpha }
    var Re: Double { maxVelocityValue * rho * L / mu }
    var Ste: Double { Cp * deltaT / latentHeat }
    var Fo: Double { alpha * time / (L*L) }
    func Nu(q: Double, T: Double) -> Double {
        return q/lambda/deltaT*L
    }

}
