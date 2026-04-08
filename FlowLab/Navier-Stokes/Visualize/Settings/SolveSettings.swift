//
//  SolveSettings.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 28.11.2025.
//
import SwiftUI

//MARK: - Корректировка настроек вычислительного процесса

struct SolveSettings: View {
    @ObservedObject var solver: NavierStokesSolver
    @Environment(\.presentationMode) var presentationMode
    
    @State private var maxIterations: String = ""
    @State private var relaxationFactor: String = ""
    @State private var criticalError: String = ""
    @State private var countsLimit: String = ""
    @State private var maxHistorySteps: String = ""
    @State private var deltaStable: Double = 0.1
    @State private var hiStabLimit: Double = 0.3
    @State private var lowStabLimit: Double = 0.2
    @State private var tolerancePsi: String = ""

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Регулирование временнóго шага Δt через число Куранта - CFL" )) {
                        HStack {
                            Text("diffusion F: \(solver.d_Factor, specifier: "%.1f")")
                            Slider(value: $solver.d_Factor, in: 0.4...3)
                        }

                        HStack {
                            Text("limits CFL: \(lowStabLimit, specifier: "%.2f") ÷ \(hiStabLimit, specifier: "%.2f")")
                            Slider(value: $lowStabLimit, in: 0.1...1)
                        }
                        HStack {
                            Text("Δ limits CFL: \(deltaStable, specifier: "%.2f")")
                            Slider(value: $deltaStable, in: 0.05...0.3)
                        }
                        Text("● Вычисляемое CFL = Δt・𝐕₁/Δx₀; при CFL ≤ lowLimit -> Δt += 2%; при CFL = lowLimit ÷ hiLimit -> Δt = const; при CFL ≥ hiLimit -> Δt -= 3%")
                            .font(.footnote)
                        Toggle("Включить гибридную схему стабилизации", isOn: $solver.useHybridScheme)
                        Toggle("Вычислять среднюю температуру?", isOn: $solver.showAvgTemp)
                    }
                    .onChange(of: lowStabLimit) { _, newValue in
                        hiStabLimit = newValue + deltaStable
                    }
                    .onChange(of: deltaStable) { _, newValue in
                        hiStabLimit = lowStabLimit + newValue
                    }
                    Section(header: Text("Решение уравнения Пуассона для функции тока ω")) {
                        HStack {
                            Text("допуcтимая погрешность")
                            TextField("Введите число ≃ 1e-8 ÷ 1e-6", text: $tolerancePsi).editText(.numberPad)
                        }
                    }
                    Section(header: Text("Параметры итерационного процесса для давления")) {
                        VStack {
                            HStack {
                                Text("лимит итераций")
                                TextField("Введите число ≃ 20 ÷ 300", text: $maxIterations).editText(.numberPad)
                            }
                            HStack {
                                Text("коэффициент релаксации")
                                TextField("Введите число ≃ 0.1 ÷ 1.0", text: $relaxationFactor).editText()
                            }
                            HStack {
                                Text("допуcтимая погрешность")
                                TextField("Введите число ≃ 1e-5 ÷ 1e-3", text: $criticalError).editText()
                            }
                        }
                    }
                    Section(header: Text("Ограничения длины массивов")) {
                        VStack {
                            HStack {
                                Text("лимит шагов для диагностики")
                                TextField("Введите число ≃ 1000 ÷ 4000", text: $countsLimit).editText(.numberPad)
                            }
                            HStack {
                                Text("лимит шагов для истории")
                                TextField("Введите число ≃ 1000 ÷ 3000", text: $maxHistorySteps).editText(.numberPad)
                            }
                        }
                    }
                }
            }
        }
        .onAppear(perform: loadSettings)
        .navigationModifier("Процесс")
        .navigationBarItems(
            trailing: Button("Готово") {
                saveSettings()
                presentationMode.wrappedValue.dismiss()
            }
        )
    }
    
    private func loadSettings() {
        hiStabLimit = solver.params.hiStabLimit
        lowStabLimit = solver.params.lowStabLimit
        deltaStable = hiStabLimit - lowStabLimit
        maxIterations = "\(solver.params.maxIterations)"
        relaxationFactor = "\(solver.params.relaxationFactor)"
        criticalError = "\(solver.params.criticalError)"
        countsLimit = "\(solver.params.countsLimit)"
        maxHistorySteps = "\(solver.params.maxHistorySteps)"
        tolerancePsi = "\(solver.tolerancePsi)"
    }
    
    private func saveSettings() {
        // Обновляем параметры решателя
        solver.params.hiStabLimit = hiStabLimit
        solver.params.lowStabLimit = lowStabLimit
        if let mi = Int(maxIterations) { solver.params.maxIterations = mi }
        if let rf = Double(relaxationFactor) {
            solver.params.relaxationFactor = rf }
        if let ce = Double(criticalError) { solver.params.criticalError = ce }
        if let tp = Double(tolerancePsi) { solver.tolerancePsi = tp }
        if let cl = Int(countsLimit) { solver.params.countsLimit = cl }
        if let mhs = Int(maxHistorySteps) {
            solver.params.maxHistorySteps = mhs }
        print("Новые параметры: \(solver.params)")
    }

}
