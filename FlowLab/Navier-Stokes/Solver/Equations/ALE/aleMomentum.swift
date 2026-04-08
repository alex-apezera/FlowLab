//
//  Momentum.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 18.07.2025.
//
//MARK: - Solve momentum equation ∂u/∂t + (u・∇)u = -(1/ρ)∇p + ν∇²u + gβ(Τ - Τ₀)
//import Foundation
extension NavierStokesSolver {
    
    /// Решение уравнений движения. Метод ALE, работает на неравномерной сетке
    func aleMomentum() {
        guard !isFrozen else {return}
        
        let nx = self.nx, ny = self.ny, dt = self.dt
        let (gx, gy) = gVector(for: time)
        let T_ref = 0.5 * (T_max + T_cold) /// для β - плотность берется при T_ref
        let inv_rho = 1.0 / rho
        var uNew = u, vNew = v
        
        for j in 1..<(ny-1) {
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
                
                /// (u・∇)u  - конвекция 2-го порядка (LUD)
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
                
                /// (1/ρ)∇p - градиент давления
                let gradP_x = inv_rho * (p[idx+1] - p[idx-1]) / dx
                let gradP_y = inv_rho * (p[idx+nx] - p[idx-nx]) / dy
 
                /// gβ(Τ - Τ₀) -  выталкивающая сила (плавучесть)
                let temp = T[idx]
                let theta = temp - T_ref
                let beta = beta(temp) /// учет β(T)
                let buoy_x = gx * beta * theta
                let buoy_y = -gy * beta * theta
                
                uNew[idx] = uVal + dt * (-u_conv - gradP_x + buoy_x)
                vNew[idx] = vVal + dt * (-v_conv - gradP_y + buoy_y)
            }
        }
        // ν∇²u - диффузия (⬅︎ ν(T) учтено)
        if useConcurrence {
            aleDiffusePar(quantity: &uNew, isMomentum: true)
            aleDiffusePar(quantity: &vNew, isMomentum: true)
        } else {
            aleDiffuse(quantity: &uNew, isMomentum: true)
            aleDiffuse(quantity: &vNew, isMomentum: true)
        }
        // явные граничные условия
        applyVelocityBoundaryConditions(&uNew, &vNew)
        // Обновление
        u = uNew; v = vNew
    }
}
