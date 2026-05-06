//
//  epmEnergyPar.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 12.01.2026.
//
//MARK: - Solve energy equation ∂T/∂t + (u·∇)T = α∇²T (LUD, EPM) use concurrence
/*
import Foundation
extension NavierStokesSolver {
    
    /// Уравнение энергии: ∂T/∂t + (u·∇)T = α∇²T
    func epmEnergyPar(_ TNew: inout [Double]) {
        let nx = self.nx, ny = self.ny, dt = self.dt
        let inv2h = 0.5 / h /// = 1 / (2*h)
        let nx_max = nx-1, ny_max = ny-1
        
        // Получаем прямой доступ к памяти массивов
        TNew.withUnsafeMutableBufferPointer { TNew in
        T.withUnsafeBufferPointer { T_old in
        u.withUnsafeBufferPointer { u in
        v.withUnsafeBufferPointer { v in

        // Организация многопоточности
        DispatchQueue.concurrentPerform(iterations: workerCount) { wID in
            let startY = 1 + (wID * (ny - 2) / workerCount)
            let endY = 1 + ((wID + 1) * (ny - 2) / workerCount)
            
            for j in startY..<endY {
                let row = j*nx
                
                for i in 1..<nx-1 {
                    let idx = row + i
                    
                    // Convection ∂T/∂t = - (u·∇)T
                    let T_conv =
                    upwind2Epm(phi: T_old, velocity: u[idx], j, i, idx, nx, nx_max, ny_max, inv2h, axisX: true) +
                    upwind2Epm(phi: T_old, velocity: v[idx], j, i, idx, nx, nx_max, ny_max, inv2h, axisX: false)
                    
                    /// Запись в TNew через прямое обращение
                    TNew[idx] = T_old[idx] - dt * T_conv
                }
            }
        }}}}}///pinning + concurrentPerform

        // Diffuse ∂T/∂t += α∇²T
        epmDiffuse(quantity: &TNew)
        applyTemperatureBoundaryConditions(&TNew) /// явные граничные условия
    }
    
}
*/
