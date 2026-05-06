//
//  ViewExtensions.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 20.11.2025.
//
//MARK: - View Extensions for Modifiers

import SwiftUI

extension View {
    
    /// Навигационный заголовок
    func navigationModifier(_ title: String) -> some View {
        modifier(NavigationModifier(title: title))
    }
    
    /// Завершение презентации по галочке
    func done(_ isPresented: Binding<Bool>) -> some View {
        modifier(BarItemModifier(isPresented: isPresented))
    }
    
    /// Возврат на предыдущий уровень
    var done: some View {
        modifier(NavigationDone())
    }
    
    /// Скрытие подписи при возврате на предыдущий уровень
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    /// Моргание
    func blinking(duration: Double = 0.5) -> some View {
        modifier(BlinkViewModifier(duration: duration))
    }
    
    /// Обработка Текстового поля
    func editText(_ use: UIKeyboardType = .default, width: CGFloat = 100) -> some View {
        modifier(TextFieldModifier(use: use, widh: width))
    }
    
    /// Эффект градиента
    var gradientModifier: some View {
        modifier(GradientEffect())
    }
    
    /// Эффект обрезания по форме
    func clipMode(_ width: CGFloat = 120) -> some View {
        modifier(ClipMode(width: width))
    }
    
    /// Внутренняя секция
    var sectionModifier: some View {
        modifier(SectionModifier())
    }
    
    /// Подпись для графика температуры
    func tLabel(offset: CGFloat, alignment: Alignment) -> some View {
        modifier(TempLabel(offset: offset, alignment: alignment))
    }
}
