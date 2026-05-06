//
//  TemperaturePlotView.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 13.07.2025.
//
//MARK: - Temperature distribution graph across sections

import SwiftUI

/// График распределения температуры по сечениям
struct TemperaturePlotView: View {
    let x: [Double]
    let y: [Double]
    let T: [[Double]]
    let avgTemp: Double
    
    @State private var currentYIndex: Double = 0
    private var Ly: Double { y.last! }
    private var ny: Int { y.count }
    private var nx: Int { x.count }
    let scaleX = iPadDevice ? 0.9 : 0.7
    let scaleY = iPadDevice ? 0.8 : 0.7
    
    var body: some View {
        GeometryReader { geo in
            let size = CGSize(width: scaleX * geo.size.width, height: scaleY * geo.size.height)
            HStack(alignment: .center, spacing: 10) {
                VStack {
                    // Mетка для выбора слоя Y
                    Text("Y,mm \(Int(currentYIndex/Double(ny)*Ly*1000))")
                        .font(.caption)
                    HStack {
                        // Вертикальный слайдер
                        VerticalSlider(value: $currentYIndex, in: 0...Double(ny-1), step: 1)
                        // Заголовок температурной оси
                        Text("Temperature")
                            .rotationEffect(.degrees(-90))
                            .frame(width: 150)
                            .font(.system(size: 12))
                            .position(x: 20, y: size.height / 2)
                    }
                    .frame(width: 20, height: size.height)
                }
                .frame(width: 40)
                
                VStack {
                    Text(iPadDevice ? "Temperature in the cross-section by height: T(x, y = Y)" : "T(x, y = Y)")
                    // График
                    ZStack {
                        // Область для рисования
                        TemperatureDrawingView(
                            x: x,
                            y: y,
                            T: T,
                            currentYIndex: Int(currentYIndex),
                            avgTemp: avgTemp
                        )
                        .frame(width: size.width, height: size.height)
                        .border(Color.gray)
                        
                        // Подписи осей
                        AxisXLabelsView(
                            x: x,
                            minTemp: minTemp,
                            maxTemp: maxTemp,
                            size: size
                        )
                    }
                }
                .padding()
                .onAppear {
                    // Начальное положение - середина по Y
                    currentYIndex = Double(ny-1) / 2
                }
            }
            .padding()
        }
    }
    
    // Вычисление минимальной температуры
    private var minTemp: Double {
        T[Int(currentYIndex)].min()!
    }
    
    // Вычисление максимальной температуры
    private var maxTemp: Double {
        T[Int(currentYIndex)].max()!
    }
}
