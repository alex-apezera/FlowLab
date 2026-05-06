//
//  LFEditor.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 23.01.2026.
//
//MARK: - Solid State Editor View and Options

import SwiftUI
import UniformTypeIdentifiers

enum EditorTool { case freehand, circle, rectangle, eraser }

struct LiquidFractionEditor: View {
    @EnvironmentObject var solver: NavierStokesSolver
    
    // Параметры Состояния редактора тела твердой фазы
    @State var currentTool: EditorTool = .freehand
    @State var brushSize: CGFloat = 6
    @State var isShowingImporter = false /// Отвечает за окно "Открыть"
    @State var isShowingExporter = false /// Отвечает за окно "Сохранить"
    @State var exportDoc: SimulationDocument? /// Хранит данные для экспорта

    // Количество ячеек в области редактирования
    let rows: Int
    let cols: Int
 
    var body: some View {
        HStack {
            liquidMap
            legendMap
        }
        // Системные диалоги (iPad-совместимые)
        .fileImporter(isPresented: $isShowingImporter, allowedContentTypes: [.json]) { result in
            importFile(result: result)
        }
        .fileExporter(isPresented: $isShowingExporter, document: exportDoc, contentType: .json) { _ in }
    }
}

