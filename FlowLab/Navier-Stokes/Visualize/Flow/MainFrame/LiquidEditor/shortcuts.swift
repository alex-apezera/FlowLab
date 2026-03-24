//
//  shortcuts.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 28.01.2026.
//
import SwiftUI
extension LiquidFractionEditor {
    // --- ГРОРЯЧИЕ КЛАВИШИ ---
    var shortcuts: some View {
        Group {
            // Управление твердой фазой
            Button("") { solver.reset() /// Функция полной очистки
            }.keyboardShortcut(.escape, modifiers: [])
            Button("") { currentTool = .freehand }.keyboardShortcut("1", modifiers: [])

            // Смена типа объекта
            Button("") {solver.makeSolid.toggle() }.keyboardShortcut("r", modifiers: [])
            Button("") { solver.activeObjectType = .circle; currentTool = .circle }.keyboardShortcut("2", modifiers: [])
            Button("") { solver.activeObjectType = .rectangle; currentTool = .rectangle }.keyboardShortcut("3", modifiers: [])
            // Ластик и кнопка сброса
            Button("") { currentTool = .eraser }.keyboardShortcut("4", modifiers: [])
            // --- ФИКСАЦИЯ (Enter) ---
            Button("") { bakeCurrentPreviewIntoGrid() }.keyboardShortcut(.return, modifiers: [])

            // Перемещение объекта (стрелки или вкл/выкл манипулятор )
            Button("") { solver.activeObjectPos.x += 1 }.keyboardShortcut(.rightArrow, modifiers: [])
            Button("") { solver.activeObjectPos.x -= 1 }.keyboardShortcut(.leftArrow, modifiers: [])
            Button("") { solver.activeObjectPos.y += 1 }.keyboardShortcut(.upArrow, modifiers: [])
            Button("") { solver.activeObjectPos.y -= 1 }.keyboardShortcut(.downArrow, modifiers: [])
            
            // Изменение размеров (WSAD)
            Button("") { solver.activeObjectSize.height += 1 }.keyboardShortcut("w", modifiers: [])
            Button("") { solver.activeObjectSize.height -= 1 }.keyboardShortcut("s", modifiers: [])
            Button("") { solver.activeObjectSize.width += 1 }.keyboardShortcut("d", modifiers: [])
            Button("") { solver.activeObjectSize.width -= 1 }.keyboardShortcut("a", modifiers: [])
            
            Button("") { brushSize += 2 }.keyboardShortcut("+", modifiers: [])
            Button("") { brushSize = max(2, brushSize - 2) }.keyboardShortcut("-", modifiers: [])

            // Сохранение/загрузка файлов
            Button("") {
                exportDoc = SimulationDocument(state: SimulationStateLiquidFraction(liquidFraction: solver.liquidFraction, T: solver.T))
                isShowingExporter = true
            }.keyboardShortcut("s", modifiers: .command)
            Button("") { isShowingImporter = true }.keyboardShortcut("o", modifiers: .command)
            
        }.opacity(0)
    }
}
