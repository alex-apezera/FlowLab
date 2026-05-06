//
//  epmDiffusePar.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 14.01.2026.
//
/*
import Foundation
extension NavierStokesSolver {
    
    /// Вычисление прогоночных коэффициентов для диффузионных членов  EPM.
    func epmDiffusePar(quantity: inout [Double], isMomentum: Bool = false) {
//        let h2 = h * h, dt_h2 = dt / h2
//        let nx = self.nx, ny = self.ny
//        let T_cold = self.T_cold
        
        // ИЗВЛЕКАЕМ УКАЗАТЕЛИ (Pinning)
        quantity.withUnsafeMutableBufferPointer { quantity in
        liquidFraction.withUnsafeBufferPointer { liquidFraction in
        T.withUnsafeBufferPointer { T in
            
        // 1. X-направление
        DispatchQueue.concurrentPerform(iterations: workerCount) { wID in
            let startY = 1 + (wID * (ny - 2) / workerCount)
            let endY = 1 + ((wID + 1) * (ny - 2) / workerCount)
            
            diffuseEpmX(startY: startY, endY: endY, &quantity, liquidFraction, T, isMomentum: isMomentum)
            
/*            // СОЗДАЕМ БУФЕРЫ ОДИН РАЗ ДЛЯ ПОТОКА
            var a = [Double](repeating: 0.0, count: nx)
            var b = [Double](repeating: 0.0, count: nx)
            var c = [Double](repeating: 0.0, count: nx)
            var d = [Double](repeating: 0.0, count: nx)
            var cP = [Double](repeating: 0.0, count: nx)
            var dP = [Double](repeating: 0.0, count: nx)
            var sol = [Double](repeating: 0.0, count: nx)
            
            for j in startY..<endY {
                let row = j * nx
                
                for i in 0..<nx {
                    let idx = row + i
                    let quantity = quantity[idx]
                    let T = T[idx]
                    
                    // ГРАНИЧНЫЕ УСЛОВИЯ, вертикальные стенки
                    if i == 0 { /// левая стенка
                        a[i] = 0.0; b[i] = 1.0; c[i] = 0.0; d[i] = isMomentum ? 0.0 : T
                    } else if i == nx - 1 { /// правая стенка/граница
                        if isMomentum {
                            a[i] = 0.0; b[i] = 1.0; c[i] = 0.0; d[i] = 0.0
                        } else if allowMelt { /// dT/dx = 0
                            a[i] = -1.0; b[i] = 1.0; c[i] = 0.0; d[i] = 0.0
                        } else { /// плавления нет
                            a[i] = 0.0; b[i] = 1.0; c[i] = 0.0; d[i] = T_cold
                        }
                        
                    // ВНУТРЕННИЕ ТОЧКИ
                    } else {
                        let f = liquidFraction[idx]
                        if f < dTm { /// solid phase
                            a[i] = 0.0; b[i] = 1.0; c[i] = 0.0; d[i] = isMomentum ? 0.0 : hasLiquidNeighbor(r: j, c: i) ? T_melt : T_cold
                        } else { /// melt phase
                            let diff_dt_h2 = (isMomentum ? nu(T) :  alpha(T)) * dt_h2
                            
                            a[i] = -diff_dt_h2; c[i] = -diff_dt_h2
                            b[i] = 1.0 + 2.0 * diff_dt_h2
                            d[i] = quantity
                        }
                    }
                }
                thomasSolveInPlace(a, b, c, d, count: nx, solution: &sol, cPrime: &cP, dPrime: &dP)
                
                for i in 0..<nx { quantity[row+i] = sol[i] }///фиксация
            }*/
        }

        // 2. Y-направление
        DispatchQueue.concurrentPerform(iterations: workerCount) { wID in
            let startX = 1 + (wID * (nx - 2) / workerCount)
            let endX = 1 + ((wID + 1) * (nx - 2) / workerCount)
   
            diffuseEpmY(startX: startX, endX: endX, &quantity, liquidFraction, T, isMomentum: isMomentum)

            
/*            // СОЗДАЕМ БУФЕРЫ ОДИН РАЗ ДЛЯ ПОТОКА
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
                    
                    // ГРАНИЧНЫЕ УСЛОВИЯ, горизонтальные стенки
                    if j == 0 { /// нижняя  (u, v = 0; dT/dy = 0)
                        a[j] = 0.0; b[j] = 1.0; c[j] = isMomentum ? 0.0 : -1.0; d[j] = 0.0
                    } else if j == ny-1 { ///верхняя  (u, v = 0; dT/dy = 0)
                        a[j] = isMomentum ? 0.0 : -1.0; b[j] = 1.0; c[j] = 0.0; d[j] = 0.0
                        
                    // ВНУТРЕННИЕ ТОЧКИ
                    } else {
                        let T = T[idx]
                        let f = liquidFraction[idx]
                        if f < dTm { /// solid phase
                            a[j] = 0.0; b[j] = 1.0; c[j] = 0.0; d[j] = isMomentum ? 0.0 : hasLiquidNeighbor(r: j, c: i) ? T_melt : T_cold
                        } else { /// liquid phase
                            let diff_dt_h2 = (isMomentum ? nu(T) : alpha(T)) * dt_h2
                            
                            a[j] = -diff_dt_h2; c[j] = -diff_dt_h2
                            b[j] = 1.0 + 2.0 * diff_dt_h2
                            d[j] = quantity[idx]
                        }
                    }
                }
                
                thomasSolveInPlace(a, b, c, d, count: ny, solution: &sol, cPrime: &cP, dPrime: &dP)
                
                for j in 0..<ny { quantity[j*nx+i] = sol[j] }///фиксация
            }*/
        
        }}}}
    }
}
*/
