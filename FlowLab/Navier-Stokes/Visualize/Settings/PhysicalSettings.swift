//
//  PhysicalSettings.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 13.11.2025.
//

import SwiftUI
struct PhysicalSettings: View {
    @ObservedObject var solver: NavierStokesSolver
    @Environment(\.presentationMode) var presentationMode
    @State private var substance: Substance = .wax23
    @State private var heatingType: HeatingType = .temperature
    @State private var heatingValue: Double = 10
    
    var body: some View {
        let settingsNotActive: Bool = solver.step > 0
        
        NavigationView {
            Form {
                Section(header: Text("Подвод тепла")) {
                    HStack {
                        Text("Тип нагревания:")
                        Picker("Heating type", selection: $heatingType) {
                            ForEach(HeatingType.allCases, id: \.self) { type in
                                Text(type.designation).tag(type)
                            }
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                    
                    EditValue(text: "Величина нагрева: \(heatingType.designation)", value: $heatingValue)
                    
                }
                    Section(header: Text("Начальное распределение температуры: \(solver.useInitialGradientT ? "Градиентное" : "Фиксированное")")) {
                        Toggle("Включить градиентное распределение", isOn: $solver.useInitialGradientT)
                    }
                Section(header: VStack(alignment: .leading) {
                    Text("Вещество")
                    Text("● вещество нельзя изменять при step ≠ 0").font(.footnote)
                    Text("●● для некоторых веществ параметры зависят от температуры").font(.footnote)
                }) {
                    Picker("Substance", selection: $substance) {
                        ForEach(Substance.allCases, id: \.self) {fluid in
                            Text(fluid.localizedName).tag(fluid)
                        }
                    }
                    .onChange(of: substance) { solver.reset() }
                    .background(settingsNotActive ? Color.secondary.opacity(0.3) : Color.clear)
                    .disabled(settingsNotActive)
                    .pickerStyle(SegmentedPickerStyle())
                    
                    HStack {
                        switch substance {
                        case .water, .wax23, .wax33, .wax56, .air:
                            substanceProperties
                        case .custom:
                            customProperties
                        }
                    }
                }
            }
        }
        .onAppear { loadCustomSettings() }
        .onChange(of: solver.useInitialGradientT) {solver.initTAndFraction()}
        .navigationModifier("Объект")
        .navigationBarItems(
            trailing: Button("Готово") {
                saveSettings()
                presentationMode.wrappedValue.dismiss()
            }
        )
    }
    
    // Загрузка параметров
    private func loadCustomSettings() {
        substance = solver.params.substance
        heatingType = solver.params.heatingType
        heatingValue = solver.params.heatingValue
    }
    
    // Сохранение параметров
    private func saveSettings() {
        solver.params.substance = substance
        solver.params.heatingType = heatingType
        solver.params.heatingValue = heatingValue
    }
    
    // Свойства вещества
    private var substanceProperties: some View  {
        VStack(alignment: .leading) {
            let air = substance == .air
            let fluid = substance.properties
            
            Text("ρ₀ \tопорная плотность \t\t\tkg/m³  \t\t\(fluid.density, specifier: "%.2f")")
            Text("ν \tкинематическая вязкость \tm²/s \t\t\(fluid.viscosity, specifier: "%.2e")")
            Text("α \tтемпературопроводность  \tm²/s \t\t\(fluid.thermalDiffusivity, specifier: "%.2e")")
            Text("λ \tтеплопроводность \t\t\tW/(m·K) \t\(fluid.thermalConductivity, specifier: "%.2f")")
            Text("Cp \tизобарная теплоёмкость \tJ/(kg·K) \t\(fluid.specificHeat, specifier: "%.0f")")
            Text("β \tобъёмное расширение \t\tK⁻¹ \t\t\t\(fluid.expansionCoefficient, specifier: "%.2e")")
            if air {
                Text("T₀ \tтемпература плавления \tºС \t\t\t\(fluid.T_melt, specifier: "%.0f") <условно>")
            } else {
                Text("T₀ \tтемпература плавления \tºС \t\t\t\(fluid.T_melt, specifier: "%.0f")")
                Text("Lh \tтеплота плавления  \t\t\tW·s/kg \t\(fluid.latentHeat, specifier: "%.0f")")
            }
        }
    }
    
    // Свойства произвольного вещества
    private var customProperties: some View  {
        VStack(alignment: .leading) {
            EditValue(text: "ρ₀ \tопорная плотность kg/m³", value: $solver.params.customFluidProperties.density)
            EditValue(text: "ν \tкинематическая вязкость m²/s", value: $solver.params.customFluidProperties.viscosity)
            EditValue(text: "α \tтемпературопроводность  m²/s", value: $solver.params.customFluidProperties.thermalDiffusivity)
            EditValue(text: "λ \tтеплопроводность W/(m·K)", value: $solver.params.customFluidProperties.thermalConductivity)
            EditValue(text: "Cp \tизобарная теплоёмкость J/(kg·K)", value: $solver.params.customFluidProperties.specificHeat)
            EditValue(text: "β \tобъёмное расширение K⁻¹", value: $solver.params.customFluidProperties.expansionCoefficient)
            EditValue(text: "T₀ \tтемпература плавления ºС", value: $solver.params.customFluidProperties.T_melt)
            EditValue(text: "Lh \tтеплота плавления  W·s/kg", value: $solver.params.customFluidProperties.latentHeat)
        }
        .font(.system(size: 14))
    }

}

