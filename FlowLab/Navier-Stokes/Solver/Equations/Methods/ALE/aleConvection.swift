//
//  aleConvection.swift
//  FlowLab
//
//  Created by Алексей Езерский on 27.06.2026.
//
//MARK: - Convection for 𝐕 and T (ALE)

import Foundation
extension NavierStokesSolver {
    
    /// Convection ∂𝐕/∂t = gβ(Τ-Τ₀) - (1/ρ)∇p - (𝐕・∇)𝐕
    func aleConvectionV(_ uNew: inout [Double], _ vNew: inout [Double]) {
        
        /// Ptr
        uNew.withUnsafeMutableBufferPointer { uNew in
        vNew.withUnsafeMutableBufferPointer { vNew in
        T.withUnsafeBufferPointer { T in
        p.withUnsafeBufferPointer { p in
        x.withUnsafeBufferPointer { x in
        y.withUnsafeBufferPointer { y in
        u.withUnsafeBufferPointer { u in
        v.withUnsafeBufferPointer { v in
                            
        if useConcurrence {
            DispatchQueue.concurrentPerform(iterations: workerCount) { wID in
                let startY = 1 + (wID * (ny - 2) / workerCount)
                let endY = 1 + ((wID + 1) * (ny - 2) / workerCount)
                
                convectionV(&uNew, &vNew, T, p, x, y, u, v, startY: startY, endY: endY)
            }
        } else {
            convectionV(&uNew, &vNew, T, p, x, y, u, v, startY: 1, endY: ny-1)
        }
            
        }}}}}}}} /// Ptr

    }
    
    /// Convection ∂T/∂t = -(𝐕·∇)T
    func aleConvectionT(_ TNew: inout [Double]) {
        
        /// Ptr
        TNew.withUnsafeMutableBufferPointer { TNew in
        T.withUnsafeBufferPointer { T in
        x.withUnsafeBufferPointer { x in
        y.withUnsafeBufferPointer { y in
        u.withUnsafeBufferPointer { u in
        v.withUnsafeBufferPointer { v in
        
        if useConcurrence {
            DispatchQueue.concurrentPerform(iterations: workerCount) { wID in
                let startY = 1 + (wID * (ny - 2) / workerCount)
                let endY = 1 + ((wID + 1) * (ny - 2) / workerCount)
                convectionT(&TNew, T, x, y, u, v, startY: startY, endY: endY)
            }
        } else {
            convectionT(&TNew, T, x, y, u, v, startY: 1, endY: ny-1)
        }
            
        }}}}}}/// Ptr
        
    }
    /// Конвекция для Температуры
    func convectionT(_ TNew: inout Mutable, _ T: ReadOnly, _ x: ReadOnly, _ y: ReadOnly, _ u: ReadOnly, _ v: ReadOnly, startY: Int, endY: Int) {
        let nx = self.nx, ny = self.ny, dt = self.dt
        
        // Convection ∂T/∂t = -(𝐕·∇)T
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
        }
    }
    /// Конвекция для вектора скорости
    func convectionV(_ uNew: inout Mutable, _ vNew: inout Mutable, _ T: ReadOnly, _ p: ReadOnly, _ x: ReadOnly, _ y: ReadOnly, _ u: ReadOnly, _ v: ReadOnly, startY: Int, endY: Int) {
        let nx = self.nx, ny = self.ny, dt = self.dt
        let (gx, gy) = gVector(for: time)
        let T_ref = 0.5 * (T_max + T_cold) /// для β - плотность берется при T_ref
        let inv_rho = 1.0 / rho
        
        for j in startY..<endY {
            let row = j * nx
            let dy = y[j+1] - y[j-1]
            let rxJ = rx[j]
            
            /// Учёт скорости границы плавления
            let rowExpansionRatio = V_melt[j] * rxJ / Lx
            
            for i in 1..<(nx-1) {
                let idx = i + row
                let dx = (x[i+1] - x[i-1]) * rxJ
                
                /// Скорость узла [m/s]
                let w_grid = x[i] * rowExpansionRatio
                
                //  LUD: ∂𝐕/∂t = - (𝐕・∇)𝐕
                let uVal = u[idx] - w_grid /// учет скорости узла
                let vVal = v[idx]
                let u_conv_x =
                upwind2(phi: u, velocity: uVal, j, i, idx, axisX: true, nx, ny, x, y)
                let u_conv_y =
                upwind2(phi: u, velocity: vVal, j, i, idx, axisX: false, nx, ny, x, y)
                let v_conv_x =
                upwind2(phi: v, velocity: uVal, j, i, idx, axisX: true, nx, ny, x, y)
                let v_conv_y =
                upwind2(phi: v, velocity: vVal, j, i, idx, axisX: false, nx, ny, x, y)
                let u_conv = u_conv_x + u_conv_y
                let v_conv = v_conv_x + v_conv_y
                
                // ∂𝐕/∂t +=  -(1/ρ)∇p
                let gradP_x = inv_rho * (p[idx+1] - p[idx-1]) / dx
                let gradP_y = inv_rho * (p[idx+nx] - p[idx-nx]) / dy
                
                // ∂𝐕/∂t += gβ(Τ-Τ₀)
                let temp = T[idx]
                let theta = temp - T_ref
                let beta = beta(temp) /// учет β(T)
                let buoy_x = gx * beta * theta
                let buoy_y = -gy * beta * theta
                
                // ∂𝐕/∂t = gβ(Τ-Τ₀) - (1/ρ)∇p - (𝐕・∇)𝐕
                uNew[idx] = uVal + dt * (-u_conv - gradP_x + buoy_x)
                vNew[idx] = vVal + dt * (-v_conv - gradP_y + buoy_y)
            }
        }/// J
    }
    
}
