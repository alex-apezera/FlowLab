//
//  GravitySettings.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 28.11.2025.
//
import SwiftUI

//MARK: - Корректировка настроек гравитации

struct GravitySettings: View {
    @ObservedObject var solver: NavierStokesSolver
    @Environment(\.presentationMode) var presentationMode
    
    @State private var gravityRotationVelocity: Double = 1
    @State private var gravityInitialAngle: Int = 0
    @State private var isGravitySynchronized: Bool = false

    var body: some View {
        NavigationView {
//            VStack {
                Form {
                    Section(header: Text("Начальный угол гравитации")) {
                        Stepper(value: $gravityInitialAngle, in: 0...360, step: 30) {
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
                    }
                    
                    Section(header: Text("Примерная угловая скорость вращения вектора")) {
                        HStack {
                            Text("\(gravityRotationVelocity, specifier: "%.1f") \(solver.allowMelt ? "[º/day]" : "[º/s]")")
                            Slider(value: $gravityRotationVelocity, in: 0...24)
                        }
                    }
                    
                    Section(header: Text("Синхронизация полей с углом поворота")) {
                        Toggle("Включить синхронизацию", isOn: $isGravitySynchronized)
                    }
                }
                .padding()
//            }
        }
        .onAppear(perform: loadSettings)
        .navigationModifier("Гравитация")
        .navigationBarItems(
            trailing: Button("Готово") {
                saveSettings()
                presentationMode.wrappedValue.dismiss()
            }
        )
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
