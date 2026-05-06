//
//  epmConvection.swift
//  FlowLab
//
//  Created by Алексей Езерский on 29.06.2026.
//
//MARK: - Convection for 𝐕 and T (EPM)

import Foundation
extension NavierStokesSolver {
    
    // Convection ∂𝐕/∂t = gβ(Τ-Τ₀) -(1/ρ)∇p - (𝐕・∇)𝐕
    func epmConvectionV(_ uNew: inout [Double], vNew: inout [Double]) {
        
        /// pinning
        uNew.withUnsafeMutableBufferPointer { uNew in
        vNew.withUnsafeMutableBufferPointer { vNew in
        u.withUnsafeBufferPointer { u in
        v.withUnsafeBufferPointer { v in
        T.withUnsafeBufferPointer { T in
        liquidFraction.withUnsafeBufferPointer { f in
    
        // Учёт конвекции ∂𝐕/∂t = gβ(Τ - Τ₀) - (𝐕・∇)𝐕
        if useConcurrence {
            DispatchQueue.concurrentPerform(iterations: workerCount) { wID in
                let startY = 1 + (wID * (ny - 2) / workerCount)
                let endY = 1 + ((wID + 1) * (ny - 2) / workerCount)
                
                convectionEpmV(startY: startY, endY: endY, uNew, vNew, u, v, T, f)
            }
        } else {
            convectionEpmV(startY: 1, endY: ny-1, uNew, vNew, u, v, T, f)
        }
        }}}}}}/// pinning

    }
    
    /// Учёт конвекции ∂T/∂t =  - (𝐕・∇)T
    func epmConvectionT(_ TNew: inout [Double]) {
        
        // Получаем прямой доступ к памяти массивов
        TNew.withUnsafeMutableBufferPointer { TNew in
        T.withUnsafeBufferPointer { T_old in
        u.withUnsafeBufferPointer { u in
        v.withUnsafeBufferPointer { v in
                        
            if useConcurrence {
                DispatchQueue.concurrentPerform(iterations: workerCount) { wID in
                    let startY = 1 + (wID * (ny - 2) / workerCount)
                    let endY = 1 + ((wID + 1) * (ny - 2) / workerCount)
                    
                    convectionEpmT(startY: startY, endY: endY, TNew, u, v, T_old)
                }
            } else {
                convectionEpmT(startY: 1, endY: ny-1, TNew, u, v, T_old)
            }
            
        }}}}///pinning
        
    }
    /// Учет конвекции и выталкивающей силы ∂𝐕/∂t + (𝐕・∇)𝐕 = gβ(Τ - Τ₀) для скорости
    func convectionEpmV(startY: Int, endY: Int, _ uNew: Mutable, _ vNew: Mutable, _ u: ReadOnly, _ v: ReadOnly, _ T: ReadOnly, _ f: ReadOnly) {
        
        let nx = self.nx, ny = self.ny
        let nx_max = nx-1, ny_max = ny-1
        let dt = self.dt
        let (gx, gy) = gVector(for: time)
        let T_ref = 0.5 * (T_max + T_cold)
        let inv2h = 1 / (2*h)
        
        for j in startY..<endY {
            let row = j*nx
            
            for i in 1..<nx-1 {
                let idx = row+i
                let uVal = u[idx], vVal = v[idx], tVal = T[idx]
                let f_current = f[idx]
                
                // конвекция 2-го порядка (LUD): (𝐕・∇)𝐕
                let u_conv_x = upwind2Epm(phi: u, velocity: uVal, j, i, idx, nx, nx_max, ny_max, inv2h, axisX: true)
                let u_conv_y = upwind2Epm(phi: u, velocity: vVal, j, i, idx, nx, nx_max, ny_max, inv2h, axisX: false)
                let v_conv_x = upwind2Epm(phi: v, velocity: uVal, j, i, idx, nx, nx_max, ny_max, inv2h, axisX: true)
                let v_conv_y = upwind2Epm(phi: v, velocity: vVal, j, i, idx, nx, nx_max, ny_max, inv2h, axisX: false)
                let u_conv = u_conv_x + u_conv_y
                let v_conv = v_conv_x + v_conv_y
                
                // (1/ρ)∇p -- учитывается при коррекции скорости
                
                // Вталкивающая сила: gβ(Τ - Τ₀)
                let deltaT = tVal - T_ref
                let buoy_x = gx * beta(tVal) * deltaT
                let buoy_y = -gy * beta(tVal) * deltaT
                
                // Промежуточная скорость (запись в uNew/vNew)
                // ∂𝐕/∂t + (𝐕・∇)𝐕 = gβ(Τ - Τ₀)
                uNew[idx] = uVal + dt * (buoy_x - u_conv) * f_current
                vNew[idx] = vVal + dt * (buoy_y - v_conv) * f_current
            }/// i
        }/// j
    }
    
    /// Учет конвекции для температуры ∂T/∂t + (𝐕・∇)T = 0
    func convectionEpmT(startY: Int, endY: Int, _ TNew: Mutable, _ u: ReadOnly, _ v: ReadOnly, _ T_old: ReadOnly) {
        
        let nx = self.nx, ny = self.ny, dt = self.dt
        let inv2h = 0.5 / h /// = 1 / (2*h)
        let nx_max = nx-1, ny_max = ny-1

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

    }
}
