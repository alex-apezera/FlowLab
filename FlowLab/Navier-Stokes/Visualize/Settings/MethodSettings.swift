//
//  MethodSettings.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 29.12.2025.
//
//MARK: - Selecting a method for solving equations

import SwiftUI

/// Выбор метода решения уравнений
struct MethodSettings: View {
    @ObservedObject var solver: NavierStokesSolver
        
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Comment").font(.headline)) {
                    editString("Enter string value", $solver.params.comment)
                }
                Section(header: Text("Main method: \(solver.useEnthalpyMethod ? "Enthalpy-Porous Media (EPM)" : "Arbitrary Lagrangian-Eulerian (ALE)")")) {
                    Toggle("ON: EPM / OFF: ALE", isOn: $solver.params.useEnthalpyMethod)
                        .disabled(solver.step > 0)
                    Toggle("ON/OFF: Melting process", isOn: $solver.params.allowMelt)
                    EditIntValue(text: "Step to activate melting", value: $solver.params.startMeltingStep)
                    if solver.useEnthalpyMethod {
                        EditValue(text: "Melting gap: Tm - Tc, [K]", value: $solver.params.dTm)
                        Toggle("ON/OFF: Stephan scheme on melt front", isOn: $solver.params.useStephanScheme)
                    }
                }
                Section(header: Text("Use concurrence:")) {
                    Toggle("ON/OFF: conv, diver, corr", isOn: $solver.params.useConcurrence)
                    Toggle("ON/OFF: diffuse", isOn: $solver.params.useParallelDiffusion)
                    Toggle("ON/OFF: pressure", isOn: $solver.params.useParallelPressure)

                    if solver.useConcurrence || solver.useParallelPressure || solver.params.useParallelDiffusion {
                        let countStep = 2
                        let countMax = solver.ny-2
                        Stepper("number of threads:  \(solver.workerCount)") {
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
            }
        }
        .navigationModifier("Methods options")
        .done
    }
    
    /// Переключение параметров
    fileprivate func toggleParams(_ value: Bool) {
        if value {
            solver.params.useParallelDiffusion = true
            solver.params.useParallelPressure = true
        } else {
            solver.params.useParallelDiffusion = false
            solver.params.useParallelPressure = false
        }
    }

}
