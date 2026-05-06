//
//  EditValue.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 28.12.2025.
//
//MARK: - Editing of the String Value

import SwiftUI

/// Редактирование текста
struct TextEdit: View {
    @Binding var editText: Bool
    @Binding var text: String
    let title: String
    let prompt: String
    
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

/// Редактирование величины с плавающей точкой
struct EditValue: View {
    let text: String
    @Binding var value: Double
    @State var number: Double = 0
    let prompt = "Enter a double value"
    
    var body: some View {
        HStack {
            Text(text).foregroundColor(.secondary)
            Spacer()
            TextField(prompt, value: $number, formatter: numberFormatter)
                .editText()
                .onSubmit {value = number}
        }
        .onAppear{number = value}
    }
}

/// Редактирование целочисленнной величины
struct EditIntValue: View {
    let text: String
    @Binding var value: Int
    @State var number: Int = 0
    let prompt = "Enter an integer value"
    
    var body: some View {
        HStack {
            Text(text).foregroundColor(.secondary)
            Spacer()
            TextField(prompt, value: $number, formatter: numberFormatter)
                .editText()
                .onSubmit {value = number}
        }
        .onAppear{number = value}
    }
}

/// Редактирование строки с указанием надписи
func editStringValue(_ text: String, _ value: Binding<String>) -> some View {
    HStack {
        Text(text).frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(.secondary)
        Spacer()
        TextField("Enter digital value", text: value).editText()
    }
}

/// Редактирование строки без указания надписи
func editString(_ prompt: String, _ value: Binding<String>) -> some View {
    TextField(prompt, text: value).editText(width: .infinity)
}

