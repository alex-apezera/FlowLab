//
//  epmEnergy.swift
//  FlowLab
//
//  Created by Алексей Езерский on 03.05.2026.
//
//MARK: - Solve energy equation (LUD, EPM): ∂T/∂t + (𝐕·∇)T = α∇²T

import Foundation
extension NavierStokesSolver {
    
    /// Уравнение энергии: ∂T/∂t + (𝐕·∇)T = α∇²T
    func epmEnergy() {
        var TNew = T

        // Учёт конвекции ∂T/∂t =  - (𝐕・∇)T
        epmConvectionT(&TNew)

        // Diffuse ∂T/∂t += α∇²T
        epmDiffuse(quantity: &TNew)
        
        // явные граничные условия T₀ = heatingValue, T₁ = T_cold = T_melt
        applyTemperatureBoundaryConditions(&TNew)

        T = TNew
    }
        
}
