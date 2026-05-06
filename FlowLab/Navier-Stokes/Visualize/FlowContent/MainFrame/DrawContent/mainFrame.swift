//
//  mainFrame.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 12.11.2025.
//
//MARK: - Main visualization area

import SwiftUI
extension Visualizator {
    
    /// Основная  область визуализации
    var mainFrame: some View {
        
        ZStack {
            // Фон
            Rectangle()
                .fill(Color.gray.opacity(0.25))
                .border(Color.blue, width: 1)
            
            if useMaxAccelerate { disableView } else {
                
                drawFieldsContent /// Отрисовка полей переменных
                
                drawPlotsContent /// Графики для температуры и градиента на границах
                
                editFractionContent /// Редактирование  твердой фазы в жидкости
                
                alertMessage /// Сообщение о расходимости
            }
        }
        .padding(.bottom,10)
    }
    
    /// Отключение просмотра
    var disableView: some View {
        VStack {
            Text("Acceleration mode")
        }
        .padding()
    }

}
