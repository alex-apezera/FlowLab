//
//  Momentum.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 18.07.2025.
//
//MARK: - Solve momentum equation
// Уравнение импульса ∂u/∂t + (u・∇)u = -(1/ρ)∇p + ν∇²u + gβ(Τ - Τ0)

extension NavierStokesSolver {
    
    // Метод ALE, работает на неравномерной сетке
    func solveMomentumEquations() async throws {
        var uNew = u
        var vNew = v
        let (gx, gy) = gVector(for: time)
        let T_ref = 0.5 * (T_max + T_cold) /// для β - плотность берется при T_ref
        let pressureScale = 1.0 / rho
        
        for j in 1..<(ny-1) {
            // Скорость границы
            let rowExpansionVelocity = V_melt[j]

            for i in 1..<(nx-1) {
                // Скорость узла
                let w_grid = (x[i] * rx[j] / Lx) * rowExpansionVelocity
                
                // Конвекция 2-го порядка (LUD)
                let u_curr = u[j][i] - w_grid /// учет скорости узла
                let v_curr = v[j][i]
                let u_conv = upwind2(phi: u, u_vel: u_curr, j: j, i: i, axisX: true) + upwind2(phi: u, u_vel: v_curr, j: j, i: i, axisX: false)
                let v_conv = upwind2(phi: v, u_vel: u_curr, j: j, i: i, axisX: true) + upwind2(phi: v, u_vel: v_curr, j: j, i: i, axisX: false)
     
                // Градиент давления
                let divP_x = pressureScale * derivativePX(p, j, i)
                let divP_y = pressureScale * derivativePY(p, j, i)
 
                // Выталкивающая сила (плавучесть)
                let temp = T[j][i]
                let theta = temp - T_ref
                let buoy_x = gx * beta(temp) * theta /// учет β(T)
                let buoy_y = -gy * beta(temp) * theta
                
                uNew[j][i] = u[j][i] + dt * (-u_conv - divP_x + buoy_x)
                vNew[j][i] = v[j][i] + dt * (-v_conv - divP_y + buoy_y)
            }
        }
        if useParallelDiffuse {
            diffuseParallel(quantity: &vNew, isMomentum: true)
            diffuseParallel(quantity: &vNew, isMomentum: true)
        } else {
            diffuse(quantity: &uNew, isMomentum: true) /// учитывается nu(Τ)
            diffuse(quantity: &vNew, isMomentum: true)
        }
        applyVelocityBoundaryConditions(&uNew, &vNew)

        u = uNew
        v = vNew
    
    }
}
