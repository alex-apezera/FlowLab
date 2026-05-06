//
//  File.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 11.11.2025.
//
//MARK: - Control commands

//import IOKit.pwr_mgt
import SwiftUI
extension Visualizator {
    
    /// Команды управления задачей
    var controlButtons: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            // Диагностика решения
            Button { withAnimation(.easeInOut(duration: 0.5)) { showDiagnostics.toggle() }
            } label: {
                HStack { Text("Z:").bold(); Text("📊 Diagnostics") }
            }
            .keyboardShortcut("z", modifiers: [])
            
            // Сброс к начальному состоянию
            Button { withAnimation(.easeInOut(duration: 0.5)) { resetSolver() }
            } label: {
                HStack { Text("X:").bold(); Text("🪣 Reset") }
            }
            .keyboardShortcut("x", modifiers: [])
            .disabled(isSolving) /// в режиме решения сброс неактивен
            
            // Управление историей
            Button { withAnimation(.easeInOut(duration: 0.5)) { showHistoryManager.toggle() }
            } label: {
                HStack { Text("C:").bold(); Text("💾 History") }
            }
            .keyboardShortcut("c", modifiers: [])
            .disabled(isSolving)/// в режиме решения доступа к истории нет
            
            // Настройки
            Button { withAnimation(.easeInOut(duration: 0.5)) { showSettings.toggle() }
            } label: {
                HStack { Text("/:").bold(); Text("⚙️ Settings") }
            }
            .keyboardShortcut("/", modifiers: [])
            
            // Запуск решения / Режим ожидания
            Button {withAnimation(.easeInOut(duration: 0.5)) { isSolving.toggle()}}
            label: {
                HStack {
                    Text("Q:").bold()
                    Text(isSolving ? "⏸️ Stop" : "▶️ Start").blinking()
                }
            }
            .keyboardShortcut("q", modifiers: [])
            
            // Кнопка ускорения
            acceleration

        }
        // включение/выключение таймера и активности системы
        .onChange(of: isSolving) { _, newValue in
            if newValue {
                timerManager.startCounting()
                solver.simulationActivity = ProcessInfo.processInfo.beginActivity(
                    options: [.background, .idleSystemSleepDisabled, .idleDisplaySleepDisabled],
                    reason: "Simulation is in progress")
            } else {
                timerManager.pauseCounting()
                if let activity = solver.simulationActivity {
                    ProcessInfo.processInfo.endActivity(activity)
                    solver.simulationActivity = nil
                }
            }
        }
        .contentShape(Rectangle()) /// зона кликабельности
        .font(.body)
        .frame(width: iPadDevice ? 180 : 260)
        .background(shortcuts)
    }
    
    /// Сброс к начальному состоянию (дубль)
    private var shortcuts: some View {
        Group {
            Button("") { resetSolver() /// Функция полной очистки и перезапуска
            }.keyboardShortcut(.escape, modifiers: [])
        }
    }
    
    
}
