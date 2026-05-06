//
//  iPhoneContent.swift
//  FlowLab
//
//  Created by Алексей Езерский on 14.07.2026.
//
//MARK: - Presentation for iPhone (portrait and landscape orientations)

import SwiftUI
extension Visualizator {
    
    /// Presentation will be use for only iPhone (portrait and landscape)
    func iPhoneContent(_ header: String) -> some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 30) {

                    HStack {
                        controlButtons
                        VStack {
                            gravityLegend /// управление вектором гравитации
                            buttonFreeze.padding(.top, 20)
                        }
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 10) {
                            parametersInfo
                            diagnostics
                            switchContent
                            historyFrame
                        }
                        .font(.system(.footnote, design: .monospaced))
                        .buttonStyle(.borderless)
                    }
                    mainFrame.frame(width: isLandscape ? 800 : 400, height: 400)
                    
                }
                .padding(.vertical,20).padding(.horizontal,15)
                .frame(maxHeight: .infinity, alignment: .top)
            }
            
            // Вычисление ориентации устройства
            .onAppear {
                // Определяем ориентацию при появлении
                isLandscape = geometry.size.width > geometry.size.height
            }
            .onChange(of: geometry.size) { _, newSize in
                // Обновляем при изменении размера (повороте)
                isLandscape = newSize.width > newSize.height
            }
        }
        // Исчезающий заголовок задачи
        .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: { withAnimation {showHeader = false} }) }
        
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
