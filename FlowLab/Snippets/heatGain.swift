//
//  heatGain.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 09.02.2026.
//
// MARK: - Совокупный прирост теплового потока
/*
extension NavierStokesSolver {
    
    /// Диффузионный  прирост теплового потока [W/m²], 1й порядок точности
    @inline(__always)
    func heatGain(_ r: Int, _ c: Int, _ dx: Double, _ lambda: Double, _ T_melt: Double, T: [Double], liquidFraction: [Double]) -> Double {
        
        // Проверяем 4 грани ячейки
        let neighbors = [(r, c+1), (r, c-1), (r+1, c), (r-1, c)]
        
        var totalHeatGain = 0.0
        for (nr, nc) in neighbors {
            if liquidFraction[idx(nc,nr)] > 0.5 {
                let localT = T[idx(nc,nr)]
                let deltaT = max(0, localT - T_melt)
                
                /// Диффузионный вклад (Теплопроводность)  [W/m²]
                let q_diff = lambda * (deltaT / dx)
                                
                totalHeatGain += q_diff
            }
        }
        return totalHeatGain /// [W/m²] суммарный баланс диффузии для ячейки
    }

    /// Диффузионный  прирост теплового потока [W/m²], схема Стефана
    @inline(__always)
    func heatGainSte(_ r: Int, _ c: Int, _ dx: Double, _ k_liq: Double, _ k_sol: Double, T: [Double], liquidFraction: [Double]) -> Double {
        let currentIdx = idx(c, r)
        let T_current = T[currentIdx]
        let fl_current = liquidFraction[currentIdx]
        
        // Эффективная теплопроводность текущей ячейки
        let k_current = fl_current * k_liq + (1.0 - fl_current) * k_sol
        
        let neighbors = [(r, c+1), (r, c-1), (r+1, c), (r-1, c)]
        var totalHeatGain = 0.0
        
        for (nr, nc) in neighbors {
            let nIdx = idx(nc, nr)
            let T_neighbor = T[nIdx]
            let fl_neighbor = liquidFraction[nIdx]
            
            // Эффективная теплопроводность соседней ячейки
            let k_neighbor = fl_neighbor * k_liq + (1.0 - fl_neighbor) * k_sol
            
            // Гармоническое среднее для границы между ячейками (классический подход СВМ/FVM)
            let k_interface = (2.0 * k_current * k_neighbor) / (k_current + k_neighbor + tiny)
            
            // Поток через грань (направленный внутрь текущей ячейки)
            let q_face = k_interface * (T_neighbor - T_current) / dx
            
            totalHeatGain += q_face
        }
        
        return totalHeatGain // [W/m²] суммарный баланс диффузии для ячейки
    }

}
*/
