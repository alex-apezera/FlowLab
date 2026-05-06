//
//  aleMomentumPar.swift
//  FlowLab
//
//  Created by Алексей Езерский on 09.06.2026.
//
//MARK: - Momentum equation ∂𝐕/∂t + (𝐕・∇)𝐕 = -(1/ρ)∇p + ν∇²𝐕 + gβ(Τ-Τ₀)
//MARK: + Concurrence
/*
import Foundation
extension NavierStokesSolver {
    
    /// Решение уравнений движения. Метод ALE, работает на неравномерной сетке
    func aleMomentumPar() {
        guard !isFrozen else {return}
        
        var uNew = u, vNew = v
        
        // Convection + Boussinesq: ∂𝐕/∂t = -(𝐕・∇)𝐕 -(1/ρ)∇p + gβ(Τ-Τ₀)
        
        // ИЗВЛЕКАЕМ УКАЗАТЕЛИ (Pinning)
        uNew.withUnsafeMutableBufferPointer { uNew in
        vNew.withUnsafeMutableBufferPointer { vNew in
        T.withUnsafeBufferPointer { T in
        p.withUnsafeBufferPointer { p in
        x.withUnsafeBufferPointer { x in
        y.withUnsafeBufferPointer { y in
        u.withUnsafeBufferPointer { u in
        v.withUnsafeBufferPointer { v in
        
        // Организация многопоточности
        DispatchQueue.concurrentPerform(iterations: workerCount) { wID in
            let startY = 1 + (wID * (ny - 2) / workerCount)
            let endY = 1 + ((wID + 1) * (ny - 2) / workerCount)
            
            convectionV(&uNew, &vNew, T, p, x, y, u, v, startY: startY, endY: endY)
                
  /*              for j in startY..<endY {
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
                        upwind2(phi: u, velocity: uVal, j, i, idx, axisX: true, nx, ny)
                        let u_conv_y =
                        upwind2(phi: u, velocity: vVal, j, i, idx, axisX: false, nx, ny)
                        let v_conv_x =
                        upwind2(phi: v, velocity: uVal, j, i, idx, axisX: true, nx, ny)
                        let v_conv_y =
                        upwind2(phi: v, velocity: vVal, j, i, idx, axisX: false, nx, ny)
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
                }*/
            }}}}}}}}} /// Ptr + Concurence
 
        // Diffuse ∂𝐕/∂t += ν∇²𝐕
        aleDiffuse(quantity: &uNew, isMomentum: true)
        aleDiffuse(quantity: &vNew, isMomentum: true)
       
        // явные граничные условия
        applyVelocityBoundaryConditions(&uNew, &vNew)

        // Обновление
        u = uNew; v = vNew
    }
}
*/
