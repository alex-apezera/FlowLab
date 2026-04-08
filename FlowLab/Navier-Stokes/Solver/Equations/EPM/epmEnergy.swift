//
//  epmEnergy.swift
//  FlowLab
//
//  Created by Алексей Езерский on 03.05.2026.
//

//MARK: - Solve energy equation ∂T/∂t + (u·∇)T = α∇²T (LUD, EPM) no concurrence

import Foundation
extension NavierStokesSolver {
    
    /// Уравнение энергии: ∂T/∂t + (u·∇)T = α∇²T
    func epmEnergy(_ TNew: inout [Double]) {
        let nx = self.nx, ny = self.ny
        let dt = self.dt, T_old = self.T
        let inv2h = 0.5 / h /// = 1 / (2*h)
        let nx_max = nx-1, ny_max = ny-1
        
        let startY = 1, endY = ny-1
        for j in startY..<endY {
            let row = j*nx
            
            for i in 1..<nx-1 {
                let idx = row + i
                
                // Convection ∂T/∂t = - (u·∇)T
                let T_conv =
                upwind2EPM(phi: T_old, velocity: u[idx], j, i, idx, nx, nx_max, ny_max, inv2h, axisX: true) +
                upwind2EPM(phi: T_old, velocity: v[idx], j, i, idx, nx, nx_max, ny_max, inv2h, axisX: false)
                
                TNew[idx] = T_old[idx] - dt * T_conv
            }
        }
        
        // Diffuse ∂T/∂t += α∇²T
        epmDiffuse(quantity: &TNew) /// ⬅︎  α(T) учтено внутри
        applyTemperatureBoundaryConditions(&TNew) /// явные граничные условия
    }
    
    
}
