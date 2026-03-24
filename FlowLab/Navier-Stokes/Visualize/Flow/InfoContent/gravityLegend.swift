//
//  gravityLegend.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 01.12.2025.
//
import SwiftUI
extension Visualizator {
    
    // Обозначение гравитации с углом на главном экране
    var gravityLegend: some View {
        VStack {
            let angle = gravityArrowAngle
            Text("Гравитация \(angle, specifier: "%.0f") °").font(.caption)
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 30, height: 30)
                Button {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        rotation = -angle}
                } label: {
                    Image(systemName: "arrow.down")
                        .rotationEffect(.degrees(angle))
                }
            }
            Text("🕗 \(solver.params.gravityRotationVelocity, specifier: "%.1f")\(solver.allowMelt ? " [º/day]" : " [º/s]")").font(.caption)
        }
    }
    
    // Угол вектора гравитации [°], degrees
    var gravityArrowAngle: Double {
        var angle = 0.0
        if isSolving || history.frames.isEmpty {
            // Режим решения - используем текущие данные solver
            angle = solver.gravityArrowAngle
        } else {
            // Режим истории - используем выбранный кадр
            let frameIndex = min(currentFrameIndex, history.frames.count-1)
            let historyFrame = history.frames[frameIndex]
            angle = historyFrame.gravityAngle
        }
        return angle
    }
}
