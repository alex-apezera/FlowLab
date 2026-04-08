//
//  switchContent.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 17.11.2025.
//

import SwiftUI
extension Visualizator {
    
    /// Управление просмотром результатов решения
    @ViewBuilder
    var switchContent: some View {
        let step: CGFloat = 0.1
        let minimumScale: CGFloat = 0.5
        let maximumScale: CGFloat = 2.0
        
        HStack/*(spacing: 20)*/ {
            
            // Переключение объекта наблюдения
            Picker("Switcher", selection: $selectedVisualization) {
                ForEach(0..<visualizationOptions.count, id: \.self) { index in
                    Text(visualizationOptions[index]).tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            // Переключатели режимов решения и просмотра (ВКЛ/ВЫКЛ)
            
            /// процесс плавления
            Toggle("❄️", isOn: $solver.params.allowMelt).clipMode()
            /// линия фронта плавления на тепловых картах
            Toggle("🌗", isOn: $showFrontLine).clipMode()
            /// наложение скоростей на тепловые карты
            Toggle("+𝐕", isOn: $addVelocityField).clipMode()
            /// цветовая схема тепловой карты
            Toggle("🌈", isOn: $toggleColorScheme).clipMode()
            /// цвет стрелок вектора скорости
            Toggle("🚥 𝐕", isOn: $toggleVelocityColor).clipMode()
            
            // Увеличение/уменьшение плотности стрелок скоростей
            Stepper("⇶⇉➔  \(arrowDensity)") {
                if arrowDensity < 5 { arrowDensity += 1 }
            } onDecrement: {
                if arrowDensity > 1 { arrowDensity -= 1 }
            }
            .clipMode(180)
            
            // Масштабирование стрелок для скоростей
            Stepper("⬆︎📶  \(arrowScale, specifier: "%.1f")") {
                if arrowScale < 20 { arrowScale += 0.5 }
            } onDecrement: {
                if arrowScale > 0 { arrowScale -= 0.25 }
            }
            .clipMode(200)
            
            // Увеличение/уменьшение масштаба тепловой карты
            Stepper("↕️  \(scale, specifier: "%.1f")") {
                if scale <= maximumScale { withAnimation(.easeInOut(duration: 0.5)) { scale += step } }
                } onDecrement: {
                    if scale >= minimumScale { withAnimation(.easeInOut(duration: 0.5)) { scale -= step } }
            }
            .clipMode(180)
            
            // Сброс трансформаций тепловой карты
            Button(action: resetTransformations) {
                Image(systemName: "arrow.2.circlepath.circle")
            }
            
        }
        // Управление запуском/остановкой процесса плавления
        .onChange(of: solver.step) { _, newValue in
            if newValue > solver.params.startMeltingStep {
                solver.params.allowMelt = true
            } else {
                solver.params.allowMelt = false
            }
        }
        .onChange(of: solver.params.allowMelt) { _, newValue in
            if newValue {
                if solver.latentHeat >= 1e6 { solver.params.allowMelt = false }
                else { solver.params.startMeltingStep = 0 }
            } else {
                solver.params.startMeltingStep =  1000000
            }
        }
        .contentShape(Rectangle())  /// зона кликабельности
        .padding(.horizontal)
    }
}
