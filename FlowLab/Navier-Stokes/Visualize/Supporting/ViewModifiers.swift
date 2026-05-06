//
//  ViewModifiers.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 20.11.2025.
//
//MARK: - View Modifiers Structures

import SwiftUI

/// Navigation title
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

/// Завершение презентации по галочке
struct BarItemModifier: ViewModifier {
    let isPresented: Binding<Bool>
    func body(content: Content) -> some View {
        content
            .navigationBarItems(trailing: Button(action: {
                isPresented.wrappedValue = false
            }) {
                Image(systemName: "checkmark")
            })
    }
}

/// Возврат на предыдущий уровень
struct NavigationDone: ViewModifier {
    @Environment(\.presentationMode) private var presentationMode
    func body(content: Content) -> some View {
        content
            .navigationBarItems(trailing: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "checkmark")
            })
    }
}

/// Эффект градиента
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

/// Эффект моргания
struct BlinkViewModifier: ViewModifier {
    let duration: Double
    @State var blink: Bool = false
    func body(content: Content) -> some View {
        content
            .opacity(blink ? 0.2 : 1)
            .animation(.easeOut(duration: duration).repeatForever(), value: blink)
            .onAppear { withAnimation { blink = true } }
    }
}

/// Текстовое поле
struct TextFieldModifier: ViewModifier {
    let use: UIKeyboardType
    let widh: CGFloat
    func body(content: Content) -> some View {
        content
            .textFieldStyle(.roundedBorder)
            .foregroundColor(.teal)
            .font(.callout)
            .keyboardType(use)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(.orange, lineWidth: 0.5))
            .frame(maxWidth: widh)
    }
}


/// Эффект обрезания по форме
struct ClipMode: ViewModifier {
    let width: CGFloat
    func body(content: Content) -> some View {
        content
            .padding(5)
            .frame(width: width)
            .background(Color.gray.opacity(0.15)) // Цвет фона
            .clipShape(RoundedRectangle(cornerRadius: 15)) // Обрезаем фон по форме капсулы
            .scaleEffect(0.7)
    }
}

/// Внутренняя секция
struct SectionModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(5)
            .background(.thickMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

/// Подпись для графика температуры
struct TempLabel: ViewModifier {
    let offset: CGFloat
    let alignment: Alignment
    func body(content: Content) -> some View {
        content
            .font(.caption)
            .bold()
            .padding(4)
            .background(.thinMaterial)
            .cornerRadius(4)
            .frame(maxWidth: .infinity, alignment: alignment)
            .offset(y: offset)
    }
}
