//
//  correctionTempAndLF.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 05.01.2026.
//
//MARK: - Calculate conditions on the melting front (EPM)

import Foundation
extension NavierStokesSolver {
    
    /// Градиентная коррекция Т второго порядка(Здесь используется fl old!)
    /// Используем workerCount (Striding) + Pinning (pointers)
    func correctionTempAndLF() throws {
        guard allowMelt else { return }
        
        let effectiveDt = adaptiveDtMelt * timeScale
        let tvd = TVDScheme(h: h)
        let localNX = nx, localNY = ny
        let L_Cp = latentHeat / Cp
        let h2_inv = 1 / h*h
        let relaxFactor = 0.25
        let effectiveDtFactor = effectiveDt / L_Cp
        
        // 1. PINNING: Пинним оба массива (для прямого обращения к памяти)
        T.withUnsafeMutableBufferPointer { tRows in
            let tPtrs = (0..<localNY).map { j in tRows[j].withUnsafeMutableBufferPointer { $0.baseAddress! } }

            liquidFraction.withUnsafeMutableBufferPointer { fRows in
                let fPtrs = fRows.baseAddress!
                
                // 2. СТРАЙДИНГ: Определяем размер блока строк для одного потока
                let workerCount = ProcessInfo.processInfo.activeProcessorCount
                let chunkSize = (localNY - 2) / workerCount
 
                // 3. ПАРАЛЛЕЛЬНЫЙ ЦИКЛ (GCD)
                DispatchQueue.concurrentPerform(iterations: workerCount) { wIdx in
                    let startJ = 1 + wIdx * chunkSize
                    let endJ = (wIdx == workerCount - 1) ? (localNY - 1) : (startJ + chunkSize)
                    
                    // Коррекция T и liquidFraction ж/(ж+тв) в зоне плавления
                    for j in startJ..<endJ {
                        let offset = j * localNX
                        // Внутренний цикл по X (Simd-friendly)
                        for i in 1..<localNX-1 {
                            let idx = offset + i
                            
                            let fl_old = fPtrs[idx]
                            let temp = T[j][i]
/*
                            if dTm < f && f < cf { /// зона плавления
                                // Расчет градиентов через tPtrs и fPtrs
                                let df_dx = (fPtrs[j][i+1] - fPtrs[j][i-1]) * inv2h
                                let df_dy = (fPtrs[j+1][i] - fPtrs[j-1][i]) * inv2h
                                let mag = sqrt(df_dx * df_dx + df_dy * df_dy) + 1e-10
                                
                                let dT_dx = (tPtrs[j][i+1] - tPtrs[j][i-1]) * inv2h
                                let dT_dy = (tPtrs[j+1][i] - tPtrs[j-1][i]) * inv2h
                                let dTdN = (dT_dx * df_dx / mag) + (dT_dy * df_dy / mag)
                                
                                // Пример коррекции (гибридная схема)
                                let df_corrected = (f - fl_old[j][i]) * (1 + abs(dTdN) * h)
 */
                            // Диффузия
                            let laplacianT = (getT(j, i+1) + getT(j, i-1) + getT(j+1, i) + getT(j-1, i) - 4 * temp) * h2_inv

                            // Конвекция через TVD структуру
                            let cX = tvd.getAdvection(u: u[j][i], fM2: getF(j, i-2), fM1: getF(j, i-1), f0: getF(j, i), fP1: getF(j, i+1), fP2: getF(j, i+2))
                            let cY = tvd.getAdvection(u: v[j][i], fM2: getF(j-2, i), fM1: getF(j-1, i), f0: getF(j, i), fP1: getF(j+1, i), fP2: getF(j+2, i))
                            
                            // Предиктор
                            let df = (alpha(temp) * laplacianT - (cX + cY)) * effectiveDtFactor
                            
                            // Логика "Твердых кусков"
                            var newFl = (fl_old + df).clamped(to: 0...1)
                            if fl_old < 0.01 && getMaxNeighborF(j, i) < 0.05 && df > 0 {
                                newFl = 0
                            }
                            // Прямая запись по указателям
                            fPtrs[idx] = newFl

                            // Корректор температуры
                            let actualDf = relaxFactor * (newFl - fl_old)
                            tPtrs[j][i] -= L_Cp * actualDf
                            
                            if dTm < newFl && newFl < 1-dTm { tPtrs[j][i] = T_melt }
                            if newFl >= 1-dTm { tPtrs[j][i] = T_cold }
                        }
                    }
                    // Нейман на внерхней и нижней границах
                    for c in 0..<localNX {
                        fPtrs[idx(c, 0)] = fPtrs[idx(c, 1)]
                        fPtrs[idx(c, localNY-1)] = fPtrs[idx(c, localNY-2)]
                    }
                }
            }
        }
    }
}

