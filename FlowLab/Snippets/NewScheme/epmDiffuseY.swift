//
//  epmDiffuseY.swift
//  FlowLab
//
//  Created by Алексей Езерский on 23.05.2026.
//

//MARK: - Диффузия по Y, New scheme
/*
import Foundation
import Combine
extension NavierStokesSolver {
    
    /// Применяется неявно к промежуточным массивам. Включает силу Буссинеска с опорной (T ref) для скоростей. Матрица тепла теперь неразрывна.
    func epmDiffuseY(quantity: inout [Double], isMomentum: Bool = false, prevFL: [Double]) {
        let nx = self.nx, ny = self.ny
        let dt_h2 = dt / (h * h)
        let dTm = self.dTm
        let lambda_sol = lambda_solid, Cp_liq = Cp, Cp_sol = Cp_solid
        let L = latentHeat

        var a = [Double](repeating: 0.0, count: ny)
        var b = [Double](repeating: 0.0, count: ny)
        var c = [Double](repeating: 0.0, count: ny)
        var d = [Double](repeating: 0.0, count: ny)
        
        var sol = [Double](repeating: 0.0, count: ny)
        var cP = [Double](repeating: 0.0, count: ny)
        var dP = [Double](repeating: 0.0, count: ny)
        
        for i in 1..<nx-1 {
            for j in 0..<ny {
                let idx = j * nx + i
                
                // ГРАНИЧНЫЕ УСЛОВИЯ, горизонтальные стенки
 
                if j == 0 { /// нижняя  (u, v = 0; dT/dy = 0)
                    a[j] = 0.0; b[j] = 1.0; c[j] = isMomentum ? 0.0 : -1.0; d[j] = 0.0
                } else if j == ny-1 { ///верхняя  (u, v = 0; dT/dy = 0)
                    a[j] = isMomentum ? 0.0 : -1.0; b[j] = 1.0; c[j] = 0.0; d[j] = 0.0

                // ====================================================
                // НИЖНЯЯ ГРАНИЦА (j == 0) — Честный адиабатический 2-й порядок
                // ====================================================
                if j == 0 {
                    a[j] = 0.0
                    c[j] = 0.0
                    
                    if isMomentum {
                        b[j] = 1.0
                        d[j] = 0.0 // Условие прилипания для скорости v=0
                    } else {
                        // ТЕПЛО: Вычисляем локальный коэффициент диффузии на нижней стенке
                        let lambda_liq = lambda(T[idx])
                        let f_curr = liquidFraction[idx]
                        let k_curr = f_curr * lambda_liq + (1.0 - f_curr) * lambda_sol
                        let Cp_eff = f_curr * Cp_liq + (1.0 - f_curr) * Cp_sol
                        let diff_coeff = (k_curr / (rho * Cp_eff)) * dt_h2
                        
                        a[j] = 0.0
                        b[j] = 1.0 + 2.0 * diff_coeff  // Самодиагональ
                        c[j] = -2.0 * diff_coeff        // Связь с верхним соседом j=1
                        
                        // В правую часть идет значение температуры, ПОЛУЧЕННОЕ ПОСЛЕ ШАГА КОНВЕКЦИИ!
                        d[j] = quantity[idx]
                    }

                // ====================================================
                // ВЕРХНЯЯ ГРАНИЦА (j == ny - 1) — Честный адиабатический 2-й порядок
                // ====================================================
                } else if j == ny - 1 {
                    c[j] = 0.0
                    
                    if isMomentum {
                        a[j] = 0.0
                        b[j] = 1.0
                        d[j] = 0.0 // Условие прилипания для скорости v=0
                    } else {
                        // ТЕПЛО: Вычисляем локальный коэффициент диффузии на верхней стенке
                        let lambda_liq = lambda(T[idx])
                        let f_curr = liquidFraction[idx]
                        let k_curr = f_curr * lambda_liq + (1.0 - f_curr) * lambda_sol
                        let Cp_eff = f_curr * Cp_liq + (1.0 - f_curr) * Cp_sol
                        let diff_coeff = (k_curr / (rho * Cp_eff)) * dt_h2
                        
                        a[j] = -2.0 * diff_coeff        // Связь с нижним соседом j=ny-2
                        b[j] = 1.0 + 2.0 * diff_coeff  // Самодиагональ
                        
                        // В правую часть идет значение температуры после шага конвекции
                        d[j] = quantity[idx]
                    }
                // ====================================================
                // НИЖНЯЯ ГРАНИЦА (j == 0) — Единый 1-й порядок (v=0 или dT/dy=0)
                // ====================================================
                if j == 0 {
                    a[j] = 0.0
                    b[j] = 1.0
                    c[j] = -1.0 // Прямая связь со следующим узлом
                    d[j] = 0.0  // Строгий ноль в правой части для обеих физических задач
                    
                // ====================================================
                // ВЕРХНЯЯ ГРАНИЦА (j == ny - 1) — Единый 1-й порядок (v=0 или dT/dy=0)
                // ====================================================
                } else if j == ny - 1 {
                    a[j] = -1.0 // Прямая связь с предыдущим узлом
                    b[j] = 1.0
                    c[j] = 0.0
                    d[j] = 0.0  // Строгий ноль в правой части
                    
                // ВНУТРЕННИЕ ТОЧКИ
                } else { /// Внутренние точки
                    let f_curr = liquidFraction[idx]
                    let T = T[idx]
                    let lambda_liq = lambda(T)

                    if isMomentum {
                        if f_curr < dTm {
                            a[j] = 0.0; b[j] = 1.0; c[j] = 0.0; d[j] = 0.0
                        } else {
                            let diff_dt_h2 = nu(T) * dt_h2
                            a[j] = -diff_dt_h2; c[j] = -diff_dt_h2
                            b[j] = 1.0 + 2.0 * diff_dt_h2
                            d[j] = quantity[idx]
                        }
                        
                    } else {
                        let k_curr = f_curr * lambda_liq + (1.0 - f_curr) * lambda_sol
                        let f_bottom = liquidFraction[idx - nx]
                        let f_top = liquidFraction[idx + nx]
                        
                        let k_bottom = f_bottom * lambda_liq + (1.0 - f_bottom) * lambda_sol
                        let k_top = f_top * lambda_liq + (1.0 - f_top) * lambda_sol
                        
                        let k_int_bottom = (2.0 * k_curr * k_bottom) / (k_curr + k_bottom + 1e-10)
                        let k_int_top = (2.0 * k_curr * k_top) / (k_curr + k_top + 1e-10)
                        
                        let Cp_eff = f_curr * Cp_liq + (1.0 - f_curr) * Cp_sol
                        let diff_bottom = (k_int_bottom / (rho * Cp_eff)) * dt_h2
                        let diff_top = (k_int_top / (rho * Cp_eff)) * dt_h2
                        
                        a[j] = -diff_bottom; c[j] = -diff_top
                        b[j] = 1.0 + diff_bottom + diff_top
                        
                        /// Расщепленный источник Воллера (вторая половина на Y)
                        let delta_fl = f_curr - prevFL[idx]
                        let sourceTerm = 0.5 * (L / Cp_eff) * delta_fl
                        
                        d[j] = quantity[idx] + sourceTerm
                    }
                }
            }
            thomasSolveInPlace(a, b, c, d, count: ny, solution: &sol, cPrime: &cP, dPrime: &dP)
            for j in 0..<ny { quantity[j * nx + i] = sol[j] }
        }
    }

}
*/
