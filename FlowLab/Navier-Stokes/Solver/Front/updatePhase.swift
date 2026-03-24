//
//  updatePhase.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 05.02.2026.
//
import Foundation
import Combine
extension NavierStokesSolver {
    
    // Коррекция T и liquidFraction ж/(ж+тв) в зоне плавления
    func updatePhaseChange() throws {
        guard allowMelt && useEnthalpyMethod else { return }
        let energyFactor = adaptiveDtMelt * timeScale / (latentHeat * rho * h)
        let L_Cp = latentHeat / Cp
        let relaxFactor = 0.25
        let localNX = nx, localNY = ny
        let tMelt = T_melt
        let tCold = T_cold
        let tMax = T_max

        // Порог защелки и критическая зона у правой стенки
        let snapLimit = 0.95
        let wallZone = 2 // Количество ячеек до правой стенки, где риск NaN максимален
        
        self.objectWillChange.send()
        
        // 1. PINNING: Пинним оба массива (для прямого обращения к памяти)
        T.withUnsafeMutableBufferPointer { tRows in
            let tPtrs = (0..<localNY).map { j in tRows[j].withUnsafeMutableBufferPointer { $0.baseAddress! } }

            liquidFraction.withUnsafeMutableBufferPointer { fRows in
                let fPtrs = fRows.baseAddress!
                
                // 2. СТРАЙДИНГ: реализация с использованием фиксированного шага (rowStep):
                let rowStep = 16
                let startY = 1
                let endY = ny - 1
                let totalRows = endY - startY
                let numChunks = (totalRows + rowStep - 1) / rowStep

                DispatchQueue.concurrentPerform(iterations: numChunks) { chunkIndex in
                    let chunkStart = startY + chunkIndex * rowStep
                    let chunkEnd = min(chunkStart + rowStep, endY)
                    
                    // Внутренний цикл по строкам чанка
                    for r in chunkStart..<chunkEnd {
                        let offset = r * localNX
                        // Внутренний цикл по X (Simd-friendly)
                        for c in 1..<localNX-1 {
                            let idx = offset + c
                            
                            let f_old = fPtrs[idx]
                            
                            /// Запрет на обновление фазы (запрет плавления) в "камнях"
                            if isStone[idx] == 1 { continue }
                            
                            /// Если ячейка уже полностью расплавлена, фазу не обновляем
                            if f_old >= 1.0 { continue }
                            
                            /// Стандартный расчет приращения пористой фазы f
                            let totalGain = calculateTotalHeatGain(r, c)
                            var df = totalGain * energyFactor
                            
                            /// Если ГРФ близко к стенке, запрещаем f уменьшаться
                            if c >= (localNX - 1 - wallZone) { df = max(0.0, df) }
                            
                            /// Защита от выхода за пределы
                            var f_new = (f_old + df).clamped(to: 0...1)
                            
                            // Логика "Твердых кусков"
                            if f_old < dTm && getMaxNeighborF(r, c) < 0.05 && df > 0 { f_new = 0 }
                            
                            /// Если мы в критической зоне у стенки — f - твердая
                            if c >= (localNX - 1 - wallZone) && f_new > 0.8 { f_new = 1.0 }
                            else if f_new > snapLimit { f_new = 1.0 }
                            
                            // Корректор температуры
                            let actualDf = relaxFactor * (f_new - f_old)
                            var temp = tPtrs[r][c]
                            temp -= L_Cp * actualDf
                            
                            // 3. ФИКСАЦИЯ ТЕМПЕРАТУРЫ И ЗАПИСЬ
                            if dTm < f_new && f_new < 1-dTm { temp = tMelt }
                            if f_new >= 1-dTm { temp = tCold }
                            
                            // Обновляем массив
                            tPtrs[r][c] = temp.clamped(to: tCold...tMax)
                            fPtrs[idx] = f_new
                            
                        }
                    }
                    
                    // Нейман на внерхней и нижней границах: df/dy = 0
                    for c in 0..<localNX {
                        fPtrs[idx(c, 0)] = fPtrs[idx(c, 1)]
                        fPtrs[idx(c, localNY-1)] = fPtrs[idx(c, localNY-2)]
                    }
                }
            }
        }
    }
    
    // Вспомогательная функция для логики "островов"
    func getMaxNeighborF(_ j: Int, _ i: Int) -> Double {
        return max(getF(j, i+1), getF(j, i-1), getF(j+1, i), getF(j-1, i))
    }
    
}
