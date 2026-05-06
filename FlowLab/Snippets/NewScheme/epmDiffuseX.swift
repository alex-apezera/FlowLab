//
//  epmDiffuseX.swift
//  FlowLab
//
//  Created by Алексей Езерский on 23.05.2026.
//

//MARK: - Диффузия по X, New scheme
/*
import Foundation
import Combine
extension NavierStokesSolver {
    
    /// Применяется неявно к промежуточным массивам. Включает силу Буссинеска с опорной (T ref) для скоростей. Матрица тепла теперь неразрывна.
    func epmDiffuseX(quantity: inout [Double], isMomentum: Bool = false, prevFL: [Double]) {
        let nx = self.nx, ny = self.ny
        let dt = self.dt, dt_h2 = dt / (h * h)
        let T_hot = T_max, dTm = self.dTm
        let lambda_sol = lambda_solid, Cp_liq = Cp, Cp_sol = Cp_solid
        let L = latentHeat
        
        var a = [Double](repeating: 0.0, count: nx)
        var b = [Double](repeating: 0.0, count: nx)
        var c = [Double](repeating: 0.0, count: nx)
        var d = [Double](repeating: 0.0, count: nx)
        
        var sol = [Double](repeating: 0.0, count: nx)
        var cP = [Double](repeating: 0.0, count: nx)
        var dP = [Double](repeating: 0.0, count: nx)
        
        for j in 1..<ny-1 {
            let row = j * nx
            for i in 0..<nx {
                let idx = row + i

                // ГРАНИЧНЫЕ УСЛОВИЯ, вертикальные стенки
                if i == 0 { /// Левая граница
                    a[i] = 0.0; c[i] = 0.0; b[i] = 1.0
                    d[i] = isMomentum ? 0.0 : T_hot
                } else if i == nx - 1 { /// Правая граница
                    b[i] = 1.0; c[i] = 0.0
                    if isMomentum { /// для скорости
                        a[i] = 0.0; d[i] = 0.0
                    } else { /// для температуры
                        a[i] = -1.0; d[i] = 0.0 /// dT/dx = 0
                    }
                // ВНУТРЕННИЕ ТОЧКИ
                } else {
                    let f_curr = liquidFraction[idx]
                    let T = T[idx]
                    let lambda_liq = lambda(T)

                    if isMomentum { /// коэффициенты для  скорости
                        if f_curr < dTm { /// solid phase
                            a[i] = 0.0; b[i] = 1.0; c[i] = 0.0; d[i] = 0.0
                        } else {
                            let diff_dt_h2 = nu(T) * dt_h2
                            a[i] = -diff_dt_h2; c[i] = -diff_dt_h2
                            b[i] = 1.0 + 2.0 * diff_dt_h2
                            d[i] = quantity[idx]
                        }
                        
                    } else { /// коэффициенты для температуры
                        let k_curr = f_curr * lambda_liq + (1.0 - f_curr) * lambda_sol
                        let f_left = liquidFraction[idx - 1]
                        let f_right = liquidFraction[idx + 1]
                        
                        let k_left = f_left * lambda_liq + (1.0 - f_left) * lambda_sol
                        let k_right = f_right * lambda_liq + (1.0 - f_right) * lambda_sol
                        
                        let k_int_left = (2.0 * k_curr * k_left) / (k_curr + k_left + tiny)
                        let k_int_right = (2.0 * k_curr * k_right) / (k_curr + k_right + tiny)
                        
                        let Cp_eff = f_curr * Cp_liq + (1.0 - f_curr) * Cp_sol
                        let diff_left = (k_int_left / (rho * Cp_eff)) * dt_h2
                        let diff_right = (k_int_right / (rho * Cp_eff)) * dt_h2
                        
                        a[i] = -diff_left; c[i] = -diff_right
                        b[i] = 1.0 + diff_left + diff_right
                        
                        /// Расщепленный источник Воллера (половина на X)
                        let delta_fl = f_curr - prevFL[idx]
                        let sourceTerm = 0.5 * (L / Cp_eff) * delta_fl
                        
                        d[i] = quantity[idx] + sourceTerm
                    }
                }
            }
            thomasSolveInPlace(a, b, c, d, count: nx, solution: &sol, cPrime: &cP, dPrime: &dP)
            for i in 0..<nx { quantity[row + i] = sol[i] }
        }
    }

}
*/
