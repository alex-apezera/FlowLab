//
//  switchContent.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 17.11.2025.
//
//MARK: - Managing the viewing of solution results

import SwiftUI
extension Visualizator {
    
    /// Управление просмотром результатов решения
    @ViewBuilder var switchContent: some View {
        let step: CGFloat = 0.1
        let minimumScale: CGFloat = 0.5
        let maximumScale: CGFloat = 2.0
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                
                // Переключение объекта наблюдения
                Button { withAnimation(.easeInOut(duration: 0.5)) {shortKeys.toggle()}
                } label: {
                    Image(systemName:  "questionmark.square")
                }.keyboardShortcut("/", modifiers: [.shift])

                Picker("Switcher", selection: $selectedVisualization) {
                    ForEach(0..<visualizationOptions.count, id: \.self) { index in
                        Text(visualizationOptions[index]).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                // Переключатели режимов решения и просмотра (ВКЛ/ВЫКЛ)
                
                /// процесс плавления
                Toggle(solver.params.allowMelt ? "𝗆❄️" : "𝗆💧", isOn: $solver.params.allowMelt).clipMode()
                    .keyboardShortcut("m", modifiers: [])
                /// линия фронта плавления на тепловых картах
                Toggle("🌗", isOn: $showFrontLine).clipMode()
                /// наложение скоростей на тепловые карты
                Toggle("+𝐕", isOn: $addVelocityField).clipMode()
                /// цветовая схема тепловой карты
                Toggle("🌈", isOn: $toggleColorScheme).clipMode()
                /// цвет стрелок вектора скорости
                Toggle("🚥 𝐕", isOn: $toggleVelocityColor).clipMode()
                    .background {
                        ForEach(0..<visualizationOptions.count, id: \.self) { index in
                            Button("") { selectedVisualization = index }
                                .keyboardShortcut(
                                    KeyEquivalent(Character("\(index + 1)")),
                                    modifiers: []
                                )
                                .hidden()
                        }
                    }
                
                // Сброс трансформаций тепловой карты
                Button(action: resetTransformations) {
                    Image(systemName: "arrow.2.circlepath.circle")
                }
                .keyboardShortcut(.escape, modifiers: [])
                .help("Thermal map scale")
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
