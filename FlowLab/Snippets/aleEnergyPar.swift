//
//  aleEnergyPar.swift
//  FlowLab
//
//  Created by Алексей Езерский on 09.06.2026.
//
//MARK: - Solve energy equation (LUD, Concurrence)
//MARK:   ∂T/∂t + (𝐕·∇)T = α∇²T
/*
import Foundation
extension NavierStokesSolver {
    
    // Метод ALE, работает на неравномерной сетке, параллельные вычисления
    func aleEnergyPar() {
        let nx = self.nx, ny = self.ny, dt = self.dt
        var TNew = T
     
        // Convection: ∂T/∂t = -(𝐕·∇)T

        // ИЗВЛЕКАЕМ УКАЗАТЕЛИ (Pinning)
        TNew.withUnsafeMutableBufferPointer { TNew in
        T.withUnsafeBufferPointer { T in
        x.withUnsafeBufferPointer { x in
        y.withUnsafeBufferPointer { y in
        u.withUnsafeBufferPointer { u in
        v.withUnsafeBufferPointer { v in
                            
        // Организация многопоточности
        DispatchQueue.concurrentPerform(iterations: workerCount) { wID in
        let startY = 1 + (wID * (ny - 2) / workerCount)
        let endY = 1 + ((wID + 1) * (ny - 2) / workerCount)
        
            for j in startY..<endY {
                let row = j * nx
                
                /// Учёт скорости границы плавления
                let rowExpansionRatio = V_melt[j] * rx[j] / Lx
                
                for i in 1..<nx-1 {
                    let idx = i + row
                    
                    /// Скорость узла [m/s]
                    let w_grid = x[i] * rowExpansionRatio
                    
                    let uVal = u[idx] - w_grid /// учет сеточной скорости в узле
                    let vVal = v[idx]
                    let T_conv = upwind2(phi: T, velocity: uVal, j, i, idx, axisX: true, nx, ny, x, y) + upwind2(phi: T, velocity: vVal, j, i, idx, axisX: false, nx, ny, x, y)
                    
                    // Явный шаг по времени для конвекции
                    TNew[idx] = T[idx] - dt * T_conv
                }
            }}}}}}}}/// Pt + Striding

        // Diffuse ∂T/∂t += α∇²T
//        useParallelDiffusion ?
//        aleDiffusePar(quantity: &TNew) :
        aleDiffuse(quantity: &TNew)
 
        // явные граничные условия
        applyTemperatureBoundaryConditions(&TNew)
        // Обновление
        T = TNew
    }
}
*/
