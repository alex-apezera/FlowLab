//
//  upwind2EPM.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 25.12.2025.
//
//MARK: - 2nd order Upwind circuit (LUD)

extension NavierStokesSolver {
    
    /// Схема Upwind 2-го порядка (LUD) для равномерной сетки с шагом h
    @inline(__always)
    func upwind2Epm(phi: ReadOnly, velocity: Double, _ j: Int, _ i: Int, _ idx: Int, _ nx: Int, _ nx_max: Int, _ ny_max: Int, _ inv2h: Double, axisX: Bool) -> Double {

        if axisX { /// Ось X (горизонтальное направление)
            if velocity > 0 { /// Поток слева направо: используем i, i-1, i-2
                let i_minus_2 = max(0, i - 2) /// Защита границ
                return velocity * (3.0 * phi[idx] - 4.0 * phi[idx-1] + phi[j*nx+i_minus_2]) * inv2h
            } else { /// Поток справа налево: используем i, i+1, i+2
                let i_plus_2 = min(nx_max, i + 2)
                return velocity * (-3.0 * phi[idx] + 4.0 * phi[idx+1] - phi[j*nx+i_plus_2]) * inv2h
            }
        } else { /// Ось Y (вертикальное направление)
            if velocity > 0 { /// Поток снизу вверх: используем j, j-1, j-2
                let j_minus_2 = max(0, j - 2)
                return velocity * (3.0 * phi[idx] - 4.0 * phi[idx-nx] + phi[j_minus_2*nx+i]) * inv2h
            } else { /// Поток сверху вниз: используем j, j+1, j+2
                let j_plus_2 = min(ny_max, j + 2)
                return velocity * (-3.0 * phi[idx] + 4.0 * phi[idx+nx] - phi[j_plus_2*nx+i]) * inv2h
            }
        }
    }

}
