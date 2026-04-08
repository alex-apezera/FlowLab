//
//  drawField.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 15.11.2025.
//

import SwiftUI
extension Visualizator {
    
    //MARK: - Изображение поля переменной в цветах (Heat map)
    
    func drawField(_ data: [Double], in context: inout GraphicsContext, scale: CGFloat, rx: [Double]) {
        // Кэш
        let nx = solver.nx, ny = solver.ny
        let x = solver.x, y = solver.y
        let (value_min, value_max) = fieldLimits(data)
        
        // Центры для смещения (физические величины в метрах)
        let halfLx = solver.Lx * rx.max()! / 2.0
        let halfLy = solver.Ly / 2.0
   
        for j in 0..<ny-1 {
            let row = nx * j
            let screenY_j = -CGFloat(y[j] - halfLy) * scale
            let screenY_next = -CGFloat(y[j+1] - halfLy) * scale
            
            for i in 0..<nx-1 {
                let idx = row + i
                // Координаты 4-х углов ячейки с учетом РАЗНЫХ rx для разных j
                let p1 = CGPoint(x: CGFloat(x[i] * rx[j] - halfLx) * scale, y: screenY_j)
                let p2 = CGPoint(x: CGFloat(x[i+1] * rx[j] - halfLx) * scale,   y: screenY_j)
                let p3 = CGPoint(x: CGFloat(x[i+1] * rx[j+1] - halfLx) * scale, y: screenY_next)
                let p4 = CGPoint(x: CGFloat(x[i] * rx[j+1] - halfLx) * scale,   y: screenY_next)
                
                let value = data[idx]
                let color = setColor(value, minValue: value_min, maxValue: value_max, mode: toggleColorScheme ? .rainbow : .twoColor)

                // Вместо CGRect рисуем закрашенный полигон (трапецию)
                var cellPath = Path()
                cellPath.move(to: p1)
                cellPath.addLine(to: p2)
                cellPath.addLine(to: p3)
                cellPath.addLine(to: p4)
                cellPath.closeSubpath()
                
                context.fill(cellPath, with: .color(color))
            }
        }
    }
}
