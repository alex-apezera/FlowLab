//
//  EditValue.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 28.12.2025.
//

import SwiftUI

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

struct EditIntValue: View {
    let text: String
    @Binding var value: Int
    @State var number: Int = 0
    let prompt = "Enter a integer value"
    
    var body: some View {
        HStack {
            Text(text).foregroundColor(.secondary)
            Spacer()
            TextField(prompt, value: $number, formatter: numberFormatter)
                .editText(.numberPad)
                .onSubmit {value = number}
        }
        .onAppear{number = value}
    }
}
