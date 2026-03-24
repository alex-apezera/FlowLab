//
//  plotForHeat.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 21.11.2025.
//


import SwiftUI
extension Visualizator {
    
//MARK: - График зависимости тепловых потоков от времени (time)
    @ViewBuilder
    func plotForHeat(_ values: [Double], _ values1: [Double], _ time: Double, xTitle: String, yTitle: String,  _ frameHeight: CGFloat) -> some View {
    
        let maxValue = max(values.max() ?? 1.0, values1.max() ?? 1.0)
        let minValue = min(values.min() ?? 0.0, values1.min() ?? 0.0)
        let range = maxValue - minValue > 0 ? maxValue - minValue : 1.0
        let maxTime = time
        let minTime = solver.allowMelt ? solver.initialTime : 0.0
        let rangeTime = maxTime - minTime > 0 ? maxTime - minTime : 1.0
        let fontValueSize: CGFloat = iPadDevice ? 10 : 8
        let s_rightWall = solver.allowMelt ? "Melt front" : "Cold wall"
        
        VStack {
            //Заголовок
            Text("\(yTitle): Hot wall = \(values.last ?? 0, specifier: "%.4f"), \(s_rightWall) = \(values1.last ?? 0, specifier: "%.4f")")
                .font(iPadDevice ? .caption : Font.system(size: 8))
                .padding(.bottom, 2)
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                let stepWidth = width / CGFloat(values.count)
                
                // Фон графика
                Rectangle()
                    .fill(Color.white.opacity(0.15))
                    .border(Color.gray, width: 1)
                
                // Оси координат
                Path { path in
                    // Ось X
                    path.move(to: CGPoint(x: 0, y: height))
                    path.addLine(to: CGPoint(x: width, y: height))
                    
                    // Ось Y
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: 0, y: height))
                }
                .stroke(Color.black, lineWidth: 1)
                
                // Линии сетки и подписи
                ForEach(0..<5, id: \.self) { i in
                    let yValue = minValue + range * Double(i)/4
                    let yPos = height * (1 - CGFloat(i)/4)
                    
                    // Горизонтальные линии
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: yPos))
                        path.addLine(to: CGPoint(x: width, y: yPos))
                    }
                    .stroke(Color.black.opacity(0.5), lineWidth: 0.5)
                    
                    // Подписи оси Y со сдвигом внутрь графика
                    Text("\(yValue, specifier: "%.3e")")
                        .font(.system(size: fontValueSize))
                        .position(x: 30, y: yPos - 5)
                }
                
                // Значения величин по оси X
                ForEach(0..<4, id: \.self) { i in
                    let xValue = minTime + rangeTime * Double(3-i)/3
                    let xPos = width * (1 - CGFloat(i)/3)
                    let timeString = solver.allowMelt ? formattedTime(xValue) : String(format: "%.2f", xValue)

                    Path { path in /// засечка высотой в 4 пункта
                        path.move(to: CGPoint(x: xPos, y: height))
                        path.addLine(to: CGPoint(x: xPos, y: height + 4))
                    }
                    .stroke(lineWidth: 1)
                    
                    let xPosShift = /// корректировка позиции
                        i == 0 ? xPos - 30 :
                        i == 3 ? xPos + 30 : xPos
                    Text("\(timeString)") /// значение со сдвигом вниз от оси х
                        .font(.system(size: fontValueSize))
                        .position(x: xPosShift, y: height + 10)
                }
                
                // Заголовок оси X по центру со сдвигом вниз от оси х
                Text(xTitle)
                    .font(.system(size: fontValueSize))
                    .position(x: width/2, y: height + 10)
                
                // Заголовок оси Y с вертикальным расположением
                Text(yTitle)
                    .font(.system(size: fontValueSize))
                    .rotationEffect(.degrees(-90))
                    .position(x: -8, y: height/2)
                
                // Кривые зависимостей values от времени (time)
                plotHeatLine(values, stepWidth, height, minValue, range, .red)
                plotHeatLine(values1, stepWidth, height, minValue, range, .blue)

            }
            .padding(.bottom,5)
            .padding(.horizontal,5)
        }
        .frame(height: frameHeight)
    }
    
//MARK: - Кривая зависимости values от времени

    private func plotHeatLine(_ values: [Double], _ stepWidth: CGFloat, _ height: CGFloat, _ minValue: Double, _ range: Double, _ color: Color) -> some View {
        Path { path in
            for (index, value) in values.enumerated() {
                let x = CGFloat(index) * stepWidth
                let y = height - CGFloat((value - minValue) / range) * height
                if index == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
        }
        .stroke(color, lineWidth: 2)
    }


}
