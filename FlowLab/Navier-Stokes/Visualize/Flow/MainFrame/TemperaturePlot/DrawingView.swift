//
//  TempetatureDrawingView.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 16.07.2025.
//

import SwiftUI

struct TemperatureDrawingView: View {
    let x: [Double]
    let y: [Double]
    let T: [[Double]]
    let currentYIndex: Int
    let avgTemp: Double
    
    var body: some View {
//        let (minTemp, maxTemp) = fieldValueLimits(T)
        GeometryReader { geometry in
            // Основной контейнер для рисования
            ZStack {
                // Сетка
                GridView(
                    x: x,
                    y: y
                )
                
                // Кривая температуры
                TemperatureCurveView(
                    x: x,
                    temperatures: T[currentYIndex],
                    minTemp: minTemp,
                    maxTemp: maxTemp,
                    avgTemp: avgTemp
                )
                
                // Подписи min и max
                TemperatureLabelsView(
                    minTemp: minTemp,
                    maxTemp: maxTemp,
                    size: geometry.size
                )
            }
        }
    }
   
    private var minTemp: Double {
        T[currentYIndex].min() ?? 0
    }
    
    private var maxTemp: Double {
        T[currentYIndex].max() ?? 1
    }
    
}

