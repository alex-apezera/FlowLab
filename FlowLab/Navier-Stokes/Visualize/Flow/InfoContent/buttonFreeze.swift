//
//  buttonFreeze.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 12.02.2026.
//
import SwiftUI
extension Visualizator {
    
    var buttonFreeze: some View {
        Button {
            solver.isFrozen.toggle()
        } label: {
            HStack {
                Image(systemName: solver.isFrozen ? "snow" : "wind")
                Text(solver.isFrozen ? "V - отключено" : "V - включено")
            }
            .font(.system(.caption, design: .monospaced))
            .padding(6)
            .foregroundColor(solver.isFrozen ? .orange : .blue)
            .background(.ultraThinMaterial)
            .cornerRadius(6)
            .opacity(0.85)
        }
        .keyboardShortcut("v", modifiers: [])
    }
}
