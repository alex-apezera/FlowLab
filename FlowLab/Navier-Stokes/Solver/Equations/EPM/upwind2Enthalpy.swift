//
//  upwind2Enthalpy.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 25.12.2025.
//

extension NavierStokesSolver {
    
    /// Схема Upwind 2-го порядка (LUD) для равномерной сетки с шагом h
    @inline(__always)
    func upwind2Enthalpy(phi: [[Double]], velocity: Double, j: Int, i: Int, axisX: Bool) -> Double {
        let nx_max = nx - 1
        let ny_max = ny - 1
        
        // Знаменатель 2 * h для схемы 2-го порядка
        let half_h = 0.5 /  h

        if axisX {
            if velocity > 0 {
                /// Поток слева направо: используем i, i-1, i-2
                let i_m2 = i > 1 ? i - 2 : 0 // Защита границ
                return velocity * (3.0 * phi[j][i] - 4.0 * phi[j][i-1] + phi[j][i_m2]) * half_h
            } else {
                /// Поток справа налево: используем i, i+1, i+2
                let i_p2 = i < nx_max - 1 ? i + 2 : nx_max
                return velocity * (-3.0 * phi[j][i] + 4.0 * phi[j][i+1] - phi[j][i_p2]) * half_h
            }
        } else {
            /// Ось Y (вертикальное направление)
            if velocity > 0 {
                /// Поток снизу вверх (v > 0): используем j, j-1, j-2
                let j_m2 = j > 1 ? j - 2 : 0
                return velocity * (3.0 * phi[j][i] - 4.0 * phi[j-1][i] + phi[j_m2][i]) * half_h
            } else {
                /// Поток сверху вниз: используем j, j+1, j+2
                let j_p2 = j < ny_max - 1 ? j + 2 : ny_max
                return velocity * (-3.0 * phi[j][i] + 4.0 * phi[j+1][i] - phi[j_p2][i]) * half_h
            }
        }
    }

}
