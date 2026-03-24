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
                Section(header: Text("Метод решения: \(solver.params.useEnthalpyMethod ? "Пористая среда (EPM)" : "Раздвижная стенка (ALE)")")) {
                    Toggle("Использовать метод пористости", isOn: $solver.params.useEnthalpyMethod)
                    Toggle("Включить режим плавления", isOn: $solver.params.allowMelt)
                }
                if !solver.params.useEnthalpyMethod {
                    Section(header: Text("Вычисление диффузионных членов (ALE):")) {
                        Toggle("Использовать многопоточность", isOn: $solver.params.useParallelDiffuse)
                    }
                } else {
                    Section(header: Text("Параметры")) {
                        EditValue(text: "Интервал плавления [K] 0.01 ÷ 1:", value: $solver.params.dTm)
                    }
                }
            }
        }
        .disabled(solver.step > 0)
        .navigationModifier("Метод решения уравнений")
        .navigationBarItems(
            trailing: Button("Готово") {
                presentationMode.wrappedValue.dismiss()
            }
        )
    }
}
