//
//  drawFluxes.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 15.11.2025.
//

import SwiftUI
extension Visualizator {
    
    private func maxVelocity(_ u: [[Double]], _ v: [[Double]]) -> Double {
        // В 2025 году использование vDSP или простых циклов быстрее, чем flatMap
        var maxMag: Double = 0
        for j in 0..<u.count {
            for i in 0..<u[j].count {
                let mag = sqrt(u[j][i]*u[j][i] + v[j][i]*v[j][i])
                if mag > maxMag { maxMag = mag }
            }
        }
        return maxMag
    }

    func drawFluxes(for frame: HistoryFrame, in context: inout GraphicsContext, size: CGSize, scale: CGFloat) {
        let u = frame.velocityX
        let v = frame.velocityY
        let rx = frame.rx
        
        let maxVel = maxVelocity(u, v)
        let skip = arrowDensity
        // Масштаб стрелок должен быть пропорционален характерному размеру ячейки
        let arrowScaleFactor = arrowScale * scale * 0.1
        
        // Смещение для центрирования: левая стенка x=0 сдвигается влево на половину ширины
        // Используем среднее или максимальное расширение для оценки центра
        let halfLx = solver.Lx * rx.max()! / 2.0
        let halfLy = solver.Ly / 2.0
        
        for j in stride(from: 1, to: v.count-1, by: skip) {
            // Инвертированный Y
            let sY = -CGFloat(solver.y[j] - halfLy) * scale
            
            for i in stride(from: 1, to: u[0].count-1, by: skip) {
                let uVal = u[j][i]
                let vVal = v[j][i]
                let velocityMagnitude = sqrt(uVal*uVal + vVal*vVal)
                
                if velocityMagnitude < 1e-6 { continue }

                // Координаты начала (x=0 теперь левая граница, смещенная относительно центра)
                let sX = CGFloat(solver.x[i] * rx[j] - halfLx) * scale
                
                // Координаты конца (инвертируем vVal для Y, так как в UI Y растет вниз)
                let eX = sX + CGFloat(uVal * arrowScaleFactor)
                let eY = sY - CGFloat(vVal * arrowScaleFactor)

                let color = setColor(velocityMagnitude, minValue: 0, maxValue: maxVel, mode: toggleVelocityColor ? .velColor : .white)

                var path = Path()
                path.move(to: CGPoint(x: sX, y: sY))
                path.addLine(to: CGPoint(x: eX, y: eY))
                
                // Наконечник
                let angle = atan2(eY - sY, eX - sX)
                let headLen = min(6.0, 0.3 * sqrt(pow(eX - sX, 2) + pow(eY - sY, 2)))
                
                path.addLine(to: CGPoint(x: eX - headLen * cos(angle - .pi/6), y: eY - headLen * sin(angle - .pi/6)))
                path.move(to: CGPoint(x: eX, y: eY))
                path.addLine(to: CGPoint(x: eX - headLen * cos(angle + .pi/6), y: eY - headLen * sin(angle + .pi/6)))
                
                context.stroke(path, with: .color(color), lineWidth: 0.8)
            }
        }
    }
}

