//
//  flowContent.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 15.11.2025.
//
// MARK: - Visualization of variable fields with superposition of velocities

import SwiftUI
extension Visualizator {
    
    /// Визуализация полей переменных с наложением поля скоростей
    @ViewBuilder func flowContent(for frame: HistoryFrame) -> some View {
        let Lx = CGFloat(solver.Lx), Ly = CGFloat(solver.Ly)

        Canvas { context, size in
            let scaleX = size.width / Lx, scaleY = size.height / Ly
            let scale = min(scaleX, scaleY)
            
            // Переносим начало координат в центр Canvas для всех отрисовок
            var centralContext = context
            centralContext.translateBy(x: size.width/2, y: size.height/2)
            
            var field: [Double]
            switch selectedVisualization {
            case 0: field = frame.temperature
            case 1: field = frame.pressure
            case 2: field = solver.streamFunction(u: frame.velocityX, v: frame.velocityY, rx: frame.rx, fl: frame.liquidFraction)
            case 6: if needsStream { /// функция тока на основе  уравнения Пуассона
                    solver.updateStreamFunctionAsync(u: frame.velocityX, v: frame.velocityY, rx: frame.rx)
                    DispatchQueue.main.async {self.needsStream = false} }
                field = solver.psi
            default: return }
            
            // 1. Отрисовка фонового поля (Heatmap)
            drawField(field, in: &centralContext, scale: scale, rx: frame.rx)
            
            // 2. Отрисовка вектора скорости (и наложение если нужно)
            if addVelocityField {
                drawVelocity(for: frame, in: &centralContext, size: size, scale: scale) }
            
            // 3. Отрисовка и наложение изолиний
                drawLines(for: field, in: &centralContext, size: size, scale: scale, rx: frame.rx)
            
            // 4. Отрисовка и наложение фронта плавления
            if solver.useEnthalpyMethod && showFrontLine {
                drawSingleLine(for: frame.liquidFraction, level: 0.5, in: &context, size: size, scale: scale) }
        }
        .drawingGroup() /// Включает Metal-акселерацию для Canvas
    }
}
