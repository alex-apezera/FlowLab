//
//  GravitySettings.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 28.11.2025.
//
//MARK: - Adjusting gravity settings

import SwiftUI

/// Корректировка настроек гравитации
struct GravitySettings: View {
    @ObservedObject var solver: NavierStokesSolver
    
    @State private var gravityRotationVelocity: Double = 1
    @State private var gravityInitialAngle: Int = 0
    @State private var initialAngleStep: Int = 30
    @State private var isGravitySynchronized: Bool = false
    @AppStorage("max degrees per day") var maxDegreesPerDay: Double = 48
    @AppStorage("max degrees per min") var maxDegreesPerMin: Double = 24
    @AppStorage("dayFormat") var dayFormat: Int = 0
    @AppStorage("minFormat") var minFormat: Int = 0

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Initial angle 𝐆")) {
                    Stepper(value: $gravityInitialAngle, in: 0...360, step: initialAngleStep) {
                        HStack {
                            Text("\(gravityInitialAngle)°")
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 30, height: 30)
                                Image(systemName: "arrow.down")
                                    .rotationEffect(.degrees(Double(gravityInitialAngle)))
                            }
                        }
                    }
                    EditIntValue(text: "initial angle step \(initialAngleStep)º", value: $initialAngleStep)
                }
                
                Section(header: Text("Rotation velocity 𝐆")) {
                    let velFormat: String = solver.allowMelt ? "%.\(dayFormat)f" : "%.\(minFormat)f"
                    let dimension: String = solver.allowMelt ? "º/day" : "º/min"
                    let maxValue: Double = solver.allowMelt ? maxDegreesPerDay : maxDegreesPerMin
                    HStack {
                        Text("\(gravityRotationVelocity, specifier: velFormat) \(dimension)")
                        Slider(value: $gravityRotationVelocity, in: 0...maxValue)
                    }
                    EditValue(text: "max value \(dimension)", value: solver.allowMelt ? $maxDegreesPerDay : $maxDegreesPerMin)
                    EditIntValue(text: "decimal places \(dimension)", value: solver.allowMelt ? $dayFormat : $minFormat)
                }
                
                Section(header: Text("Field synchronization with rotation 𝐆")) {
                    Toggle("ON/OFF synchronization", isOn: $isGravitySynchronized)
                }
                Section(header: Text("𝐆 magnitude")) {
                    EditValue(text: "magnitude value [m/s²]", value: $solver.gMagnitude)
                }
            }
            .padding()
        }
        .onAppear(perform: loadSettings)
        .onDisappear(perform: saveSettings)
        .navigationModifier("Gravity")
        .done
    }
    
    private func loadSettings() {
        gravityInitialAngle = Int(solver.params.gravityInitialAngle)
        gravityRotationVelocity = solver.params.gravityRotationVelocity
        isGravitySynchronized = solver.params.isGravitySynchronized
    }
    
    private func saveSettings() {
        // Обновляем параметры решателя
        solver.params.gravityInitialAngle = Double(gravityInitialAngle)
        solver.params.gravityRotationVelocity = gravityRotationVelocity
        solver.params.isGravitySynchronized = isGravitySynchronized
    }

}
