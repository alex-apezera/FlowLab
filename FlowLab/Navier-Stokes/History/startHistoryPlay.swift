//
//  startHistotyPlay.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 14.11.2025.
//
// MARK: - Методы управления Историей

import SwiftUI
extension Visualizator {
    /// Проигрывание истории
    func startHistoryPlayback() {
        // Отменяем предыдущую задачу, если есть
        playbackTask?.cancel()
        
        // Создаем новую задачу
        playbackTask = Task { [self] in
            while !Task.isCancelled && isPlayingHistory && currentFrameIndex < history.frames.count - 1 {
                try await Task.sleep(nanoseconds: UInt64(300_000_000 / historyPlaybackSpeed)) // 0.3 s
                await MainActor.run {
                    if currentFrameIndex < history.frames.count - 1 {
                        currentFrameIndex += 1
                    } else { isPlayingHistory = false }
                }
            }
            await MainActor.run { isPlayingHistory = false }
        }
    }
    
    func toggleHistoryPlayback() {
        isPlayingHistory.toggle()
    }
    
    func stopHistoryPlayback() {
        playbackTask?.cancel()
        playbackTask = nil
    }
}
