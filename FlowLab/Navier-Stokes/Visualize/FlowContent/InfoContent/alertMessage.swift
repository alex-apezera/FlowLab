//
//  alertMessage.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 10.02.2026.
//
//MARK: - Divergence Status Pop-up Message

import SwiftUI
extension Visualizator {
  
    /// Всплывающее сообщение о состоянии расходимости
    @ViewBuilder var alertMessage: some View {
        
        if !solver.statusMessage.isEmpty {
            VStack {
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.shield.fill")
                        .foregroundColor(.yellow)
                    
                    Text(solver.statusMessage)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Кнопка принудительного закрытия (Dismiss)
                    Button {
                        solver.statusMessage = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding()
                .background(Color.black.opacity(0.85))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.5), lineWidth: 1)
                )
            }
            .padding()
            .transition(.move(edge: .top).combined(with: .opacity))
            .zIndex(100) // Поверх всего
        }
    }
    
}
