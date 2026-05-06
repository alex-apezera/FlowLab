//
//  LabelsView.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 16.07.2025.
//
//MARK: - Diagonal marks for minimum and maximum temperature

import SwiftUI

/// Диагональные метки минимальной и максимальной температуры
struct TemperatureLabelsView: View {
    let minTemp: Double
    let maxTemp: Double
    let size: CGSize
    
    var body: some View {
        VStack {
            // Максимальное значение (вверху)
            Text(String(format: "Max: %.0f", maxTemp))
                .tLabel(offset: 10, alignment: .trailing)
            
            Spacer()
            
            // Минимальное значение (внизу)
            Text(String(format: "Min: %.0f", minTemp))
                .tLabel(offset: -10, alignment: .leading)
        }
        .frame(height: size.height)
    }
}
