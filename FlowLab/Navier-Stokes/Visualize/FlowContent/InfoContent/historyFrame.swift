//
//  historyFrame.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 14.11.2025.
//
//MARK: - Play history in automatic or manual modes

import SwiftUI
extension Visualizator {
    
    /// Проигрывание истории в автоматическом или ручном режимах
    @ViewBuilder var historyFrame: some View {
        
        if !isSolving && !history.frames.isEmpty {
            VStack(alignment: .leading) {
                HStack {
                    Button(action: toggleHistoryPlayback) {
                        Image(systemName: isPlayingHistory ? "pause.fill" : "play.fill")
                    }.keyboardShortcut(" ", modifiers: [])
 
                    Text("Velocity:")
                    Slider(value: $historyPlaybackSpeed, in: 1...15, step: 1) {
                        Text("Velocity")
                    } minimumValueLabel: {
                        Text("1x")
                    } maximumValueLabel: {
                        Text("15x")
                    }.frame(width: 250)
                    
                    Text("\(historyPlaybackSpeed, specifier: "%.0f")x")
                        .frame(width: 40)
                        .padding(.trailing,30)
                                        
                    Text("Frame: \(currentFrameIndex + 1)/\(history.frames.count)")
                        .padding(.trailing, 30)

                    Button(action: { currentFrameIndex = 1 }) {
                        Image(systemName: "backward.end.alt")
                    }
                }
                
                Slider(
                    value: Binding(
                        get: { Double(currentFrameIndex) / Double(max(1, history.frames.count - 1)) },
                        set: { newValue in
                            currentFrameIndex = min(Int(newValue * Double(history.frames.count - 1)), history.frames.count - 1)
                        }
                    ),
                    in: 0...1
                )
                .frame(width: iPadDevice ? 620 : (isLandscape ? 620 : 400), height: 10, alignment: .leading)
            }
            .contentShape(Rectangle()) /// управление кликабильностью
            .padding(.horizontal)
            .padding(.bottom, iPadDevice ? 5 : 0)
        }
    }
}
