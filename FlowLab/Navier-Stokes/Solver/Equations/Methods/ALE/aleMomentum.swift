//
//  Momentum.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 18.07.2025.
//
//MARK: - Solve momentum equation
//MARK:  ∂𝐕/∂t + (𝐕・∇)𝐕 = -(1/ρ)∇p + ν∇²𝐕 + gβ(Τ-Τ₀)

import Foundation
extension NavierStokesSolver {
    
    /// Решение уравнений движения. Метод ALE, работает на неравномерной сетке
    func aleMomentum() {
        guard !isFrozen else {return}
        
        /// Необходимы копии массивов во избежание конфликта данных
        var uNew = u, vNew = v

        // Convection ∂𝐕/∂t = gβ(Τ-Τ₀) -(1/ρ)∇p - (𝐕・∇)𝐕
        aleConvectionV(&uNew, &vNew)

        // Diffusion  ∂𝐕/∂t += ν∇²𝐕
        aleDiffuse(quantity: &uNew, isMomentum: true)
        aleDiffuse(quantity: &vNew, isMomentum: true)
        
        // явные граничные условия
        applyVelocityBoundaryConditions(&uNew, &vNew)
        
        // Обновление
        u = uNew; v = vNew
    }
}
