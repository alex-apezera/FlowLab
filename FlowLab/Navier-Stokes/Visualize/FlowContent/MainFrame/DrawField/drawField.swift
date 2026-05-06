//
//  drawField.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 15.11.2025.
//
//MARK: - Variable field image in colors (Heat map)

import SwiftUI
extension Visualizator {
    
    /// Изображение поля переменной в цветах (Тепловая карта)
    func drawField(_ data: [Double], in context: inout GraphicsContext, scale: CGFloat, rx: [Double]) {
        // Кэш
        let nx = solver.nx, ny = solver.ny
        let useWind = solver.params.useWind
        let leftSink = solver.params.leftSink
        let jStart = Int(solver.params.y_start * Double(ny)) /// отметка входа
        let jEnd = Int(solver.params.y_end * Double(ny))
        let jOut = (jEnd-jStart)/2 ///отметка для выходного потока
        let jOut_top = ny-jOut
        let (value_min, value_max) = fieldLimits(data)
        
        // Центры для смещения (физические величины в метрах)
        let halfLx = solver.Lx * rx.max()! / 2.0
        let halfLy = solver.Ly / 2.0
        
        data.withUnsafeBufferPointer { data in
        solver.x.withUnsafeBufferPointer { x in
        solver.y.withUnsafeBufferPointer { y in
        rx.withUnsafeBufferPointer { rx in
                
        for j in 0..<ny-1 {
            let row = nx * j
            let rxJ = rx[j]
            let rxJ1 = rx[j+1]
            let screenY_j = -CGFloat(y[j] - halfLy) * scale
            let screenY_next = -CGFloat(y[j+1] - halfLy) * scale
            
            for i in 0..<nx-1 {
                let idx = row + i
                // Координаты 4-х углов ячейки с учетом РАЗНЫХ rx[j]
                let p1 = CGPoint(x: CGFloat(x[i] * rxJ - halfLx) * scale, y: screenY_j)
                let p2 = CGPoint(x: CGFloat(x[i+1] * rxJ - halfLx) * scale,   y: screenY_j)
                let p3 = CGPoint(x: CGFloat(x[i+1] * rxJ1 - halfLx) * scale, y: screenY_next)
                let p4 = CGPoint(x: CGFloat(x[i] * rxJ1 - halfLx) * scale,   y: screenY_next)
                
                // Цвет ячейки
                let value = data[idx]
                let inletPins = useWind && ((i==0 || i==1) && (j==jStart || j==jEnd))
                let outletPins = (useWind && leftSink) && ((i==0 || i==1) && (j==jOut || j==jOut_top))
                let color: Color
                if outletPins { color = .gray
                } else if inletPins { color = .black
                } else { color = setColor(value, minValue: value_min, maxValue: value_max, mode: toggleColorScheme ? .rainbow : .twoColor)
                }
                
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
    }}}}}///ptr
}
