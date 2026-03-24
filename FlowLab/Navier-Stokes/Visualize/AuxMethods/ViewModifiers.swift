//
//  ViewModifiers.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 20.11.2025.
//

import SwiftUI

//MARK: - Navigation modifier
struct NavigationModifier: ViewModifier {
    let title: String
    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .buttonStyle(.borderless)
            .listStyle(.inset)
            .background(.thinMaterial)
    }
}

//MARK: - Gradient
struct GradientEffect: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color.white)
            .padding(5)
            .background(LinearGradient(gradient: Gradient(colors: [Color.indigo, Color.cyan]), startPoint: .bottomLeading, endPoint: .topTrailing))
            .cornerRadius(10.0)
            .shadow(radius: 5)
    }
}

//MARK: - Blinking Modifier
struct BlinkViewModifier: ViewModifier {
    let duration: Double
    @State var blink: Bool = false
    func body(content: Content) -> some View {
        content
            .opacity(blink ? 0 : 1)
            .animation(.easeOut(duration: duration).repeatForever(), value: blink)
            .onAppear { withAnimation { blink = true } }
    }
}

//MARK: - TextField
struct TextFieldModifier: ViewModifier {
    let use: UIKeyboardType 
    func body(content: Content) -> some View {
        content
            .textFieldStyle(.roundedBorder)
            .foregroundColor(.teal)
            .font(.callout)
            .keyboardType(use)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(.orange, lineWidth: 0.5))
    }
}


//MARK: - Clipshape around
struct ClipMode: ViewModifier {
    let width: CGFloat
    func body(content: Content) -> some View {
        content
            .padding(5)
            .frame(width: width)
            .background(Color.gray.opacity(0.15)) // Цвет фона
            .clipShape(RoundedRectangle(cornerRadius: 15)) // Обрезаем фон по форме капсулы
            .scaleEffect(0.7)
//            .padding(.trailing, 20)
    }
}
//MARK: - Section inside
struct SectionModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(5)
            .background(.thickMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}
