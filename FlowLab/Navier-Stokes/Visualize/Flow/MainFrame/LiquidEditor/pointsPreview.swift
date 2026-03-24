//
//  pointsPreview.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 28.01.2026.
//
import Foundation
extension LiquidFractionEditor {
    
    func isPointInsidePreview(col: Int, row: Int) -> Bool {
        let dx = CGFloat(col) - solver.activeObjectPos.x
        let dy = CGFloat(row) - solver.activeObjectPos.y
        
        // Используем половину ширины и высоты
        let w2 = max(1, solver.activeObjectSize.width / 2)
        let h2 = max(1, solver.activeObjectSize.height / 2)
        
        switch currentTool {
        case .circle:
            // Уравнение эллипса: (x/a)^2 + (y/b)^2 <= 1
            return (dx*dx)/(w2*w2) + (dy*dy)/(h2*h2) <= 1.0
        case .rectangle:
            // Границы прямоугольника
            return abs(dx) <= w2 && abs(dy) <= h2
        default:
            return false
        }
    }
}
