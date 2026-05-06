//
//  drawFieldsContent.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 17.11.2025.
//
//MARK: - Rendering variable fields

import SwiftUI
extension Visualizator {
    
    /// Отрисовка полей переменных
    var drawFieldsContent: some View {
        GeometryReader { geometry in
            let angle = solver.params.isGravitySynchronized ? -gravityArrowAngle : rotation
            let frame = isSolving || history.frames.isEmpty ? solver.captureFrame() : history.frames[min(currentFrameIndex, history.frames.count-1)]

            ZStack {
                
                flowContent(for: frame)
                    .gesture(cellLocation(geometry.size))
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .gesture(magnificationGesture)
                    .aspectRatio(dynamicAspectRatio, contentMode: .fit)
 
                if let info = selectedCell {
                    cellInfoPopup(info) /// Всплывающее окно инспектора
                        .scaleEffect(1/scale)
                        .rotationEffect(.degrees(-angle))
                        .position(x: inspectorPos.x, y: inspectorPos.y - 80)
                        .allowsHitTesting(false) /// не перехватывать жесты
                }
            }
            // Масштаб, поворот и отступ применяем к общему контейнеру
            .scaleEffect(scale)
            .rotationEffect(.degrees(angle))
            .offset(offset)
        }
        .contentShape(Rectangle())
    }
    /// Нормализованное соотношение ширины к высоте
    private var dynamicAspectRatio: CGFloat {
        let physicalWidth = (solver.x.last ?? 1.0) * (solver.rx.max() ?? 1.0)
        let physicalHeight = solver.y.last ?? 1.0
        return physicalWidth / physicalHeight
    }

}
