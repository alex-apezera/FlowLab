//
//  LabelsView.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 16.07.2025.
//

import SwiftUI

struct TemperatureLabelsView: View {
    let minTemp: Double
    let maxTemp: Double
    let size: CGSize
    
    var body: some View {
        VStack {
            // Максимальное значение (вверху)
            Text(String(format: "Max: %.0f", maxTemp))
                .font(.caption)
                .bold()
                .padding(4)
                .background(.thinMaterial)
                .cornerRadius(4)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .offset(y: 10)
            
            Spacer()
            
            // Минимальное значение (внизу)
            Text(String(format: "Min: %.0f", minTemp))
                .font(.caption)
                .bold()
                .padding(4)
                .background(.thinMaterial)
                .cornerRadius(4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .offset(y: -10)
        }
        .frame(height: size.height)
    }
}
