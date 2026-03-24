//
//  resetFuncs.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 20.11.2025.
//
import SwiftUI
extension Visualizator {
    
    //MARK: - Сброс результатов текущих расчетов, диагностики, таймера и истории
    func resetSolver() {
        isSolving = false
        isPlayingHistory = false
        history.clear()
        activeHistoryFile = nil
        currentFrameIndex = 0
        timerManager.stopAndResetCounting()
        solver.reset()

        // Сброс трансформаций
        resetTransformations()
    }

    // MARK: - Сброс трансформаций
    func resetTransformations() {
        withAnimation(.easeInOut(duration: 0.5)) {
            scale = 1; lastScale = 1
            offset = .zero; lastOffset = .zero
            rotation = 0; lastRotation = 0
        }
    }
    
}
