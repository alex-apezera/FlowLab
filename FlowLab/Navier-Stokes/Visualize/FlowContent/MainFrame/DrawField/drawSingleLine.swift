//
//  drawSingleLine.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 29.12.2025.
//
//MARK: - Drawing the isoline of the melting front

import SwiftUI
extension Visualizator {
    
    /// Отрисовка изолинии фронта плавления
    func drawSingleLine(for field: [Double], level: Double, in context: inout GraphicsContext, size: CGSize, scale: CGFloat) {
        var path = Path()
        let h_scaled = solver.h * scale // Используем ваш шаг h
        
        // Смещение для центрирования (как в ваших полях)
        let nx = solver.nx
        let ny = solver.ny
        let idx = solver.idx
        let offsetX = (size.width - CGFloat(nx-1) * h_scaled) / 2
        let offsetY = (size.height - CGFloat(ny-1) * h_scaled) / 2

        for j in 0..<ny - 1 {
            for i in 0..<nx - 1 {
                // Значения f_l в 4-х углах ячейки
                let f = [field[idx(i,j)], field[idx(i+1,j)], field[idx(i+1,j+1)], field[idx(i,j+1)]]
                
                // Координаты углов ячейки на экране
                // Вместо: y: offsetY + CGFloat(j) * h_scaled
                // Используем инверсию относительно высоты области:
                let screenY_j = offsetY + CGFloat(ny - 1 - j) * h_scaled
                let screenY_next = offsetY + CGFloat(ny - 1 - (j + 1)) * h_scaled

                let p = [
                    CGPoint(x: offsetX + CGFloat(i) * h_scaled,   y: screenY_j),
                    CGPoint(x: offsetX + CGFloat(i+1) * h_scaled, y: screenY_j),
                    CGPoint(x: offsetX + CGFloat(i+1) * h_scaled, y: screenY_next),
                    CGPoint(x: offsetX + CGFloat(i) * h_scaled,   y: screenY_next)
                ]

                // Ищем пересечение уровня 0.5 (Marching Squares)
                var segments: [CGPoint] = []
                for k in 0..<4 {
                    let next = (k + 1) % 4
                    if (f[k] <= level && f[next] > level) || (f[k] > level && f[next] <= level) {
                        let t = (level - f[k]) / (f[next] - f[k])
                        let px = p[k].x + t * (p[next].x - p[k].x)
                        let py = p[k].y + t * (p[next].y - p[k].y)
                        segments.append(CGPoint(x: px, y: py))
                    }
                }
                
                if segments.count == 2 {
                    path.move(to: segments[0])
                    path.addLine(to: segments[1])
                }
            }
        }
        
        // Рисуем фронт яркой белой или черной линией
        context.stroke(path, with: .color(.black), lineWidth: 4.0)
    }

}
