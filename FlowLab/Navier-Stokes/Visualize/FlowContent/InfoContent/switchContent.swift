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
                .help("Select object to visualize")
                
                // Переключатели режимов решения и просмотра (ВКЛ/ВЫКЛ)
                
                /// процесс плавления
                Toggle(solver.params.allowMelt ? "𝗆❄️" : "𝗆💧", isOn: $solver.params.allowMelt).clipMode()
                    .keyboardShortcut("m", modifiers: [])
                    .help("Allow melting")
                
                /// линия фронта плавления на тепловых картах
                Toggle("🌗", isOn: $showFrontLine).clipMode()
                    .help("Show melting front line")
                    .keyboardShortcut("1", modifiers: [.option])
                
                /// наложение скоростей на тепловые карты
                Toggle("+𝐕", isOn: $addVelocityField).clipMode()
                    .help("Velocity overlay")
                    .keyboardShortcut("2", modifiers: [.option])
                
                /// цветовая схема тепловой карты
                Toggle("🌈", isOn: $toggleColorScheme).clipMode()
                    .help("Toggle thermal map color scheme")
                    .keyboardShortcut("3", modifiers: [.option])
                
                /// цвет стрелок вектора скорости
                Toggle("🚥 𝐕", isOn: $toggleVelocityColor).clipMode()
                    .help("Velocity color cheme toggle")
                    .keyboardShortcut("4", modifiers: [.option])
                
                // Плотность стрелок для скоростей
                Stepper("⇶ \(arrowDensity)") {
                    arrowDensity += 1
                } onDecrement: {
                    if arrowDensity > 1 {
                        arrowDensity  -= 1
                    }
                }
                .help("Set the velocity arrow density")
                .clipMode(150)
                
                // Масштаб стрелок для скоростей
                Stepper("⇡ \(arrowScale, specifier: "%.1f")") {
                    arrowScale *= 2
                } onDecrement: {
                    if arrowScale >= 0.5 {
                        arrowScale /= 2
                    }
                }
                .keyboardShortcut("6", modifiers: [.option])
                .help("Set the velocity arrow density")
                .clipMode(170)
                
                // Масштаб тепловой карты
                Stepper("↕️\(scale, specifier: "%.1f")") {
                    if scale < maximumScale {
                        withAnimation(.easeInOut(duration: 0.5)) { scale += step }
                    }
                } onDecrement: {
                    if scale > minimumScale {
                        withAnimation(.easeInOut(duration: 0.5)) { scale -= step }
                    }
                }
                .keyboardShortcut("7", modifiers: [.option])
                .help("Thermal map scale")
                .clipMode(160)
                
                // Сброс трансформаций тепловой карты
                Button(action: resetTransformations) {
                    Image(systemName: "arrow.2.circlepath.circle")
                }
                .keyboardShortcut(.escape, modifiers: [])
                .help("Reset transformations")
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
        .background { /// горячие клавиши: дублирование действий
            // Дублирование Picker
            ForEach(0..<visualizationOptions.count, id: \.self) { index in
                Button("") { selectedVisualization = index }
                    .keyboardShortcut(
                        KeyEquivalent(Character("\(index + 1)")),
                        modifiers: []
                    )
                    .hidden()
            }
            
            // Дублирование: плотность стрелок для скоростей
            Button("") { arrowDensity += 1 }
                .keyboardShortcut("5", modifiers: [.option])
            Button("") {
                if arrowDensity > 1 { arrowDensity  -= 1 }
            }
            .keyboardShortcut("5", modifiers: [.shift, .option])

            // Дублирование: масштаб стрелок для скоростей
            Button("") { arrowScale *= 2 }
                .keyboardShortcut("6", modifiers: [.option])
            Button("") {
                if arrowScale >= 0.5 { arrowScale /= 2 }
            }
            .keyboardShortcut("6", modifiers: [.shift, .option])

            // Дублирование: масштаб тепловой карты
            Button("") {
                if scale < maximumScale {
                    withAnimation(.easeInOut(duration: 0.5)) { scale += step }
                }
            }
            .keyboardShortcut("7", modifiers: [.option])
            Button("") {
                if scale > minimumScale {
                    withAnimation(.easeInOut(duration: 0.5)) { scale -= step }
                }
            }
            .keyboardShortcut("7", modifiers: [.shift, .option])

        }
    }
}
