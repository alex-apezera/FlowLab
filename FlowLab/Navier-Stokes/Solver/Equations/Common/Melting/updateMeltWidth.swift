//
//  updateMeltWidth.swift
//  FlowLab
//
//  Created by Алексей Езерский on 14.06.2026.
//
//MARK: - Relative volume of the melt, rate of its increase from physics

extension NavierStokesSolver {
    /// Относительные объём расплава [1] и скорость его приращения [1/s]  из физики
    func updateMeltWidth() {
        
        // проверка режима (плавление или нет)
        guard allowMelt else { rx_avg = 1; V_melt_avg = 0; return }

        // лимит прироста отностительного объёма V/V₀
        let maxIncrement = 0.05
 
        // предыдущий объём
        rx_avg_old = rx_avg

        // текущий объём
        rx_avg = useEnthalpyMethod ?
        liquidWidth(liquidFraction, rx,  rx_avg).avg :
        calculateAverageByHeight(value: rx)
  
        // прирост отностительного объёма не более  maxIncrement
        if rx_avg - rx_avg_old > maxIncrement {
            rx_avg = rx_avg_old + maxIncrement }

        // скорость приращения жидкой фазы [1/c]
        V_melt_avg = (rx_avg - rx_avg_old) / (dTime+tiny)
    }
}
