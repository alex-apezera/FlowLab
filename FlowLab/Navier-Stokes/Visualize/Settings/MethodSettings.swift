//
//  MethodSettings.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 29.12.2025.
//

import SwiftUI

//MARK: - Выбор метода решения уравнений

struct MethodSettings: View {
    @ObservedObject var solver: NavierStokesSolver
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Комментарий к задаче").font(.headline)) {
                    TextField("Текст", text: $solver.params.comment)
                        .editText(.asciiCapable)
                }
                Section(header: Text("Метод решения: \(solver.params.useEnthalpyMethod ? "Пористая среда (EPM)" : "Раздвижная стенка (ALE)")")) {
                    Toggle("Использовать метод пористости", isOn: $solver.params.useEnthalpyMethod)
                        .disabled(solver.step > 0)
                    Toggle("Включить режим плавления", isOn: $solver.params.allowMelt)
                    HStack {
                        Text("Шаг запуска плавления:")
                        TextField("Введите число ≃ 0 ÷ ∞", value: $solver.params.startMeltingStep, format: .number).editText(.numberPad)
                    }
                    if solver.params.useEnthalpyMethod {
                        EditValue(text: "Температурный интервал плавления [K] 0.01 ÷ 0.1:", value: $solver.params.dTm)
                        Toggle("Включить градиентную коррекцию II порядка на границе рраздела фаз", isOn: $solver.params.useGradientCorrection)
                    }
                }
                Section(header: Text("Использование многопоточности:")) {
                        Toggle("Включить/выключить многопоточность", isOn: $solver.params.useConcurrence)
                        Toggle("ВКЛ/ВЫКЛ: для расчёта давления", isOn: $solver.params.useParallelPressure)
                        .disabled(solver.params.useEnthalpyMethod)
                    
                    if solver.params.useConcurrence || solver.params.useParallelPressure {
                        let countStep = 2
                        let countMax = solver.ny-2
                        Stepper("Число параллельных потоков  \(solver.workerCount)") {
                            if solver.workerCount < countMax {
                                solver.workerCount *= countStep
                            }
                        } onDecrement: {
                            if solver.workerCount > countStep {
                                solver.workerCount /= countStep
                            }
                        }
                    }
                }
                .onChange(of: solver.params.useConcurrence) { _, value in
                    if value { solver.params.useParallelPressure = true }}
                .onChange(of: solver.params.useEnthalpyMethod) { _, value in
                    if value { solver.params.useParallelPressure = true }
                    else { solver.params.useParallelPressure = false }}
                .onAppear { if solver.params.useEnthalpyMethod {
                    solver.params.useParallelPressure = true }
                }
            
            }
        }
        .navigationModifier("Метод решения уравнений")
        .navigationBarItems(
            trailing: Button("Готово") {
                presentationMode.wrappedValue.dismiss()
            }
        )
    }
}
