//
//  GestureVars.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 18.07.2025.
//

import SwiftUI
extension Visualizator {
    
    // MARK: - Жесты
    
    var dragGesture: some Gesture { /// перемещение
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
    
    func cellLocation(_ size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                updateInspector(at: value.location, in: size)
            }
            .onEnded { _ in selectedCell = nil } // Скрывать при отпускании
    }
        
    var magnificationGesture: some Gesture { /// масштабирование
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
        
    var rotationGesture: some Gesture { /// поворот
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
