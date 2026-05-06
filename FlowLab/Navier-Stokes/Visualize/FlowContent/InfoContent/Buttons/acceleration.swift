//
//  acceleration.swift
//  FlowLab
//
//  Created by Алексей Езерский on 16.07.2026.
//
//MARK: - Button for maximum acceleration of calculation

import SwiftUI
extension Visualizator {
    
    /// Кнопка для максимального ускорения
    var acceleration: some View {
        Button {withAnimation(.easeInOut(duration: 0.5)) { useMaxAccelerate.toggle()}}
        label: {
            HStack {
                Image(systemName: "arrow.forward.to.line")
                Text("Accelerate")
            }
        }
        .keyboardShortcut(.tab, modifiers: [])
    }
}
