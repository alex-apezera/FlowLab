//
//  liquidWidth.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 08.01.2026.
//
//MARK: - Calculation of average volume, minimum and maximum melt thickness

extension NavierStokesSolver {
    
    /// Вычисление среднего объёма, минимальной и максимальной толщин расплава
    func liquidWidth(_ liquidFraction: [Double], _ rx: [Double], _ rx_avg: Double) -> (avg: Double, min: Double, max: Double) {
  
        guard useEnthalpyMethod else {
 
            // Используется ALE метод и неравномерная сетка
            return (avg: rx_avg, /// coldWallState()
                    min: (rx.min() ?? 1.0),
                    max: (rx.max() ?? 1.0))
        }
        
        // Далее используется EPM метод и квадратная сетка
        let initialWidth: Double = initMeltWidthRatio * Lx
        var widths = [Double](repeating: 1.0, count: ny)
        for j in 0..<ny {
            widths[j] = findFrontLocation(liquidFraction, j)
        }
        
        let n = 1 /// Количество неучитываемых концевых элементов для мин и макс
        let subWidths = widths[n..<(widths.count - n)]
        // Относительные объём и толщины не могут быть меньше 1.0
        let avgWidth = max(1, subWidths.reduce(0, +) / Double(ny-2*n) / initialWidth)
        let minWidth = max(1, (subWidths.min() ?? 1.0) / initialWidth)
        let maxWidth = max(1, (subWidths.max() ?? 1.0) / initialWidth)
        return (avg: avgWidth, min: minWidth, max: maxWidth) ///[1]
    }
    
    /// Поиск "честной" толщины в EPM
    private func findFrontLocation(_ liquidFraction: [Double], _ j: Int) -> Double {
        let row = j * nx
        for i in (0..<nx-1).reversed() {
            let idx = row + i
            let f = liquidFraction[idx]
            if f > 0.5 {
                // Линейная интерполяция между узлами i и i+1
                return h * (Double(i) + (0.5 - f) / (liquidFraction[idx+1] - f))
            }
        }
        return 0.0
    }
}
