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
    func aleEnergy() {
        let nx = self.nx, ny = self.ny
        var TNew = T
        
        // Convection ∂T/∂t = -(u·∇)T
        for j in 1..<ny-1 {
            let row = j * nx

            /// Учёт скорости границы плавления
            let rowExpansionRatio = V_melt[j] * rx[j] / Lx

            for i in 1..<nx-1 {
                let idx = i + row
                
                /// Скорость узла [m/s]
                let w_grid = x[i] * rowExpansionRatio

                let uVal = u[idx] - w_grid /// учет сеточной скорости в узле
                let vVal = v[idx]
                let T_conv = upwind2(phi: T, velocity: uVal, j, i, idx, axisX: true, nx, ny) + upwind2(phi: T, velocity: vVal, j, i, idx, axisX: false, nx, ny)
                
                // Явный шаг по времени для конвекции
                TNew[idx] = T[idx] - dt * T_conv
            }
        }
        // Diffuse ∂T/∂t += α∇²T (⬅︎ α(T) учтено)
        if useConcurrence {
            aleDiffusePar(quantity: &TNew)
        } else {
            aleDiffuse(quantity: &TNew)
        }
        // явные граничные условия
        applyTemperatureBoundaryConditions(&TNew)
        // Обновление
        T = TNew
    }
}
