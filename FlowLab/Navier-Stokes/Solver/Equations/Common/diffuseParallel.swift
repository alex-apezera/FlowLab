//
//  diffuseParallel.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 14.01.2026.
//
import Foundation
extension NavierStokesSolver {
    
    // Вычисление прогоночных коэффициентов для диффузионных членов уравнений (ALE + EPM)
    
    /// Применено Пиннинг и Страйдинг
    func diffuseParallel(quantity: inout [[Double]], isMomentum: Bool = false) {
        let h2 = h * h
        let dt_h2 = dt / h2
        let localNX = nx
        let localNY = ny
        let workerCount = ProcessInfo.processInfo.activeProcessorCount
        let chunkSize = (localNY - 2) / workerCount /// Группируем  внутренние строки

        // ИЗВЛЕКАЕМ УКАЗАТЕЛИ (Pinning)
        quantity.withUnsafeMutableBufferPointer { rowsPtr in
            
            // 1. X-направление
            DispatchQueue.concurrentPerform(iterations: workerCount) { workerIndex in
                // СОЗДАЕМ БУФЕРЫ ОДИН РАЗ ДЛЯ ПОТОКА
                var a = [Double](repeating: 0.0, count: localNX)
                var b = [Double](repeating: 0.0, count: localNX)
                var c = [Double](repeating: 0.0, count: localNX)
                var d = [Double](repeating: 0.0, count: localNX)
                var cP = [Double](repeating: 0.0, count: localNX)
                var dP = [Double](repeating: 0.0, count: localNX)
                var sol = [Double](repeating: 0.0, count: localNX)
                // Подготовка для Страйдинг
                let startJ = 1 + workerIndex * chunkSize
                let endJ = (workerIndex == workerCount - 1) ? (localNY - 1) : (startJ + chunkSize)
                
                for j in startJ..<endJ {
                    let offset = j * localNX
                    // Получаем доступ к строке напрямую
                    rowsPtr[j].withUnsafeMutableBufferPointer { rowPtr in
                                                
                        for i in 0..<localNX {
                            let idx = offset + i
                            // ГРАНИЧНЫЕ УСЛОВИЯ, вертикальные стенки
 
                            if i == 0 { /// левая стенка
                                a[i] = 0.0; b[i] = 1.0; c[i] = 0.0; d[i] = isMomentum ? 0.0 : T[j][0]

                            } else if i == localNX - 1 { /// правая стенка/граница
                                if isMomentum {
                                    a[i] = 0.0; b[i] = 1.0; c[i] = 0.0; d[i] = 0.0
                                } else if allowMelt && (useEnthalpyMethod || rx[j] >= Rx) { /// dT/dx = 0
                                    a[i] = -1.0; b[i] = 1.0; c[i] = 0.0; d[i] = 0.0
                                } else { /// плавления нет
                                    a[i] = 0.0; b[i] = 1.0; c[i] = 0.0; d[i] = T_cold
                                }
                                
                                // ВНУТРЕННИЕ ТОЧКИ
                            } else {
                                if useEnthalpyMethod { /// EPM, dx=dy=h
                                    // Коэф-ты для твердой фазы и жидкости
                                    let f = liquidFraction[idx]
                                    if f < dTm { /// solid phase
                                        a[i] = 0.0; b[i] = 1.0; c[i] = 0.0; d[i] = isMomentum ? 0.0 : hasLiquidNeighbor(r: j, c: i) ? T_melt : T_cold
                                    } else { /// melt phase
                                        let T_val = T[j][i]
                                        let diff_dt_h2 = (isMomentum ? nu(T_val) :  alpha(T_val)) * dt_h2
                                        
                                        a[i] = -diff_dt_h2; c[i] = -diff_dt_h2
                                        b[i] = 1.0 + 2.0 * diff_dt_h2
                                        d[i] = rowPtr[i]
                                    }
                                    
                                } else { ///ALE
                                    let dx_west = (x[i] - x[i-1]) * rx[j]
                                    let dx_east = (x[i+1] - x[i]) * rx[j]
                                    let dx_center = 0.5 * (dx_west + dx_east)
                                    let currentDiff = isMomentum ? nu(T[j][i]) : alpha(T[j][i])
                                    let diff_dt_current = currentDiff * dt
                                    let alpha_west = diff_dt_current / (dx_west * dx_center)
                                    let alpha_east = diff_dt_current / (dx_east * dx_center)
                                    
                                    a[i] = -alpha_west; c[i] = -alpha_east
                                    b[i] = 1.0 + alpha_west + alpha_east
                                    d[i] = rowPtr[i]
                                }
                            }
                        }
                        thomasSolveInPlace(a: a, b: b, c: c, d: d, count: localNX, solution: &sol, cPrime: &cP, dPrime: &dP)
                        
                        for i in 0..<localNX { rowPtr[i] = sol[i] }
                    }
                }
            }
                
            // 2. Y-направление
            // Заранее извлекаем указатели на все строки, чтобы не дергать rowsPtr[j] в цикле
            let rowPointers = (0..<localNY).map { j in
                rowsPtr[j].withUnsafeMutableBufferPointer { $0.baseAddress! }
            }
            let workerCount = ProcessInfo.processInfo.activeProcessorCount
            let chunkSizeI = (localNX - 2) / workerCount // Группируем внутренние столбцы

            DispatchQueue.concurrentPerform(iterations: workerCount) { workerIndex in
                // СОЗДАЕМ БУФЕРЫ ОДИН РАЗ ДЛЯ ПОТОКА
                var a = [Double](repeating: 0.0, count: localNY)
                var b = [Double](repeating: 0.0, count: localNY)
                var c = [Double](repeating: 0.0, count: localNY)
                var d = [Double](repeating: 0.0, count: localNY)
                var cP = [Double](repeating: 0.0, count: localNY)
                var dP = [Double](repeating: 0.0, count: localNY)
                var sol = [Double](repeating: 0.0, count: localNY)
                // Подготовка для Страйдинг
                let startI = 1 + workerIndex * chunkSizeI
                let endI = (workerIndex == workerCount - 1) ? (localNX - 1) : (startI + chunkSizeI)
                
                for i in startI..<endI {
                    // РАБОТА СО СТОЛБЦОМ
                    for j in 0..<localNY {
                        // ГРАНИЧНЫЕ УСЛОВИЯ, горизонтальные стенки
 
                        if j == 0 { /// нижняя стенка
                            a[j] = 0.0; b[j] = 1.0; c[j] = isMomentum ? 0.0 : -1.0; d[j] = 0.0 /// u, v = 0; dT/dy = 0
 
                        } else if j == localNY - 1 { ///верхняя стенка
                            a[j] = isMomentum ? 0.0 : -1.0; b[j] = 1.0; c[j] = 0.0; d[j] = 0.0 /// u, v = 0; dT/dy = 0

                            // ВНУТРЕННИЕ ТОЧКИ
                        } else {
                            if useEnthalpyMethod { /// EPM
                                // Коэф-ты для твердой фазы и жидкости
                                let f = liquidFraction[idx(i,j)]
                                if f < dTm { /// solid phase
                                    a[j] = 0.0; b[j] = 1.0; c[j] = 0.0; d[j] = isMomentum ? 0.0 : hasLiquidNeighbor(r: j, c: i) ? T_melt : T_cold
                                } else { /// liquid phase
                                    let T_val = T[j][i]
                                    let diff_dt_h2 = (isMomentum ? nu(T_val) : alpha(T_val)) * dt_h2

                                    a[j] = -diff_dt_h2; c[j] = -diff_dt_h2
                                    b[j] = 1.0 + 2.0 * diff_dt_h2
                                    d[j] = rowPointers[j][i]
                                }
                                
                            } else { ///ALE
                                let dy_south = y[j] - y[j-1]
                                let dy_north = y[j+1] - y[j]
                                let dy_center = 0.5 * (dy_south + dy_north)
                                let currentDiff = isMomentum ? nu(T[j][i]) : alpha(T[j][i])
                                let diff_dt_current = currentDiff * dt
                                let alpha_south = diff_dt_current / (dy_south * dy_center)
                                let alpha_north = diff_dt_current / (dy_north * dy_center)
                                
                                a[j] = -alpha_south; c[j] = -alpha_north
                                b[j] = 1.0 + alpha_south + alpha_north
                                d[j] = rowPointers[j][i]

                            }
                        }
                    }
                    
                    thomasSolveInPlace(a: a, b: b, c: c, d: d, count: localNY, solution: &sol, cPrime: &cP, dPrime: &dP)
                    
                    for j in 0..<localNY { rowPointers[j][i] = sol[j] }
                }
            }
        }
    }
}
