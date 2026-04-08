//
//  drawLines.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 17.12.2025.
//

//MARK: - Изолинии с надписями и указателями направления потока для ψ)

import SwiftUI
extension Visualizator {
    /// Отрисовка изолиний с надписями (и указателями направления потока для ψ)
    func drawLines(for field: [Double], in context: inout GraphicsContext, size: CGSize, scale: CGFloat, rx: [Double]) {
        let nx = solver.nx, ny = solver.ny
        let x = solver.x, y = solver.y
        let (vMin, vMax) = fieldLimits(field)
        let nLines = 10
        let levels = (0...nLines).map { vMin + (vMax - vMin) * Double($0) / Double(nLines) }
        
        let halfLx = solver.Lx * rx.max()! / 2.0
        let halfLy = solver.Ly / 2.0
        
        for level in levels {
            let relativeField = (vMax != vMin) ? (level - vMin) / (vMax - vMin) : 0.5
            var path = Path()
            var labelDrawnInZone = [false, false, false]
            
            for j in 0..<ny-1 {
                let row = nx*j
                for i in 0..<nx-1 {
                    let idx = row + i
                    
                    /// код поиска segments через Marching Squares
                    let f = [field[idx], field[idx+1], field[idx+nx+1], field[idx+nx]]
                    let p = [
                        CGPoint(x: (x[i]*rx[j] - halfLx), y: y[j] - halfLy),
                        CGPoint(x: (x[i+1]*rx[j] - halfLx), y: y[j] - halfLy),
                        CGPoint(x: (x[i+1]*rx[j+1] - halfLx), y: y[j+1] - halfLy),
                        CGPoint(x: (x[i]*rx[j+1] - halfLx), y: y[j+1] - halfLy)
                    ]
                    var segments: [CGPoint] = []
                    for k in 0..<4 {
                        let next = (k + 1) % 4
                        if (f[k] <= level && f[next] > level) || (f[k] > level && f[next] <= level) {
                            let t = (level - f[k]) / (f[next] - f[k])
                            let px = p[k].x + t * (p[next].x - p[k].x)
                            let py = p[k].y + t * (p[next].y - p[k].y)
                            segments.append(CGPoint(x: CGFloat(px) * scale, y: -CGFloat(py) * scale))
                        }
                    }
                    if segments.count == 2 {
                        let p0 = segments[0]
                        let p1 = segments[1]
                        path.move(to: p0)
                        path.addLine(to: p1)
                        
                        /// Надписи на изолиниях
                        inscriptions(nx, i, &labelDrawnInZone, &segments, relativeField, context)
                        ///  Указатели направления  потока (стрелки)
                        flowDirection(i, j, p0, p1, field, &context)
                    }
                }
            }
            // Отрисовка изолинии
            context.stroke(path, with: .color(.black.opacity(0.5)), lineWidth: 0.8)
        }
    }
    
    /// Отрисовка стрелок, указывающих направление потока (только для ψ)
    fileprivate func flowDirection(_ i: Int, _ j: Int, _ p0: CGPoint, _ p1: CGPoint, _ field: [Double], _ context: inout GraphicsContext) {
        let nx = solver.nx; let ny = solver.ny
        if i % (nx/5) == 0 && j % (ny/10) == 0 /// частота отрисовки
            && selectedVisualization > 1 { /// условие отрисовки (только для ψ)
            let mid = CGPoint(x: (p0.x + p1.x) / 2, y: (p0.y + p1.y) / 2)
            
            /// Геометрический вектор сегмента (экранный)
            let dx_seg = p1.x - p0.x
            let dy_seg = p1.y - p0.y
            var angle = atan2(dy_seg, dx_seg)
            
            // Вычисляем компоненты скорости ЧЕРЕЗ производные ψ (field)
            /// Это гарантирует идеальное соответствие стрелки линии u = dPsi/dy, v = -dPsi/dx
            
            /// Центральные разности для производных psi в узле (j, i)
            let jMax = ny - 1; let iMax = nx - 1
            let dPsiDy = field[solver.idx(i, min(j+1, jMax))] - field[solver.idx(i, max(j-1, 0))]
            let dPsiDx = field[solver.idx(min(i+1, iMax), j)] - field[solver.idx(max(i-1, 0), j)]
            
            /// Перевод в экранные координаты:  u -> screenDX; v -> -screenDY (инверсия Y в iOS)
            /// Поскольку v = -dPsi/dx, то screenDY = -(-dPsi/dx) = dPsi/dx
            let u_screen = CGFloat(dPsiDy)
            let v_screen = CGFloat(dPsiDx)
            
            // Синхронизация направления (скалярное произведение)
            let dot = dx_seg * u_screen + dy_seg * v_screen
            if dot < 0 { angle += .pi }
            
            // Проверка на наличие потока (чтобы не рисовать в "стоячей" воде)
            if abs(dPsiDy) > 1e-9 || abs(dPsiDx) > 1e-9 {
                drawArrowHead(in: &context, at: mid, angle: Double(angle))
            }
        }
    }

    /// Отрисовка наконечников ("усиков") стрелки
    fileprivate func drawArrowHead(in context: inout GraphicsContext, at point: CGPoint, angle: CGFloat) {
        let arrowLength: CGFloat = 5.0
        let wingAngle: CGFloat = .pi / 7 // Острый наконечник
        var p = Path()
        p.move(to: point)
        // Левое "крыло"
        p.addLine(to: CGPoint(x: point.x - arrowLength * cos(angle - wingAngle), y: point.y - arrowLength * sin(angle - wingAngle)))
        p.move(to: point)
        // Правое "крыло"
        p.addLine(to: CGPoint(x: point.x - arrowLength * cos(angle + wingAngle), y: point.y - arrowLength * sin(angle + wingAngle)))
        
        context.stroke(p, with: .color(.black.opacity(0.8)), lineWidth: 1.2)
    }
    
    /// Отрисовка относительных величин, соответствующих линии (от 0.0 до 1.0)
    fileprivate func inscriptions(_ nx: Int, _ i: Int, _ labelDrawnInZone: inout [Bool], _ segments: inout [CGPoint], _ relativeField: Double, _ context: GraphicsContext) {
        // Надписи (оставляем логику по зонам)
        let cF = nx
        let zones = [cF/4, cF/2, 3*cF/4]
        for (idx, zoneIndex) in zones.enumerated() {
            if i == zoneIndex && !labelDrawnInZone[idx] {
                let labelPos = CGPoint(x: (segments[0].x + segments[1].x) / 2,
                                       y: (segments[0].y + segments[1].y) / 2)
                let labelText = Text(String(format: "%.1f", relativeField))
                    .font(.system(size: 8)).foregroundColor(.black.opacity(0.8))
                context.draw(labelText, at: labelPos)
                labelDrawnInZone[idx] = true
            }
        }
    }

}
