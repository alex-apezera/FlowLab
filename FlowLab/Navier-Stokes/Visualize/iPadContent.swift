//
//  iPadContent.swift
//  FlowLab
//
//  Created by Алексей Езерский on 14.07.2026.
//
//MARK: - Presentation for iPad, Mac (landscape orientation)

import SwiftUI
extension Visualizator {
    /// Presentation will be use for only iPad or Mac
    func iPadContent(_ header: String) -> some View {
        VStack(alignment: .leading) {
            HStack {
                controlButtons /// кнопки управления
                VStack {
                    gravityLegend /// управление вектором гравитации
                    buttonFreeze.padding(.top, 20)
                }
                parametersInfo /// основные параметры задачи
            }
            switchContent /// переключатели для визуализации
            historyFrame  /// слайдер истории с кнопками управления
            mainFrame /// область визуализации
            diagnostics /// диагностика (если включена)
        }
        .padding(.horizontal, 15)
        
        // Запуск панели настроек
        .sheet(isPresented: $showSettings) { SettingsView(solver: solver) }
        
        // Запуск панели со слайдером Истории
        .sheet(isPresented: $showHistoryManager) {
            HistoryManagerView(
                isPresented: $showHistoryManager,
                solver: solver,
                history: history,
                timerManager: timerManager,
                activeFile: $activeHistoryFile
            )
        }
        // Запуск процесса решения уравнений
        .onChange(of: isSolving) { _, solving in
            if solving { startSolving() } else { stopSolving() }
        }
        // Запуск Проигрывателя Истории
        .onChange(of: isPlayingHistory) { _, playing in
            if playing { startHistoryPlayback()
            } else { stopHistoryPlayback() }
        }
        // Отменяем все задачи при исчезновении view
        .onDisappear { stopSolving(); stopHistoryPlayback() }
    }
}
