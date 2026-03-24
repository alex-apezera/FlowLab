//
//  Plot.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 17.07.2025.
//

import SwiftUI
extension Visualizator {
    
    //MARK: - График диагностики в зависимости от вычислительного шага
    @ViewBuilder
    func plot(values: [Double], target: Double, color: Color, yTitle: String,  _ frameHeight: CGFloat) -> some View {
        
        let stepValue = values.count > 1 ? values.count - 1 : 1
        let maxValue = values.max() ?? 300.0
        let minValue = values.min() ?? 0.0
        let range = maxValue - minValue > 0 ? maxValue - minValue : 1.0
        let maxStep = stepValue
        let minStep = stepValue > solver.params.countsLimit ? stepValue - solver.params.countsLimit : 0 /// при превышении лимита - шкала Х сдвигается
        let rangeStep = maxStep - minStep > 0 ? maxStep - minStep : 1
        let fontValueSize: CGFloat = iPadDevice ? 8 : 6
        
        VStack {
            //Заголовок
            Text("\(yTitle): \(values.last ?? 0, specifier: "%.5f")")
                .font(iPadDevice ? .caption : Font.system(size: 8))
                .padding(.bottom, 2)
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                let stepWidth = width / CGFloat(rangeStep)
                
                // Фон графика
                Rectangle()
                    .fill(Color.white.opacity(0.35))
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
                    .stroke(Color.gray.opacity(0.8), lineWidth: 0.5)
                    
                    // Подписи оси Y со сдвигом внутрь графика
                    Text("\(yValue, specifier: "%.3e")")
                        .font(.system(size: fontValueSize))
                        .position(x: 25, y: yPos - 5)
                }
                
                // Значения величин по оси X
                ForEach(0..<4, id: \.self) { i in
                    let xValue = minStep + rangeStep * (3-i)/3
                    let xPos = width * (1 - CGFloat(i)/3)
                    
                    Path { path in /// засечка высотой в 4 пункта
                        path.move(to: CGPoint(x: xPos, y: height))
                        path.addLine(to: CGPoint(x: xPos, y: height + 4))
                    }
                    .stroke(lineWidth: 1)

                    let xPosShift = /// корректировка позиции
                        i == 0 ? xPos - 20 :
                        i == 3 ? xPos + 20 : xPos
                    Text("\(Double(xValue), specifier: "%.3e")") /// значение
                        .font(.system(size: fontValueSize))
                        .position(x: xPosShift, y: height + 10)
                }
                
                // Заголовок оси X по центру
                Text("step")
                    .font(.system(size: fontValueSize))
                    .position(x: width/2, y: height + 10)
                
                // Заголовок оси Y с вертикальным расположением
                Text(yTitle)
                    .font(.system(size: fontValueSize))
                    .rotationEffect(.degrees(-90))
                    .position(x: -8, y: height/2)
                
                // Кривая зависимости value от шага (step)
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
                
                // Целевое значение
                Path { path in
                    let targetY = height - CGFloat(target / maxValue) * height
                    path.move(to: CGPoint(x: 0, y: targetY))
                    path.addLine(to: CGPoint(x: width, y: targetY))
                }
                .stroke(Color.orange, style: StrokeStyle(lineWidth: 1, dash: [5]))
                
                Text("Цель: \(target, specifier: "%.4f")")
                    .font(.system(size: fontValueSize))
                    .foregroundColor(.orange)
                    .position(x: width - 40, y: height - 30)
            }
            .padding(.bottom,5)
            .padding(.horizontal,5)
        }
        .frame(height: frameHeight)
    }

}
