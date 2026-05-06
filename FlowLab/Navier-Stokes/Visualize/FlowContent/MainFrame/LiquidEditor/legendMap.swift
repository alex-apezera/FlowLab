//
//  legendMap.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 28.01.2026.
//
//MARK: - View box: Legend and controls

import SwiftUI
extension LiquidFractionEditor {
    
    /// View box: Легенда и управление
    var legendMap: some View {
        VStack(alignment: .leading, spacing: 5) {
            ScrollView(.vertical, showsIndicators: false) {
                Text("Hotkeys and Control")
                    .font(.footnote).foregroundStyle(.tertiary)
                // Управление твердой фазой
                Text("PHASE MODE").font(.headline).bold().padding(.top, 5)
                Button(solver.makeSolid ? "R: Solid mode ON" : "R: Solid mode OFF") { solver.makeSolid.toggle()}
                    .keyboardShortcut("r", modifiers: [])
                
                // Смена типа объекта
                Text("TOOL: \(String(describing: currentTool))").bold().padding(.top, 10)
                Button("1: Brush") { currentTool = .freehand }.keyboardShortcut("1", modifiers: [])
                Button("2: Circle") { solver.activeObjectType = .circle; currentTool = .circle }.keyboardShortcut("2", modifiers: [])
                Button("3: Rectangle") { solver.activeObjectType = .rectangle; currentTool = .rectangle }.keyboardShortcut("3", modifiers: [])
                Button("4: Eraser") { currentTool = .eraser }.keyboardShortcut("4", modifiers: [])
                HStack {
                    Button("+") { brushSize += 1 }.keyboardShortcut("+", modifiers: [])
                    Button("-") { brushSize = max(2, brushSize - 1) }.keyboardShortcut("-", modifiers: [])
                }
                // Изменение размеров (WSAD) и перемещение
                Text("SIZE and MOVE: \(solver.activeObjectType == .circle ? "Circle" : "Rectangle")").bold().padding(.top, 10)
 
                Button("W: more hight") { solver.activeObjectSize.height += 1 }.keyboardShortcut("w", modifiers: [])
                Button("A: less width") { solver.activeObjectSize.width -= 1 }.keyboardShortcut("a", modifiers: [])
                Button("D: more width") { solver.activeObjectSize.width += 1 }.keyboardShortcut("d", modifiers: [])
               Button("S: less hight") { solver.activeObjectSize.height -= 1 }.keyboardShortcut("s", modifiers: [])
                
                Button("⬆️") { solver.activeObjectPos.y += 1 }.keyboardShortcut(.upArrow, modifiers: [])
                HStack {
                    Button("⬅️") { solver.activeObjectPos.x -= 1 }.keyboardShortcut(.leftArrow, modifiers: [])
                    Button("➡️") { solver.activeObjectPos.x += 1 }.keyboardShortcut(.rightArrow, modifiers: [])
                }
                Button("⬇️") { solver.activeObjectPos.y -= 1 }.keyboardShortcut(.downArrow, modifiers: [])

                // --- ФИКСАЦИЯ (Enter) ---
                Button("✅: Bake") { bakeCurrentPreviewIntoGrid() }.keyboardShortcut(.return, modifiers: []).padding(.top, 10)
                
                // Сохранение/загрузка файлов
                Text("ФАЙЛЫ:").bold().padding(.top, 10)
                Button("⌃S: export") {
                    exportDoc = SimulationDocument(state: SimulationStateLiquidFraction(liquidFraction: solver.liquidFraction, T: solver.T))
                    isShowingExporter = true
                }.keyboardShortcut("s", modifiers: .control)
                Button("⌃O: import") { isShowingImporter = true }.keyboardShortcut("o", modifiers: .control)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(8)
        .padding()
    }
}
