//
//  epmDiffuse.swift
//  FlowLab
//
//  Created by Алексей Езерский on 04.05.2026.
//
//MARK: - Diffusion for 𝐕 and T (EPM)

import Foundation
extension NavierStokesSolver {
    
    /// Подготовка потоков для диффузионных членов  EPM.
    func epmDiffuse(quantity: inout [Double], isMomentum: Bool = false) {
        
        // ИЗВЛЕКАЕМ УКАЗАТЕЛИ (Pinning)
        quantity.withUnsafeMutableBufferPointer { quantity in
        liquidFraction.withUnsafeBufferPointer { liquidFraction in
        T.withUnsafeBufferPointer { T in
                    
            if useParallelDiffusion {
                DispatchQueue.concurrentPerform(iterations: workerCount) { wID in
                    let startY = 1 + (wID * (ny - 2) / workerCount)
                    let endY = 1 + ((wID + 1) * (ny - 2) / workerCount)
                    diffuseEpmX(startY: startY, endY: endY, quantity, liquidFraction, T, isMomentum: isMomentum)
                }
                
                DispatchQueue.concurrentPerform(iterations: workerCount) { wID in
                    let startX = 1 + (wID * (nx - 2) / workerCount)
                    let endX = 1 + ((wID + 1) * (nx - 2) / workerCount)
                    diffuseEpmY(startX: startX, endX: endX, quantity, liquidFraction, T, isMomentum: isMomentum)
                }
                
            } else {
                diffuseEpmX(startY: 1, endY: ny-1, quantity, liquidFraction, T, isMomentum: isMomentum)
                diffuseEpmY(startX: 1, endX: nx-1, quantity, liquidFraction, T, isMomentum: isMomentum)
            }
            
        }}}/// Ptr
    }
    
    /// Вычисление прогоночных коэффициентов для диффузионных членов  по оси X
    fileprivate func diffuseEpmX(startY: Int, endY: Int,_ quantity: Mutable, _ liquidFraction: ReadOnly, _ T: ReadOnly, isMomentum: Bool) {
        
        let h2 = h * h, dt_h2 = dt / h2
        let nx = self.nx
        let T_cold = self.T_cold, alpha_solid = self.alpha_solid
        
        var a = [Double](repeating: 0.0, count: nx)
        var b = [Double](repeating: 0.0, count: nx)
        var c = [Double](repeating: 0.0, count: nx)
        var d = [Double](repeating: 0.0, count: nx)
        var cP = [Double](repeating: 0.0, count: nx)
        var dP = [Double](repeating: 0.0, count: nx)
        var sol = [Double](repeating: 0.0, count: nx)
        
        for j in startY..<endY {
            let row = j * nx
            
            let jStart = Int(params.y_start * Double(ny))
            let jEnd = Int(params.y_end * Double(ny))
            let isTempAdiabat = !isMomentum && params.useWind && outlet(jStart, jEnd, j)
            
            for i in 0..<nx {
                let idx = row + i
                let quantity = quantity[idx]
                
                // ГРАНИЧНЫЕ УСЛОВИЯ, вертикальные стенки
                if i == 0 { /// левая стенка

                    /// для всех переменных
                    a[i] = 0.0; b[i] = 1.0
                    if isTempAdiabat {c[i] = -1.0; d[i] = 0.0}///вдув/сток
                    else { c[i] = 0.0; d[i] = quantity }

                } else if i == nx - 1 { /// правая стенка/граница
                    /// прилипание для скоростей
                    if isMomentum {
                        a[i] = 0.0; b[i] = 1.0; c[i] = 0.0; d[i] = 0.0
                    /// условия для температуры
                    } else if allowMelt && params.useNeiman { /// dT/dx = 0
                        a[i] = -1.0; b[i] = 1.0; c[i] = 0.0; d[i] = 0.0
                    } else { /// плавления нет или фронт коснулся стенки, T=T cold
                        a[i] = 0.0; b[i] = 1.0; c[i] = 0.0; d[i] = T_cold
                    }
                    
                // ВНУТРЕННИЕ ТОЧКИ
                } else {
                    let T = T[idx]
                    let f = liquidFraction[idx]
                    /// Определяем коэффициент температуропроводности с учётом фазы
                    let alpha_eff: Double
                    if isMomentum {
                        alpha_eff = nu(T)  // для momentum - вязкость
                    } else if f >= 1-dTm {
                        alpha_eff = alpha(T)  // жидкая фаза
                    } else if f <= dTm {
                        alpha_eff = alpha_solid   // чисто твёрдая фаза
                    } else {
                        // Кашица/пористая среда: линейная интерполяция
                        alpha_eff = alpha_solid + f * (alpha(T) - alpha_solid)
                    }

                    let diff_dt_h2 = /*f < dTm ? 0.0 :*/ alpha_eff * dt_h2

                    // Для всех фаз используем одинаковую трёхточечную схему
                    a[i] = -diff_dt_h2
                    c[i] = -diff_dt_h2
                    b[i] = 1.0 + 2.0 * diff_dt_h2
                    d[i] = quantity  // предыдущая температура
                }
            }
            thomasSolveInPlace(a, b, c, d, count: nx, solution: &sol, cPrime: &cP, dPrime: &dP)
            
            for i in 0..<nx { quantity[row+i] = sol[i] }///фиксация
        }
    }
    
