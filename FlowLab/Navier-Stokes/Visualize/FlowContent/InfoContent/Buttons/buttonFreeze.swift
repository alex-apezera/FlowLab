//
//  buttonFreeze.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 12.02.2026.
//
//MARK: - Forced zeroing of speeds or return to convection

import SwiftUI
extension Visualizator {
    
    /// Принудительное обнуление скоростей или вернуть к конвекции
    var buttonFreeze: some View {
        Button {
            freezeVelocities = true
        } label: {
            HStack {
                Image(systemName: solver.isFrozen ? "snow" : "wind")
                Text(solver.isFrozen ? "𝐕 = 0" : "𝐕 ≠ 0")
                    .underline(false)
            }
            .font(.system(.caption, design: .monospaced))
            .padding(6)
            .foregroundColor(solver.isFrozen ? .orange : .blue)
            .background(.ultraThinMaterial)
            .cornerRadius(6)
            .opacity(0.85)
        }
        .keyboardShortcut("v", modifiers: [])
        .confirmationDialog("Speed freezing", isPresented: $freezeVelocities, titleVisibility: .visible) {
            Button("Freeze: 𝐕 = 0", role: .destructive) {
                solver.isFrozen = true
            }
            Button("Unfreeze: 𝐕 ≠ 0", role: .confirm) {
                solver.isFrozen = false
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            solver.isFrozen ?
            Text("now frozen: 𝐕 = 0") : Text("now unfrozen: 𝐕 ≠ 0")
        }
    }
}
