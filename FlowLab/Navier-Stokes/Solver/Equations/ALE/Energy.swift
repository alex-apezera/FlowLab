//
//  Energy.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 18.07.2025.
//
//MARK: - Solve energy equation (LUD)
// Уравнение энергии: ∂T/∂t + (u·∇)T = α∇²T

extension NavierStokesSolver {
    
    // Метод ALE, работает на неравномерной сетке
    func solveEnergyEquation() async throws {
        var TNew = T
        
        // Convection ∂T/∂t = -(u·∇)T
        for j in 1..<ny-1 {
            let v_wall = V_melt[j]

            for i in 1..<nx-1 {
                let w_grid = (x[i] * rx[j] / Lx) * v_wall /// скорость фронта плавления в узле
                let u_curr = u[j][i] - w_grid /// учет сеточной скорости в узле
                let v_curr = v[j][i]
                let T_conv = upwind2(phi: T, u_vel: u_curr, j: j, i: i, axisX: true) + upwind2(phi: T, u_vel: v_curr, j: j, i: i, axisX: false)
                
                // Явный шаг по времени для конвекции
                TNew[j][i] = T[j][i] - dt * T_conv
            }
        }
        // Diffuse ∂T/∂t += α∇²T
        if useParallelDiffuse {
            diffuseParallel(quantity: &TNew)
        } else {
            diffuse(quantity: &TNew) /// ⬅︎  α(T) учтено внутри
        }
        // явные граничные условия
        applyTemperatureBoundaryConditions(&TNew)
        // Обновление
        T = TNew
    }
}
