//
//  heatGainPtr.swift
//  FlowLab
//
//  Created by Алексей Езерский on 08.05.2026.
//
//MARK: - Diffusion increase in heat flux on melting front

extension NavierStokesSolver {
    
    /// Диффузионный  прирост теплового потока [W/m²], 1й порядок точности
    @inline(__always)
    func heatGainPtr(_ r: Int, _ c: Int, _ dx: Double, _ lambda: Double, _ T_melt: Double, T: Mutable, liquidFraction: Mutable) -> Double {
        
        /// Проверяем 4 грани ячейки
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
    
    /// Диффузионный  прирост теплового потока [W/m²], схема Стефана.
    /// Требует доработки.
    @inline(__always)
    func heatGainStePtr(_ r: Int, _ c: Int, _ dx: Double, _ k_liq: Double, _ k_sol: Double, T: Mutable, liquidFraction: Mutable) -> Double {
        let currentIdx = idx(c, r)
        let T_current = T[currentIdx]
        let fl_current = liquidFraction[currentIdx]
        
        /// Эффективная теплопроводность текущей ячейки
        let k_current = fl_current * k_liq + (1.0 - fl_current) * k_sol
        
        let neighbors = [(r, c+1), (r, c-1), (r+1, c), (r-1, c)]
        var totalHeatGain = 0.0
        
        for (nr, nc) in neighbors {
            let nIdx = idx(nc, nr)
            let T_neighbor = T[nIdx]
            let fl_neighbor = liquidFraction[nIdx]
            
            /// Эффективная теплопроводность соседней ячейки
            let k_neighbor = fl_neighbor * k_liq + (1.0 - fl_neighbor) * k_sol
            
            /// Гармоническое среднее для границы между ячейками (СВМ/FVM)
            let k_interface = (2.0 * k_current * k_neighbor) / (k_current + k_neighbor + tiny)
            
            /// Поток через грань (направленный внутрь текущей ячейки)
            let q_face = k_interface * (T_neighbor - T_current) / dx
            
            totalHeatGain += q_face
        }
        
        return totalHeatGain /// [W/m²] суммарный баланс диффузии для ячейки
    }

}
