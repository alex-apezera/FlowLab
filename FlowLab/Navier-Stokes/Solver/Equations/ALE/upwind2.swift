//
//  upwind2.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 19.12.2025.
//

extension NavierStokesSolver {
    
    /// Схема Upwind 2-го порядка (LUD) - неравномерная сеткка
    @inline(__always)
    func upwind2(phi: [[Double]], u_vel: Double, j: Int, i: Int, axisX: Bool) -> Double {
        let nx_max = nx - 1
        let ny_max = ny - 1
        /// Множители 0.5 и 2 взаимо сокращены
        if axisX {
            let dx_val = (x[i+1] - x[i-1]) * rx[j] /** 0.5*/ // средний шаг
            if u_vel > 0 {
                /// Поток слева направо: используем узлы i, i-1, i-2
                let i_minus_2 = max(0, i - 2)
                    return u_vel * (3 * phi[j][i] - 4 * phi[j][i-1] + phi[j][i_minus_2]) / (/*2 **/ dx_val)
            } else {
                /// Поток справа налево: используем узлы i, i+1, i+2
                let i_plus_2 = min(nx_max, i + 2)
                return u_vel * (-3 * phi[j][i] + 4 * phi[j][i+1] - phi[j][i_plus_2]) / (/*2 **/ dx_val)
            }
        } else {/// axisY
            let dy_val = (y[j+1] - y[j-1]) /** 0.5*/
            if u_vel > 0 {
                let j_minus_2 = max(0, j - 2)
                return u_vel * (3 * phi[j][i] - 4 * phi[j-1][i] + phi[j_minus_2][i]) / (/*2 **/ dy_val)
            } else {
                let j_plus_2 = min(ny_max, j + 2)
                return u_vel * (-3 * phi[j][i] + 4 * phi[j+1][i] - phi[j_plus_2][i]) / (/*2 **/ dy_val)
            }
        }
    }

}
