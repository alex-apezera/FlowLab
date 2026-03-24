//
//  liquidWidth.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 08.01.2026.
//
extension NavierStokesSolver {
    
    /// Вычисление средней, минимальной и максимальной толщин расплава
    func liquidWidth(_ liquidFraction: [Double], _ rx: [Double], _ rx_avg: Double) -> (avg: Double, min: Double, max: Double) {
  
        guard useEnthalpyMethod else {
 
            // Используется ALE метод
            return (avg: rx_avg,
                    min: (rx.min() ?? 1.0),
                    max: (rx.max() ?? 1.0))
        }
        
        /// Далее используется EPM метод
        let initialWidth: Double = initMeltWidthRatio * Lx
        var widths = [Double](repeating: 1.0, count: ny)
        for j in 0..<ny {
            widths[j] = findFrontLocation(liquidFraction, j)
        }
        
        let n = 1 // Количество неучитываемых концевых элементов для мин и макс
        let subWidths = widths[n..<(widths.count - n)]

        let avgWidth = subWidths.reduce(0, +) / Double(ny-2*n) / initialWidth
        let minWidth = (subWidths.min() ?? 1.0) / initialWidth
        let maxWidth = (subWidths.max() ?? 1.0) / initialWidth
        return (avg: avgWidth, min: minWidth, max: maxWidth) ///[1]
    }
    
    /// Относительные объём расплава искорость его приращения
    func updateMeltWidth(method: Bool = false) { /// по умолчанию - метод ALE
        rx_avg_old = rx_avg
        if method {
            rx_avg = liquidWidth(liquidFraction, rx,  rx_avg).avg  /// [1]
            let Rx = 1 / initMeltWidthRatio
            if rx_avg  > Rx {rx_avg = Rx } /// ограничитель
            V_melt_avg = (rx_avg - rx_avg_old) / (dTime + 1e-10)///  [1/s]
        } else {
            rx_avg = calculateAverageByHeight(value: rx) ///  [1]
            if rx_avg > Rx {rx_avg = Rx} /// ограничитель
            V_melt_avg = calculateAverageByHeight(value: V_melt)/// [m/s]
        }
    }
    
    /// Поиск "честной" толщины в EPM
    private func findFrontLocation(_ liquidFraction: [Double], _ j: Int) -> Double {
        for i in (0..<nx-1).reversed() {
            let f = liquidFraction[idx(i,j)]
            if f > 0.5 {
                // Линейная интерполяция между узлами i и i+1
                return h * (Double(i) + (0.5 - f) / (liquidFraction[idx(i+1,j)] - f))
            }
        }
        return 0.0
    }
}
