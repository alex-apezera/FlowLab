//
//  mainFrame.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 12.11.2025.
//

import SwiftUI
extension Visualizator {
    
    var mainFrame: some View {
        // Основная  область визуализации
        
        ZStack {
            // Фон
            Rectangle()
                .fill(Color.gray.opacity(0.25))
                .border(Color.blue, width: 1)
            
            if useMaxAccelerate { emptyView } else {
                
                drawFieldsContent /// Отрисовка полей переменных
                
                drawPlotsContent /// Графики для температуры и градиента на границе плавления
                
                editFractionContent /// Редактирование  твердой фазы в жидкости
                
                alertMessage /// Сообщение о расходимости
            }
        }
        .padding(.bottom,10)
        .background(shortcut)
    }
    
    private var emptyView: some View {
        VStack {
            Text("Этот режим используется для максимального ускорения расчетов")
            Text("Используйте клавишу Tab для переключения").font(.caption)
            Text("Используйте клавишу ^S для старта/паузы").font(.caption)
        }
        .padding()
    }
    @ViewBuilder
    private var shortcut: some View {
        Button("") { useMaxAccelerate.toggle()}.keyboardShortcut(.tab, modifiers: []).opacity(0)
        Button("") { isSolving.toggle()}.keyboardShortcut("s", modifiers: .control).opacity(0)

    }
}
