//
//  Visualizator.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 14.07.2025.
//

import SwiftUI

// MARK: - Визуализатор потока с расширенными функциями

struct Visualizator: View {
    @ObservedObject var solver = NavierStokesSolver()
    @ObservedObject var history = HistoryStore()
    @StateObject var timerManager = TimeCounterManager()
    
    // Управление задачей
    @State var isSolving = false /// запуск процесса решения
    @State var showSettings = false /// управление настройками
    @State var useRestoreState: Bool = false /// откат на 20 шагов
    @State var meltingActive: Bool = false /// запуск задачи плавления
    @State var useMaxAccelerate: Bool = false /// отключение визуализации
    @State var freezeVelocities: Bool = false /// заморозка скоростей
    
    // Управление Историей
    @State var currentFrameIndex = 0
    @State var showHistoryManager = false
    @State var activeHistoryFile: String?
    @State var ySlice: Double = 0.5
    @State var isPlayingHistory = false
    @State var historyPlaybackSpeed: Double = 1.0
    @State var showHistoryPanel = false
    @State var showHistoryPlayView = false
    @State var isSavingHistory = false
    @AppStorage("loadedComment") var loadedComment = ""
    
    // Для применения жестов в области визуализации
    @State var scale: CGFloat = 1.0
    @State var lastScale: CGFloat = 1.0
    @State var offset: CGSize = .zero
    @State var lastOffset: CGSize = .zero
    @State var rotation: Double = 0
    @State var lastRotation: Double = 0
    @State var selectedCell: CellInfo? = nil
    @State var inspectorPos: CGPoint = .zero
    
    // Для управления асинхронными задачами
    @State var solvingTask: Task<Void, Error>?
    @State var playbackTask: Task<Void, Error>?
    
    // Для кнопок управления состоянием полей и графиками
    @State var showDiagnostics = false /// показать режим диагностики
    @State var toggleDiagnostic: Bool = false /// режимы диагностики
    @State var addVelocityField: Bool = true /// наложение поля скоростей
    @State var toggleColorScheme: Bool = true /// цветовая схема поля для T, p, ψ
    @State var toggleVelocityColor: Bool = true /// цветовая схема для вектора V
    @State var arrowDensity: Int = 4 /// плотность стрелок (прореживание)
    @State var arrowScale: Double = 0.5 /// масштабирование стрелок
    @State var showFrontLine: Bool = true /// показ фронта плавления
    @State var needsStream = true /// если необходим пересчёт ω
    
    // Выбор объекта демонстрации
    @State var selectedVisualization = 0 /// переключается в switchContent
    let visualizationOptions = ["T", "p", "ψ", "T(x)", "q(t)", "🟦", "ω"]

    // Главный экран
    var body: some View {
        VStack {
            Text("Решение 2D уравнений Навье-Стокса в приближении Буссинеска с использованием коллокационной сетки в прямоугольной области")
                .padding(.bottom, 20)
            HStack {
                gravityLegend /// управление вектором гравитации
                parametersInfo /// основные параметры задачи
                Spacer()
                controlButtons /// кнопки управления
            }
            switchContent /// переключатели для визуализации
            infoLine /// информационная строка
            mainFrame /// область визуализации
            historyFrame  /// слайдер истории с кнопками управления
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


