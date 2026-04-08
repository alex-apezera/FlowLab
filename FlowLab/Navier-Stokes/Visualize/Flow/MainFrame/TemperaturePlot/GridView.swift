//
//  GridView.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 16.07.2025.
//

import SwiftUI

struct GridView: View {
    let x: [Double]
    let y: [Double]

    private var xMin: Double { x.first ?? 0 }
    private var xMax: Double { x.last ?? 1 }
    private var yMin: Double { y.first ?? 0 }
    private var yMax: Double { y.last ?? 1 }
    
    var body: some View {
        Canvas { context, size in
            // Конфигурация линий
            let gridStyle = StrokeStyle(lineWidth: 1, dash: [2])
            let axisStyle = StrokeStyle(lineWidth: 2)
            
            // Преобразование координат
            func transformX(_ xVal: Double) -> CGFloat {
                size.width * CGFloat((xVal - xMin) / (xMax - xMin))
            }
            
            func transformY(_ yVal: Double) -> CGFloat { /// Y = 0  внизу
                size.height * (1 - CGFloat((yVal - yMin) / (yMax - yMin)))
            }
            
            // Ось X
            context.stroke(
                Path { path in
                    path.move(to: CGPoint(x: 0, y: size.height))
                    path.addLine(to: CGPoint(x: size.width, y: size.height))
                },
                with: .color(.black),
                style: axisStyle
            )
            
            // Ось Y
            context.stroke(
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: 0, y: size.height))
                },
                with: .color(.black),
                style: axisStyle
            )
            
            // Вертикальные линии сетки (X)
            for xVal in x {
                let xPos = transformX(xVal)
                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: xPos, y: 0))
                        path.addLine(to: CGPoint(x: xPos, y: size.height))
                    },
                    with: .color(.gray),
                    style: gridStyle
                )
            }
            
            // Горизонтальные линии сетки (Y)
            for yVal in y {
                let yPos = transformY(yVal)
                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: yPos))
                        path.addLine(to: CGPoint(x: size.width, y: yPos))
                    },
                    with: .color(.gray),
                    style: gridStyle
                )
            }
        }
        .drawingGroup() // Включает Metal-акселерацию для Canvas
    }
    
}

