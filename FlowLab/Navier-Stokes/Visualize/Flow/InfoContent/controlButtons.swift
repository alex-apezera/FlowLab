//
//  File.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 11.11.2025.
//
import SwiftUI
extension Visualizator {

    var controlButtons: some View {
        VStack {
            HStack(spacing: 20) {
                
                // Старт/пауза
                Button { withAnimation(.easeInOut(duration: 0.5)) { isSolving.toggle() }
                } label: {
                    Image(systemName: isSolving ? "pause.fill" : "play.fill")
                }
                
                // Диагностика решения
                Button { withAnimation(.easeInOut(duration: 0.5)) {showDiagnostics.toggle() }} label: {
                    Image(systemName: "rectangle.and.text.magnifyingglass") }
                
                // Сброс к начальному состоянию
                Button(action: resetSolver) {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(isSolving) /// в режиме решения сброс неактивен
                
                // Управление историей
                Button { withAnimation(.easeInOut(duration: 0.5)) {showHistoryManager.toggle() }
                } label: {
                    Image(systemName: "desktopcomputer")
                }
                /// Режим управления историей выключен при включенном режиме решения
                .disabled(isSolving)
                
                // Настройки
                Button { withAnimation(.easeInOut(duration: 0.5)) { showSettings.toggle() }
                } label: {
                    Image(systemName: "gear")
                }
                
            }
            .onChange(of: isSolving) { _, newValue in /// включение/выключение таймера
                newValue ? timerManager.startCounting() : timerManager.pauseCounting()
            }
            .contentShape(Rectangle()) /// зона кликабельности
        }
    }
}