    /// Вычисление прогоночных коэффициентов для диффузионных членов  по оси Y
    fileprivate func diffuseEpmY(startX: Int, endX: Int,_ quantity: Mutable, _ liquidFraction: ReadOnly, _ T: ReadOnly, isMomentum: Bool) {
        
        let h2 = h * h, dt_h2 = dt / h2
        let nx = self.nx, ny = self.ny
        let alpha_solid = self.alpha_solid
        let useWind = self.params.useWind
        
        var a = [Double](repeating: 0.0, count: ny)
        var b = [Double](repeating: 0.0, count: ny)
        var c = [Double](repeating: 0.0, count: ny)
        var d = [Double](repeating: 0.0, count: ny)
        var cP = [Double](repeating: 0.0, count: ny)
        var dP = [Double](repeating: 0.0, count: ny)
        var sol = [Double](repeating: 0.0, count: ny)
        
        for i in startX..<endX {
            // РАБОТА СО СТОЛБЦОМ
            for j in 0..<ny {
                let idx = j*nx + i
                let quantity = quantity[idx]
                
                // ГРАНИЧНЫЕ УСЛОВИЯ, горизонтальные стенки
                if j == 0 {
                    /// нижняя --  dT/dy = 0; u, v = 0; есть сток: du/dy, dv/dy = 0
                    a[j] = 0.0; b[j] = 1.0; c[j] = isMomentum && !useWind ? 0.0 : -1.0; d[j] = 0.0
                } else if j == ny-1 { ///верхняя -- аналогично нижней
                    a[j] = isMomentum && !useWind ? 0.0 : -1.0; b[j] = 1.0; c[j] = 0.0; d[j] = 0.0
                    
                // ВНУТРЕННИЕ ТОЧКИ
                } else {
                    let T = T[idx]
                    let f = liquidFraction[idx]
                    /// Определяем коэффициент температуропроводности с учётом фазы
                    let alpha_eff: Double
                    if isMomentum {
                        alpha_eff = nu(T)  // для momentum - вязкость
                    } else if f >= 1-dTm {
                        alpha_eff = alpha(T)  // жидкая фаза
                    } else if f <= dTm {
                        alpha_eff = alpha_solid   // чисто твёрдая фаза
                    } else {
                        // Кашица/пористая среда: линейная интерполяция
                        alpha_eff = alpha_solid + f * (alpha(T) - alpha_solid)
                    }

                    let diff_dt_h2 = /*f < dTm ? 0.0 :*/ alpha_eff * dt_h2

                    // Для всех фаз используем одинаковую трёхточечную схему
                    a[j] = -diff_dt_h2
                    c[j] = -diff_dt_h2
                    b[j] = 1.0 + 2.0 * diff_dt_h2
                    d[j] = quantity  // предыдущая температура
                }
            }
            
            thomasSolveInPlace(a, b, c, d, count: ny, solution: &sol, cPrime: &cP, dPrime: &dP)
            
            for j in 0..<ny { quantity[j*nx+i] = sol[j] }///фиксация
        }
    }

}
