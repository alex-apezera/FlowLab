//
//  updatePhaseSnippet.swift
//  FlowLab
//
//  Created by Алексей Езерский on 16.05.2026.
//
/*
//MARK: - Обновление температуры и состава фазы при плавлении (EPM)
//MARK: Using concurrentPerform
import Foundation
import Combine
extension NavierStokesSolver {
    
    /// Коррекция T и liquidFraction ж/(ж+тв) в зоне плавления
    func updatePhaseSnip() {
        guard allowMelt else { return }
        
        let nx = self.nx, ny = self.ny, h = self.h
        let workerCount = self.workerCount
        let effectiveDt = adaptiveDtMelt * timeScale
        let tvd = TVDScheme(h: h)
        let energyFactor = effectiveDt / (latentHeat * rho * h)
        let L_Cp = latentHeat / Cp
        let rho_Cp = rho * Cp
        let effectiveDtFactor = effectiveDt / L_Cp
        let relaxFactor = 1.0
        let tMelt = T_melt, tCold = T_cold, tMax = T_max
        let lambda = self.lambda(tMelt), h2_inv = 1 / (h*h)
        let factor = params.useGradientCorrection ? effectiveDtFactor : energyFactor
        
        let snapLimit = 0.95///порог защелки  у правой стенки
        let wallZone = 2///количество ячеек до правой стенки, где риск NaN максимален
        
        // Пинним массивы для прямого обращения к памяти
        T.withUnsafeMutableBufferPointer { T in
        liquidFraction.withUnsafeMutableBufferPointer { fl in
        u.withUnsafeBufferPointer { u in
        v.withUnsafeBufferPointer { v in
                                                    
            DispatchQueue.concurrentPerform(iterations: workerCount) { wID in
                let startY = 1 + (wID * (ny - 2) / workerCount)
                let endY = 1 + ((wID + 1) * (ny - 2) / workerCount)

                // Внутренний цикл по строкам чанка
                for r in startY..<endY {
                    let row = r * nx
                    // Внутренний цикл по X (Simd-friendly)
                    for c in 1..<nx-1 {
                        let idx = row + c
                        
                        /// Запрет на обновление фазы (запрет плавления) в "камнях"
                        if isStone[idx] == 1 { continue }
                        
                        /// Если ячейка уже полностью расплавлена, фазу не обновляем
                        let f_old = fl[idx]
                        if f_old >= 1.0 { continue }
                        
                        /// Температура
                        var temp = T[idx]
                        
                        /// Расчет приращения пористой фазы
                        var totalGain: Double
                        if params.useGradientCorrection {/// Г2 коррекция

                            /// Диффузия
                            let laplacianT = (getT(r, c+1) + getT(r, c-1) + getT(r+1, c) + getT(r-1, c) - 4 * temp) * h2_inv

                            /// Конвекция через TVD структуру
                            let cX = tvd.getAdvection(u: u[idx], fM2: getF(r, c-2), fM1: getF(r, c-1), f0: getF(r, c), fP1: getF(r, c+1), fP2: getF(r, c+2))
                            let cY = tvd.getAdvection(u: v[idx], fM2: getF(r-2, c), fM1: getF(r-1, c), f0: getF(r, c), fP1: getF(r+1, c), fP2: getF(r+2, c))

                            totalGain = lambda * laplacianT - (cX + cY)

                        } else { /// стандартный расчет
                            totalGain = heatGainPtr(r, c, h, lambda, rho_Cp, u, v, T: T, liquidFraction: fl )
                        }
                        
                        var df = totalGain * factor
                        
                        /// Если ГРФ близко к стенке, запрещаем f уменьшаться
                        if c >= (nx - 1 - wallZone) { df = max(0.0, df) }
                        
                        /// Защита от выхода за пределы
                        var f_new = (f_old + df).clamped(to: 0...1)
                        
                        // Логика "Твердых кусков"
                        if f_old < dTm && getMaxNeighborF(r, c) < 0.05 && df > 0 { f_new = 0 }
                        
                        /// Если мы в критической зоне у стенки — f - твердая
                        if c >= (nx - 1 - wallZone) && f_new > 0.8 { f_new = 1.0 }
                        else if f_new > snapLimit { f_new = 1.0 }
                        
                        // Корректор температуры
                        let actualDf = relaxFactor * (f_new - f_old)
                        temp -= L_Cp * actualDf
                        
                        // ФИКСАЦИЯ ТЕМПЕРАТУРЫ И ЗАПИСЬ
                        if dTm < f_new && f_new < 1-dTm { temp = tMelt }
                        if f_new >= 1-dTm { temp = tCold }
                        
                        T[idx] = temp.clamped(to: tCold...tMax)
                        fl[idx] = f_new
                    }
                }
                
                // Нейман на внерхней и нижней границах: df/dy = 0
                for c in 0..<nx {
                    fl[idx(c, 0)] = fl[idx(c, 1)]
                    fl[idx(c, ny-1)] = fl[idx(c, ny-2)]
                }
            }
        }}}}
    }
}
*/
