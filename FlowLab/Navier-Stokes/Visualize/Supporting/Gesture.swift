//
//  GestureVars.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 18.07.2025.
//
// MARK: - Use Gestures

import SwiftUI
extension Visualizator {
    
    /// Перемещение
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }
    
    /// Перемещение
    func cellLocation(_ size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                updateInspector(at: value.location, in: size)
            }
            .onEnded { _ in selectedCell = nil } // Скрывать при отпускании
    }
       
    /// Масштабирование
    var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let delta = value / lastScale
                lastScale = value
                scale = max(0.1, min(5.0, scale * delta))
            }
            .onEnded { _ in
                lastScale = 1.0
            }
    }
        
    /// Поворот
    var rotationGesture: some Gesture {
        RotationGesture()
            .onChanged { value in
                let delta = value.degrees - lastRotation
                lastRotation = value.degrees
                rotation += delta
            }
            .onEnded { _ in
                lastRotation = 0
            }
    }
}
