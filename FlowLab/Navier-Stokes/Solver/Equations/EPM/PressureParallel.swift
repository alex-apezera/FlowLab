//
//  SolvePressureEnthalpyParallel.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 14.01.2026.
//

import Foundation
extension NavierStokesSolver {
        
    func solvePressureEnthalpyParallel(_ uNew: [[Double]], _ vNew: [[Double]]) throws {
        let relax = params.relaxationFactor
        let h2_rho_dt = (h * h) * (rho / dt)
        let divergence = calculateDivergence(uStar: uNew, vStar: vNew)
        let localNX = nx
        let localNY = ny
        let workerCount = ProcessInfo.processInfo.activeProcessorCount
        // Группируем строки (по 2 минимум для Red-Black)
        let chunkSize = ((localNY - 2) / workerCount)
        getSolidMask()
        
        p.withUnsafeMutableBufferPointer { rowsPtr in
            let rowPointers = rowsPtr.baseAddress!
            let divPointers = (0..<localNY).map { j in divergence[j].withUnsafeBufferPointer { $0.baseAddress! } }
            solidMask.withUnsafeBufferPointer { maskPtr in
                let m = maskPtr.baseAddress!

                // Итерации по давлению в шахматном порядке
                var iteration = 0
                repeat {
                    var threadMaxDiffs = [Double](repeating: 0.0, count: workerCount)
                    
                    for color in 0...1 {
                        
                        // Striding - параллельные вычисления
                        DispatchQueue.concurrentPerform(iterations: workerCount) { wIdx in
                            let startJ = 1 + wIdx * chunkSize
                            let endJ = (wIdx == workerCount - 1) ? (localNY - 1) : (startJ + chunkSize)
                            
                            var localMax = 0.0
                            
                            for j in startJ..<endJ {
                                let offset = j * localNX
                                let rowDiv = divPointers[j]
                                
                                /// Определяем начальное i в зависимости от j и текущего цвета
                                /// (i + j) % 2 == color  =>  i = color - j (по модулю 2)
                                let startI = 1 + ((color + 2 - (1 + j % 2)) % 2)
                                
                                /// Использование stride убирает проверку "if % 2" внутри цикла
                                for i in stride(from: startI, to: localNX - 1, by: 2) {
                                    let idx = offset + i
                                                                        
                                    if m[idx] == 1 { rowPointers[idx] = 0; continue }
                                    
                                    let p_old = rowPointers[idx]
                                    let left  = idx - 1
                                    let right = idx + 1
                                    let up    = idx - localNX
                                    let down  = idx + localNX

// Соседи: если m[neighbor] == 1, берем p_old (условие dp/dn = 0)
                                    let pL = (m[left] == 1) ? p_old : rowPointers[left]
                                    let pR = (m[right] == 1) ? p_old : rowPointers[right]
                                    let pT = (m[up] == 1) ? p_old : rowPointers[up]
                                    let pB = (m[down] == 1) ? p_old : rowPointers[down]

                                    let p_neighbors = pL + pR + pT + pB
                                    
                                    /// Стабилизация
                                    let p_stab = 0.02 * (p_neighbors - 4.0 * p_old)
                                    
                                    let newValue = 0.25 * (p_neighbors - h2_rho_dt * rowDiv[i]) + p_stab
                                    let relaxedValue = newValue * relax + p_old * (1.0 - relax)
                                    
                                    rowPointers[idx] = relaxedValue
                                    
                                    let diff = abs(relaxedValue - p_old)
                                    if diff > localMax { localMax = diff }
                                    
                                }
                            }
                            threadMaxDiffs[wIdx] = max(threadMaxDiffs[wIdx], localMax)
                        }
                    }
                    
                    applyPressureBoundaryConditionsInline(rowPointers: rowPointers, nx: localNX, ny: localNY)
                    maxPressureResidual = threadMaxDiffs.max() ?? 0.0
                    iteration += 1
                    
                } while maxPressureResidual > params.criticalError && iteration < params.maxIterations
                
                iterations = iteration
            }
        }
        
        correctVelocities(uNew, vNew)
        applyVelocityBoundaryConditions(&u, &v)
    }
         
}
