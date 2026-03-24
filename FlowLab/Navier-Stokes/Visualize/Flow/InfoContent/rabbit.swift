//
//  rabbit.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 11.02.2026.
//
import SwiftUI
extension Visualizator {
    
    var rabbit: some View {
        HStack {
            Button {
                solver.dt /= 2
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: solver.dt < 1e-4 ? "tortoise.fill" : "hare.fill")
                    Text(String(format: "[⬇︎:⬆︎], ∆t: %.2e[s] ", solver.dt))
                }
                .font(.system(.caption, design: .monospaced))
                .padding(6)
                .foregroundColor(solver.dt < 1e-4 ? .orange : .green)
                .background(.ultraThinMaterial)
                .cornerRadius(6)
                .opacity(0.85)
            }
            .keyboardShortcut("[", modifiers: [])
            
            Button("") { solver.dt *= 1.1 }.keyboardShortcut("]", modifiers: [])

        }
        //        .padding(8)
    }
}
