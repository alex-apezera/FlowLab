//
//  historyFrame.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 14.11.2025.
//

import SwiftUI
extension Visualizator {
    
    //MARK: - Проигрывание истории в автоматическом или ручном режимах
    @ViewBuilder
    var historyFrame: some View {
        
        if !isSolving && !history.frames.isEmpty {
            VStack {
                HStack {
                    Button(action: toggleHistoryPlayback) {
                        Image(systemName: isPlayingHistory ? "pause.fill" : "play.fill")
                    }
                    Text("Скорость:")
                    Slider(value: $historyPlaybackSpeed, in: 1...15, step: 1) {
                        Text("Скорость")
                    } minimumValueLabel: {
                        Text("1x")
                    } maximumValueLabel: {
                        Text("15x")
                    }
                    .frame(width: 250)
                    Text("\(historyPlaybackSpeed, specifier: "%.0f")x")
                        .frame(width: 40)
                    Spacer()
                                        
                    Text("Кадр: \(currentFrameIndex + 1)/\(history.frames.count)")
                    Spacer()
                    // Управление историей
                    if let activeHistoryFile {
                        Text("Файл: \(activeHistoryFile) -   \(loadedComment)").padding(.bottom, 10)
                    }
                    Spacer()

                    Button(action: { currentFrameIndex = 1 }) {
                        Image(systemName: "backward.end.alt")
                    }
                }
                .contentShape(Rectangle()) /// управление кликабильностью
                .padding(.horizontal)
                
                Slider(
                    value: Binding(
                        get: { Double(currentFrameIndex) / Double(max(1, history.frames.count - 1)) },
                        set: { newValue in
                            currentFrameIndex = min(Int(newValue * Double(history.frames.count - 1)), history.frames.count - 1)
                        }
                    ),
                    in: 0...1
                )
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
        }
    }
}
