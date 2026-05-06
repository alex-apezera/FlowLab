//
//  startSolving.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 11.11.2025.
//
// MARK: - Solving Management Methods

import SwiftUI
extension Visualizator {
    
    /// Старт решения
    func startSolving() {
        // Отменяем предыдущую задачу, если есть
        solvingTask?.cancel()
        
        // Создаем новую задачу
        solvingTask = Task { [self] in
            while !Task.isCancelled && isSolving && solver.t < solver.maxTime && solver.rx_avg < solver.meltVolumeLimit {
                // Выполняем шаг решения
                guard await solver.solveStep() else { break }
                
                // Сохраняем кадр через заданные интервалы
                if solver.t.truncatingRemainder(dividingBy: solver.timeGap) < solver.dt {
                    let frame = solver.captureFrame()
                    await MainActor.run { history.addFrame(frame: frame) }
                }
                // Небольшая задержка для контроля асинхронности
                try await Task.sleep(nanoseconds: 500_000)
            }
            await MainActor.run { isSolving = false }
        }
    }
    
    func toggleSolving() {
        isSolving.toggle()
    }
    
    func stopSolving() {
        solvingTask?.cancel()
        solvingTask = nil
        needsStream = true
    }
    
}

