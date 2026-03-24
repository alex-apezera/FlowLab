
//  numberFormatter.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 04.12.2025.
//


import SwiftUI
// Используем NumberFormatter для корректного отображения и ввода Double
let numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.maximumFractionDigits = 10 // Точность
    formatter.minimumFractionDigits = 0
    return formatter
}()

struct TextEdit: View {
    @Binding var editText: Bool
    @Binding var text: String
    let title: String
    let prompt: String
    
//MARK: - Input new text
    var body: some View {
        VStack {
            Text(title).opacity(0.5)
            TextField(prompt, text: $text)
            .editText()
            .onSubmit { withAnimation {editText = false} }
        }
        .padding(10)
        .background(.thinMaterial)
        .cornerRadius(15)
    }
}

