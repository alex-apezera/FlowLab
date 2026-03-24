//
//  TemperatureCurveView.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 16.07.2025.
//

import SwiftUI

struct TemperatureCurveView: View {
    let x: [Double]
    let temperatures: [Double]
    let minTemp: Double
    let maxTemp: Double
    let avgTemp: Double
    
    var body: some View {
        
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            // Основная кривая
            Path { path in
                guard !temperatures.isEmpty else { return }
                // Начальная точка
                let firstPoint = CGPoint(
                    x: transformX(width, index: 0),
                    y: transformY(height, temp: temperatures[0])
                )
                path.move(to: firstPoint)
                // Кривая вдоль оси Х
                for i in 0..<temperatures.count {
                    let nextPoint = CGPoint(
                        x: transformX(width, index: i),
                        y: transformY(height, temp: temperatures[i])
                    )
                    path.addLine(to: nextPoint)
                }
            }
            .stroke(Color.blue, lineWidth: 3)
            
            // Средняя температура (прямая)
            Path { path in
                let firstPoint = CGPoint(
                    x: transformX(width, index: 0),
                    y: transformY(height, temp: avgTemp)
                )
                path.move(to: firstPoint)
                // Прямая вдоль оси Х
                for i in 0..<temperatures.count  {
                    let nextPoint = CGPoint(
                        x: transformX(width, index: i),
                        y: transformY(height, temp: avgTemp)
                    )
                    path.addLine(to: nextPoint)
                }
            }
            .stroke(Color.orange, style: StrokeStyle(lineWidth: 2, dash: [5]))
            // Надпись
            Text("Avg: \(avgTemp, specifier: "%.2f")").bold()
                .font(.caption).padding(4)
                .foregroundColor(.primary)
                .background(.thinMaterial)
                .cornerRadius(4)
                .offset(x: width-180, y: transformY(height, temp: avgTemp))
        }
}
    
    // Методы преобразования координат

    private var xMin: Double { x.first ?? 0 }
 
    private var xMax: Double { x.last ?? 1 }
    
    private func transformX(_ width: CGFloat, index: Int) -> CGFloat {
        return CGFloat((x[index] - xMin) / (xMax - xMin)) * width
    }
    
    private func transformY(_ height: CGFloat, temp: Double) -> CGFloat {
        let normalized = (temp - minTemp) / (maxTemp - minTemp)
        return height * (1 - CGFloat(normalized))
    }

}

