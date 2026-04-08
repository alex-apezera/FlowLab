//
//  diffuseParallel.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 14.01.2026.
//
import Foundation
extension NavierStokesSolver {
    
    /// Вычисление прогоночных коэффициентов для диффузионных членов   ALE
    func aleDiffusePar(quantity: inout [Double], isMomentum: Bool = false) {
        let nx = self.nx, ny = self.ny, workerCount = self.workerCount
        let dt = self.dt, Tc = self.T_cold
        
        // ИЗВЛЕКАЕМ УКАЗАТЕЛИ (Pinning)
        quantity.withUnsafeMutableBufferPointer { qPtr in
        T.withUnsafeBufferPointer { T in
                
            // 1. X-направление
            DispatchQueue.concurrentPerform(iterations: workerCount) { wID in
                let startY = 1 + (wID * (ny - 2) / workerCount)
                let endY = 1 + ((wID + 1) * (ny - 2) / workerCount)
 
                // СОЗДАЕМ БУФЕРЫ ОДИН РАЗ ДЛЯ ПОТОКА
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
                        
                        // ГРАНИЧНЫЕ УСЛОВИЯ, вертикальные стенки
                        if i == 0 { /// левая стенка
                            a[i] = 0.0; b[i] = 1.0; c[i] = 0.0;
                            d[i] = isMomentum ? 0.0 : T[idx]
                        } else if i == nx - 1 { /// правая стенка/граница
                            if isMomentum {
                                a[i] = 0; b[i] = 1; c[i] = 0; d[i] = 0
                            } else if allowMelt && rx[j] >= Rx { /// dT/dx = 0
                                a[i] = -1; b[i] = 1; c[i] = 0; d[i] = 0
                            } else { /// плавления нет
                                a[i] = 0; b[i] = 1; c[i] = 0; d[i] = Tc
                            }
                            
                            // ВНУТРЕННИЕ ТОЧКИ
                        } else {
                            let T = T[idx]
                            let dx_west = dx[i-1] * rx[j]
                            let dx_east = dx[i] * rx[j]
                            let dx_center = 0.5 * (dx_west + dx_east)
                            let currentDiff = isMomentum ? nu(T) : alpha(T)
                            let diff_dt_current = currentDiff * dt
                            let alpha_west = diff_dt_current / (dx_west * dx_center)
                            let alpha_east = diff_dt_current / (dx_east * dx_center)
                            
                            a[i] = -alpha_west; c[i] = -alpha_east
                            b[i] = 1.0 + alpha_west + alpha_east
                            d[i] = qPtr[idx]
                        }
                    }
                    thomasSolveInPlace(a: a, b: b, c: c, d: d, count: nx, solution: &sol, cPrime: &cP, dPrime: &dP)
                    
                    for i in 0..<nx { qPtr[row+i] = sol[i] }///фиксация
                }
            }
            
            // 2. Y-направление
            DispatchQueue.concurrentPerform(iterations: workerCount) { wID in
                let startX = 1 + (wID * (nx - 2) / workerCount)
                let endX = 1 + ((wID + 1) * (nx - 2) / workerCount)

                // СОЗДАЕМ БУФЕРЫ ОДИН РАЗ ДЛЯ ПОТОКА
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
                            let dy_south = dy[j-1]
                            let dy_north = dy[j]
                            let dy_center = 0.5 * (dy_south + dy_north)
                            let currentDiff = isMomentum ? nu(T) : alpha(T)
                            let diff_dt_current = currentDiff * dt
                            let alpha_south = diff_dt_current / (dy_south * dy_center)
                            let alpha_north = diff_dt_current / (dy_north * dy_center)
                            
                            a[j] = -alpha_south; c[j] = -alpha_north
                            b[j] = 1.0 + alpha_south + alpha_north
                            d[j] = qPtr[idx]
                        }
                    }
                    
                    thomasSolveInPlace(a: a, b: b, c: c, d: d, count: ny, solution: &sol, cPrime: &cP, dPrime: &dP)
                    
                    for j in 0..<ny { qPtr[j*nx+i] = sol[j] }///фиксация
                }
            }
        }}
    }
}
