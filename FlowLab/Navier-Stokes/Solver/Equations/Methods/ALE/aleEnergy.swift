//
//  Energy.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 18.07.2025.
//
//MARK: - Solve energy equation (LUD): ∂T/∂t + (𝐕·∇)T = α∇²T

import Foundation
extension NavierStokesSolver {
    
    /// Решение уравнения энергии. Метод ALE, работает на неравномерной сетке
    func aleEnergy() {
        var TNew = T
 
        // Convection ∂T/∂t = -(𝐕·∇)T
        aleConvectionT(&TNew)
        
        // Diffuse ∂T/∂t += α∇²T
        aleDiffuse(quantity: &TNew)
 
        // явные граничные условия T₀ = heatingValue, T₁ = T_cold = T_melt
        applyTemperatureBoundaryConditions(&TNew)
        
        // Обновление
        T = TNew
    }
}
