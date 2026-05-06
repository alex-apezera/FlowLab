//
//  VerticalSlider.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 16.07.2025.
//
//MARK: - Selecting an across section for the temperature graph

import SwiftUI

/// Выбор сечения для графика температуры
struct VerticalSlider: View {
    @Binding var value: Double
    var `in`: ClosedRange<Double>
    var step: Double
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                Slider(value: $value, in: `in`, step: step)
                    .rotationEffect(.degrees(-90))
                    .frame(width: geometry.size.height)
                Spacer()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}
