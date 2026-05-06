//
//  epmMomentumPar.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 15.01.2026.
//
/*
//MARK: - Solve momentum equation (EPM, Gauss-Seidel) use concurrence
//MARK: Уравнение импульса ∂u/∂t + (u・∇)u = -(1/ρ)∇p + ν∇²u + gβ(Τ - Τ₀)

import Foundation
extension NavierStokesSolver {
    /// Решение уравнения импульса для квадратной сетки
    func epmMomentumPar(_ uNew: inout [Double], _ vNew: inout [Double]) {
        guard !isFrozen else {return}

        let nx = self.nx, ny = self.ny
        let nx_max = nx-1, ny_max = ny-1
        let dt = self.dt
        let (gx, gy) = gVector(for: time)
        let T_ref = 0.5 * (T_max + T_cold)
        let inv2h = 1 / (2*h)
        
        uNew.withUnsafeMutableBufferPointer { uNew in
        vNew.withUnsafeMutableBufferPointer { vNew in
        u.withUnsafeBufferPointer { u in
        v.withUnsafeBufferPointer { v in
        T.withUnsafeBufferPointer { T in
        liquidFraction.withUnsafeBufferPointer { f in
                
        // Параллельный расчет конвекции и плавучести
        DispatchQueue.concurrentPerform(iterations: workerCount) { wID in
            let startY = 1 + (wID * (ny - 2) / workerCount)
            let endY = 1 + ((wID + 1) * (ny - 2) / workerCount)
            
            convectionEpmV(startY: startY, endY: endY, uNew, vNew, u, v, T, f)

//            for j in startY..<endY {
//                let row = j*nx
//                
//                for i in 1..<nx-1 {
//                    let idx = row+i
//                    let uVal = u[idx], vVal = v[idx], tVal = T[idx]
//                    let f_current = f[idx]
//                    /// (u・∇)u - конвекция 2-го порядка (LUD)
//                    let u_conv_x = upwind2Epm(phi: u, velocity: uVal, j, i, idx, nx, nx_max, ny_max, inv2h, axisX: true)
//                    let u_conv_y = upwind2Epm(phi: u, velocity: vVal, j, i, idx, nx, nx_max, ny_max, inv2h, axisX: false)
//                    let v_conv_x = upwind2Epm(phi: v, velocity: uVal, j, i, idx, nx, nx_max, ny_max, inv2h, axisX: true)
//                    let v_conv_y = upwind2Epm(phi: v, velocity: vVal, j, i, idx, nx, nx_max, ny_max, inv2h, axisX: false)
//                    let u_conv = u_conv_x + u_conv_y
//                    let v_conv = v_conv_x + v_conv_y
//                    
//                    /// (1/ρ)∇p -- учитывается при коррекции скорости
//                    
//                    /// Плавучесть (Boussinesq)
//                    let deltaT = tVal - T_ref
//                    let buoy_x = gx * beta(tVal) * deltaT
//                    let buoy_y = -gy * beta(tVal) * deltaT
//                    
//                    /// Промежуточная скорость (запись в uNew/vNew)
//                    uNew[idx] = uVal + dt * (buoy_x - u_conv) * f_current
//                    vNew[idx] = vVal + dt * (buoy_y - v_conv) * f_current
//                }/// i
//            }/// j
        }/// concurrentPerform
        }}}}}}/// Ptr
        
        // ν∇²u - диффузия
        epmDiffuse(quantity: &uNew, isMomentum: true)
        epmDiffuse(quantity: &vNew, isMomentum: true)
        
        applyVelocityBoundaryConditions(&uNew, &vNew)/// 𝐕=0
    }
}
*/
