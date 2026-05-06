//
//  epmMomentum.swift
//  FlowLab
//
//  Created by Алексей Езерский on 03.05.2026.
//

//MARK: - Solve momentum equation (EPM, Gauss-Seidel)
//MARK: ∂𝐕/∂t + (𝐕・∇)𝐕 = -(1/ρ)∇p + ν∇²𝐕 + gβ(Τ - Τ₀)

import Foundation
extension NavierStokesSolver {
    /// Решение уравнения импульса для квадратной сетки
    func epmMomentum(_ uNew: inout [Double], _ vNew: inout [Double]) {
        guard !isFrozen else {return}

        // Convection ∂𝐕/∂t = gβ(Τ-Τ₀) -(1/ρ)∇p - (𝐕・∇)𝐕
        epmConvectionV(&uNew, vNew: &vNew)
 
        // учет диффузии ∂𝐕/∂t += ν∇²𝐕
        epmDiffuse(quantity: &uNew, isMomentum: true)
        epmDiffuse(quantity: &vNew, isMomentum: true)

        // явные граничные условия
        applyVelocityBoundaryConditions(&uNew, &vNew)
    }
}
