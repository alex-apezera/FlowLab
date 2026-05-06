//
//  updatePhase.swift
//  FlowLab
//
//  Created by Алексей Езерский on 08.05.2026.
//
//MARK: - Update of temperature and phase composition during melting (EPM)

import Foundation
//import Combine
extension NavierStokesSolver {
    
    /// Обновление температуры и состава фазы при плавлении (EPM).
    /// Коррекция T и liquidFraction ж/(ж+тв) в зоне плавления
    func updatePhase(_ T: Mutable, _ fl: Mutable) {
        guard allowMelt else { return }
        
        let nx = self.nx, ny = self.ny, h = self.h
        let tMelt = T_melt, tCold = T_cold, tMax = T_max
        let lambda = self.lambda(tMelt), l_sol = self.lambda_solid
        let effectiveDt = adaptiveDtMelt * timeScale
        let energyFactor = effectiveDt / (latentHeat * rho_solid * h)
                
        let snapLimit = 0.95/// порог защелки  у правой стенки
        let wallZone = 1///количество ячеек до правой стенки, где риск NaN максимален

        // Проход по внутренним узлам
        for r in 1..<ny-1 {
            let row = r * nx

            for c in 1..<nx-1 {
                let idx = row + c
                
                /// Запрет на обновление фазы (запрет плавления) в "камнях"
                if isStone[idx] == 1 { continue }
                
                /// Если ячейка уже полностью расплавлена, фазу не обновляем
                let f_old = fl[idx]
                if f_old >= 1.0 { continue }
                
                /// Температура
                var temp = T[idx]
                
                /// Расчет теплового потока через границу плавления  [W/m²]
                let totalGain = useStephanScheme ?
                heatGainStePtr(r, c, h, lambda, l_sol, T: T, liquidFraction: fl) : 
                heatGainPtr(r, c, h, lambda, tMelt, T: T, liquidFraction: fl )
 
                /// Расчет приращения пористой фазы [1]
                var df = totalGain * energyFactor
                
                /// Если ГРФ близко к стенке, запрещаем f уменьшаться
                if c >= (nx - 1 - wallZone) { df = max(0.0, df) }
                
                /// Защита от выхода за пределы
                var f_new = (f_old + df).clamped(to: 0...1)
                
                // Логика "Твердых кусков"
                if f_old < dTm && getMaxNeighborF(r, c) < 0.05 && df > 0 { f_new = 0 }
                
                // В критической зоне у стенки — f - твердая
                if c >= (nx - 1 - wallZone) && f_new > 0.8 { f_new = 1.0 }
                else if f_new > snapLimit { f_new = 1.0 }
                
                // Корректор температуры
                let Cp_eff = Cp_solid * (1-f_new) + Cp * f_new
                temp -= latentHeat * Cp_eff * (f_new - f_old)
                
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
}
