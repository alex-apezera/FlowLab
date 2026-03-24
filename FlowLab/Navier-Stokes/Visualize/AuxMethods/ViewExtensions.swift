//
//  ViewExtensions.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 20.11.2025.
//

import SwiftUI

extension View {
    
    func navigationModifier(_ title: String) -> some View {
        modifier(NavigationModifier(title: title))
    }
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    func blinking(duration: Double = 0.2) -> some View {
        modifier(BlinkViewModifier(duration: duration))
    }
    func editText(_ use: UIKeyboardType = .decimalPad) -> some View {
        modifier(TextFieldModifier(use: use))
    }
    var gradientModifier: some View {
        modifier(GradientEffect())
    }
    func clipMode(_ width: CGFloat = 120) -> some View {
        modifier(ClipMode(width: width))
    }
    var sectionModifier: some View {
        modifier(SectionModifier())
    }
}
