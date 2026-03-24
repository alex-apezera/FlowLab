//
//  setColor.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 06.11.2025.
//

import SwiftUI

//MARK: - Цвет ячейки (Синий для минимума, красный для максимума)

enum ColorMode {
    case rainbow, twoColor, velColor, white
}

func setColor(_ value: Double, minValue: Double, maxValue: Double, mode: ColorMode) -> Color {
    
    guard maxValue != minValue else {
        // Если диапазон нулевой, вернуть безопасное значение или цвет по умолчанию
        return Color.white // Например, белый цвет
        // return Color(hue: 0.0, saturation: 0.0, brightness: 0.0) // Или черный
    }
    
    let normalized = (value - minValue) / (maxValue - minValue)
    
    // Также полезно убедиться, что normalized находится в диапазоне 0.0 до 1.0
    // хотя в большинстве случаев это не вызовет EXC_BREAKPOINT,
    // это предотвратит появление странных цветов.
    let clampedNormalized = max(0.0, min(1.0, normalized))

    let hue = 1.0 - clampedNormalized

    switch mode {
    case .rainbow:
        return Color(hue: 0.7 * hue, saturation: 0.6, brightness: 0.8)
    case .twoColor:
        return Color(red: normalized, green: 0.5, blue: 1 - normalized)
    case .velColor:
//        return Color(red: clampedNormalized, green: 0.5, blue: 1 - clampedNormalized)
        return Color(hue: 0.8 * hue, saturation: 0.7, brightness: 1.0)
    case .white:
        return Color.white
    }
}
