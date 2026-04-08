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
            freezeVelocities = true
        } label: {
            HStack {
                Image(systemName: solver.isFrozen ? "snow" : "wind")
                Text(solver.isFrozen ? "V➡︎0" : "V≠0")
            }
            .font(.system(.caption, design: .monospaced))
            .padding(6)
            .foregroundColor(solver.isFrozen ? .orange : .blue)
            .background(.ultraThinMaterial)
            .cornerRadius(6)
            .opacity(0.85)
        }
        .keyboardShortcut("v", modifiers: [])
        .actionSheet(isPresented: $freezeVelocities) {
            ActionSheet(
                title: Text("Заморозка скоростей"),
                message: Text(solver.isFrozen ? "Включено ❄️" : "Выключено"),
                buttons: [
                    .default(Text("ВКЛЮЧИТЬ")) {
                        solver.isFrozen = true
                    },
                    .destructive(Text("ВЫКЛЮЧИТЬ")) {
                        solver.isFrozen = false
                    },
                    .cancel()
                ]
            )
        }
    }
}
