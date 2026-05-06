//
//  upwind2.swift
//  FlowLab
//
//  Created by Алексей Езерский on 03.05.2026.
//
//MARK: - 2nd order Upwind circuit (LUD)

extension NavierStokesSolver {
    
    /// Схема Upwind 2-го порядка (LUD) - равномерная/неравномерная сетка
    @inline(__always)
    func upwind2(phi: ReadOnly, velocity: Double, _ j: Int, _ i: Int, _ idx: Int, axisX: Bool, _ nx: Int, _ ny: Int, _ x: ReadOnly, _ y: ReadOnly) -> Double {
        
        /// Множители 0.5 и 2 взаимо сокращены - см встроенные комменты
        if axisX {
            if stretch_x == 0.0 { /// равномерная сетка по  X
                let dx_val = (x[i+1] - x[i-1]) * rx[j] /** 0.5*/ // средний шаг
                if velocity > 0 {  /// Поток слева направо: используем узлы i, i-1, i-2
                    let i_minus_2 = max(0, i - 2) /// Защита границ
                    return velocity * (3 * phi[idx] - 4 * phi[idx-1] + phi[j*nx+i_minus_2]) / (/*2 **/ dx_val)
                } else { /// Поток справа налево: используем узлы i, i+1, i+2
                    let i_plus_2 = min(nx-1, i + 2)
                    return velocity * (-3 * phi[idx] + 4 * phi[idx+1] - phi[j*nx+i_plus_2]) / (/*2 **/ dx_val)
                }
            } else { /// неравномерная сетка
                if velocity > 0 {  /// поток слева направо: используем узлы i, i-1, i-2
                    if i >= 2 {
                        let h1 = (x[i] - x[i-1]) * rx[j]
                        let h2 = (x[i-1] - x[i-2]) * rx[j]
                        let phi_i   = phi[idx]
                        let phi_im1 = phi[j*nx + (i-1)]
                        let phi_im2 = phi[j*nx + (i-2)]
                        let denom = h1 * (h1 + h2)
                        let term0 = (2*h1 + h2) / denom
                        let term1 = -(h1 + h2) / (h1 * h2)
                        let term2 = h1 / (h2 * (h1 + h2))
                        return velocity * (term0 * phi_i + term1 * phi_im1 + term2 * phi_im2)
                    } else if i > 0 { /// граница: первая порядок (backward)
                        let h = (x[i] - x[i-1]) * rx[j]
                        let phi_i = phi[idx]
                        let phi_im1 = phi[j*nx + (i-1)]
                        return velocity * ((phi_i - phi_im1) / h)
                    } else if i + 1 < nx { /// граница слева: используем forward
                        let h = (x[i+1] - x[i]) * rx[j]
                        let phi_i = phi[idx]
                        let phi_ip1 = phi[j*nx + (i+1)]
                        return velocity * ((phi_ip1 - phi_i) / h)
                    } else {
                        return 0.0
                    }
                } else { /// velocity <= 0: поток справа налево ->  узлы i, i+1, i+2
                    if i + 2 < nx {
                        let h1 = (x[i+1] - x[i]) * rx[j]
                        let h2 = (x[i+2] - x[i+1]) * rx[j]
                        let phi_i   = phi[idx]
                        let phi_ip1 = phi[j*nx + (i+1)]
                        let phi_ip2 = phi[j*nx + (i+2)]
                        let denom = h1 * (h1 + h2)
                        let term0 = -(2*h1 + h2) / denom
                        let term1 = (h1 + h2) / (h1 * h2)
                        let term2 = -h1 / (h2 * (h1 + h2))
                        return velocity * (term0 * phi_i + term1 * phi_ip1 + term2 * phi_ip2)
                    } else if i + 1 < nx {/// граница справа: первая порядок
                        let h = (x[i+1] - x[i]) * rx[j]
                        let phi_i = phi[idx]
                        let phi_ip1 = phi[j*nx + (i+1)]
                        return velocity * ((phi_ip1 - phi_i) / h)
                    } else if i > 0 {/// крайний правый: задействуем  шаг назад
                        let h = (x[i] - x[i-1]) * rx[j]
                        let phi_i = phi[idx]
                        let phi_im1 = phi[j*nx + (i-1)]
                        return velocity * ((phi_i - phi_im1) / h)
                    } else {
                        return 0.0
                    }
                }

            }
        } else {/// axisY
            if stretch_y == 0.0 { /// равномерная сетка по Y
                let dy_val = (y[j+1] - y[j-1]) /** 0.5*/
                if velocity > 0 {
                    let j_minus_2 = max(0, j - 2)
                    return velocity * (3 * phi[idx] - 4 * phi[idx-nx] + phi[j_minus_2*nx+i]) / (/*2 **/ dy_val)
                } else {
                    let j_plus_2 = min(ny-1, j + 2)
                    return velocity * (-3 * phi[idx] + 4 * phi[idx+nx] - phi[j_plus_2*nx+i]) / (/*2 **/ dy_val)
                }
            } else { /// неравномерная сетка
                if velocity > 0 {
                    if j >= 2 {
                        let h1 = y[j] - y[j-1]
                        let h2 = y[j-1] - y[j-2]
                        let phi_i  = phi[idx]
                        let phi_jm1 = phi[(j-1)*nx + i]
                        let phi_jm2 = phi[(j-2)*nx + i]
                        let denom = h1 * (h1 + h2)
                        let term0 = (2*h1 + h2) / denom
                        let term1 = -(h1 + h2) / (h1 * h2)
                        let term2 = h1 / (h2 * (h1 + h2))
                        return velocity * (term0 * phi_i + term1 * phi_jm1 + term2 * phi_jm2)
                    } else if j > 0 {
                        let h = y[j] - y[j-1]
                        let phi_i = phi[idx]
                        let phi_jm1 = phi[(j-1)*nx + i]
                        return velocity * ((phi_i - phi_jm1) / h)
                    } else if j + 1 < ny {
                        let h = y[j+1] - y[j]
                        let phi_i = phi[idx]
                        let phi_jp1 = phi[(j+1)*nx + i]
                        return velocity * ((phi_jp1 - phi_i) / h)
                    } else {
                        return 0.0
                    }
                } else { /// velocity <= 0
                    if j + 2 < ny {
                        let h1 = y[j+1] - y[j]
                        let h2 = y[j+2] - y[j+1]
                        let phi_i  = phi[idx]
                        let phi_jp1 = phi[(j+1)*nx + i]
                        let phi_jp2 = phi[(j+2)*nx + i]
                        let denom = h1 * (h1 + h2)
                        let term0 = -(2*h1 + h2) / denom
                        let term1 = (h1 + h2) / (h1 * h2)
                        let term2 = -h1 / (h2 * (h1 + h2))
                        return velocity * (term0 * phi_i + term1 * phi_jp1 + term2 * phi_jp2)
                    } else if j + 1 < ny {
                        let h = y[j+1] - y[j]
                        let phi_i = phi[idx]
                        let phi_jp1 = phi[(j+1)*nx + i]
                        return velocity * ((phi_jp1 - phi_i) / h)
                    } else if j > 0 {
                        let h = y[j] - y[j-1]
                        let phi_i = phi[idx]
                        let phi_jm1 = phi[(j-1)*nx + i]
                        return velocity * ((phi_i - phi_jm1) / h)
                    } else {
                        return 0.0
                    }
                }
            }
        }
    }

}
