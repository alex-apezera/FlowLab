//
//  Visualizator.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 14.07.2025.
//
// MARK: - Flow visualizer with advanced features

import SwiftUI

/// Визуализатор потока с расширенными функциями
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
    @State var resetSolution = false /// сброс к началу расчетов

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
    @State var showDiagnostics = false /// показать  диагностику
    @State var toggleDiagnostic: Bool = false /// режимы диагн.
    @State var addVelocityField: Bool = true /// наложение поля 𝐕
    @State var toggleColorScheme: Bool = true /// цветовая схема
    @State var toggleVelocityColor: Bool = true /// цвета для 𝐕
    @State var arrowDensity: Int = 4 /// прореживание стрелок
    @State var arrowScale: Double = 0.5 /// масштаб стрелок
    @State var showFrontLine: Bool = true ///показ фронта плавления
    @State var needsStream = true /// если необходим пересчёт ω
    @State var realSize: Bool = false /// размерность для meltWidth
    @State var isLandscape: Bool = false /// поворот для iPhone
    @State var shortKeys: Bool = false ///  панель горячих клавиш

    // Выбор объекта демонстрации
    @State var selectedVisualization = 0 /// выбор объекта  
    let visualizationOptions = ["T", "p", "ψ", "T(x)", "q(t)", "🟦", "ω"]

    /// Заголовок задачи
    @State var showHeader = true
    let headerTask = "Solution of 2D Navier-Stokes Equations in the Boussinesq Approximation on a Collocation Grid in a Rectangular Domain with Melting Option"

    // Главный экран
    var body: some View {
        VStack {
            if showHeader || iPadDevice { Text(headerTask).bold() }
            if !solver.params.comment.isEmpty { Text("Comment: \(solver.params.comment)") }
            // Управление историей
            else if let activeHistoryFile {
                Text("File: \(activeHistoryFile) -   \(loadedComment)")
            }
        }
        .padding(5)
        
        if iPadDevice { iPadContent(headerTask) } else { iPhoneContent(headerTask) }
            
    }
}


