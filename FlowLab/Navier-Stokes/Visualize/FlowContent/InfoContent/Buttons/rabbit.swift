//
//  rabbit.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 11.02.2026.
//
//MARK: - Operational management of the time step ∆t

import SwiftUI
extension Visualizator {
    
    /// Оперативное правление временнЫм шагом ∆t
    var rabbit: some View {
        HStack {
            let dtRabbit = 0.01, dtTurtle = 0.001
            let dtUp = 1.2, dtDown = 0.8

            Button {
                solver.dt = dtTurtle
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: solver.dt < dtRabbit ? "tortoise.fill" : "hare.fill")
                    Text(String(format: "t:[⬇︎:⬆︎], ∆t=%.5f[s] ", solver.dt))
                        .underline(false)
                }
                .font(.system(.caption, design: .monospaced))
                .padding(6)
                .foregroundColor(solver.dt < dtRabbit ? solver.dt < dtTurtle/2 ? .red : .orange : .green)
                .background(.ultraThinMaterial)
                .cornerRadius(6)
            }
            .keyboardShortcut("t", modifiers: [])
            
            Button("") { solver.dt *= dtUp }.keyboardShortcut("]", modifiers: [])
            Button("") { solver.dt *= dtDown }.keyboardShortcut("[", modifiers: [])
        }
    }
}
