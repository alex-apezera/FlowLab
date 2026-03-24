//
//  calculatedParams.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 25.11.2025.
//

extension NavierStokesSolver {
    
    // MARK: - Вычисляемые физические параметры вещества
    
    // α - температуропроводность - thermal diffusivity [m²/s]
    @inline(__always)
    var alpha: Double { params.currentProperties.thermalDiffusivity }
    @inline(__always) func alpha(_ T: Double) -> Double {
        switch substance {
        case .water: return lambda(T)/rho/Cp
        case .wax23, .wax33, .wax56: return alpha
        case .air: return 18.6e-6 - 0.128e-6 * T
        case .custom: return params.customFluidProperties.thermalDiffusivity
        }
    }
    
    /// коэффициент объемного теплового  расширения
    /// β - volumetric thermal expansion coefficient (expansionCoefficient) [K⁻¹]
    @inline(__always)
    var beta: Double { params.currentProperties.expansionCoefficient }
    @inline(__always) func beta(_ T: Double) -> Double {
        switch substance {
        case .water: return ///  (0-40ºC)
            -(0.0064e-3 - 0.017e-3 * T + 0.000204e-3 * T * T)
        case .wax23, .wax33, .wax56: return beta
        case .air: return 1/(T + 273.15) /// [K⁻¹]
        case .custom: return params.customFluidProperties.expansionCoefficient
        }
    }
    
    /// ν - кинематическая вязкость - kinematic viscosity [m²/s]
    @inline(__always) var nu: Double {params.currentProperties.viscosity}
    @inline(__always) func nu(_ T: Double) -> Double {
        switch substance {
        case .water: return 1.787e-6 - 0.046e-6 * T ///  (0-40ºC)
        case .wax23, .wax33, .wax56: return nu
        case .air: return 13.28e-6 + 0.094e-6 * T /// (0 - 100°C)
        case .custom: return params.customFluidProperties.viscosity
        }
    }
    
    /// λ - теплопроводность - thermal сonductivity [W/m•K]
    @inline(__always) var lambda: Double { params.currentProperties.thermalConductivity }
    @inline(__always) func lambda(_ T: Double) -> Double {
        switch substance {
        case .water: return  0.561 + 0.013 * T ///  (0-40ºC)
        case .wax23, .wax33, .wax56, .air: return lambda
        case .custom: return params.customFluidProperties.thermalConductivity
        }
    }
    
    /// μ - динамическая вязкость при 5ºC [Pa•s = kg//m•s] = ν•ρ
    var mu: Double {nu * rho}
    
   /// ρ -  плотность  [kg/m³]
    @inline(__always) var rho: Double {
        switch substance {
        case .water, .wax23, .wax33, .wax56, .air:
            return params.currentProperties.density
        case .custom: return params.customFluidProperties.density
        }
    }

    /// Cp -  теплоемкость  - specific нeat  [W•s/kg•K]
    @inline(__always) var Cp: Double {
        switch substance {
        case .water, .wax23, .wax33, .wax56, .air: return params.currentProperties.specificHeat
        case .custom: return params.customFluidProperties.specificHeat
        }
    }
    
    /// скрытая теплота плавления  [W•s/kg]
    @inline(__always) var latentHeat: Double {
        switch substance {
        case .water, .wax23, .wax33, .wax56, .air:
            return params.currentProperties.latentHeat
        case .custom: return params.customFluidProperties.latentHeat
        }
    }
    
    //MARK: - Вычисление чисел подобия
    
    var Ra: Double { gMagnitude * beta * deltaT * L*L*L / (nu * alpha) }
    var Pr: Double { nu / alpha }
    var Re: Double { maxVelocityValue * rho * L / mu }
    var Ste: Double { Cp * deltaT / latentHeat }
    var Fo: Double { alpha * time / (L*L) }

}
