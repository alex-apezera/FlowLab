//
//  PhysicalSettings.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 13.11.2025.
//
//MARK: - Selection of physical parameters of a substance

import SwiftUI

/// Выбор физических параметров вещества
struct PhysicalSettings: View {
    @ObservedObject var solver: NavierStokesSolver
    @State private var substance: Substance = .custom
    @State private var heatingType: HeatingType = .temperature
    @State private var heatingValue: Double = 10
    
    var body: some View {
        let settingsNotActive: Bool = solver.step > 0
        
        NavigationView {
            Form {
                Section(header: Text("Heat supply")) {
                    HStack {
                        Text("Heating type:")
                        Picker("Heating type", selection: $heatingType) {
                            ForEach(HeatingType.allCases, id: \.self) { type in
                                Text(type.designation).tag(type)
                            }
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                    
                    EditValue(text: "Heating value: \(heatingType.designation)", value: $heatingValue)
                    
                }
                Section(header: Text("Temperature conditions")) {
                    Toggle("ON/OFF init gradient distribution", isOn: $solver.useInitialGradientT)
                    Toggle("After the front touched the cold wall: \(solver.params.useNeiman ? "dT/dx=0" : "T=T_cold")", isOn: $solver.params.useNeiman)
                }
                Section(header: VStack(alignment: .leading) {
                    Text("Substance")
                    Text("● substance may change only if step ≠ 0").font(.footnote)
                    Text("●● for some substances parameters depend on temperature").font(.footnote)
                }) {
                    Picker("Substance", selection: $substance) {
                        ForEach(Substance.allCases, id: \.self) {fluid in
                            Text(fluid.localizedName).tag(fluid)
                        }
                    }
                    .onChange(of: substance) { solver.reset() }
                    .onChange(of: solver.useInitialGradientT) { solver.reset() }
                    .background(settingsNotActive ? Color.secondary.opacity(0.3) : Color.clear)
                    .disabled(settingsNotActive)
                    .pickerStyle(SegmentedPickerStyle())
                    
                    HStack {
                        switch substance {
                        case .water, .eicosane, .docosane, .wax56, .air:
                            substanceProperties
                        case .custom:
                            customProperties
                        }
                    }
                }
            }
        }
        .onAppear(perform: loadSettings)
        .onDisappear(perform: saveSettings)
        .onChange(of: solver.useInitialGradientT) {solver.initTAndFraction()}
        .navigationModifier("Object")
        .done
    }
    
    /// Загрузка параметров
    private func loadSettings() {
        substance = solver.params.substance
        heatingType = solver.params.heatingType
        heatingValue = solver.params.heatingValue
    }
    
    /// Сохранение параметров
    private func saveSettings() {
        solver.params.substance = substance
        solver.params.heatingType = heatingType
        solver.params.heatingValue = heatingValue
    }
    
    /// Свойства вещества
    private var substanceProperties: some View  {
        VStack/*(alignment: .leading)*/ {
            let air = substance == .air
            let fluid = substance.properties
            
            propertyForm("ρ₀, density, [kg/m³]", fluid.density, "%.2f")
            propertyForm("ν, viscosity, [m²/s]", fluid.viscosity, "%.2e")
            propertyForm("α, thermalDiffusivity, [m²/s]", fluid.thermalDiffusivity, "%.2e")
            propertyForm("λ, thermalConductivity, [W/m·K]", fluid.thermalConductivity, "%.2f")
            propertyForm("Cp, specificHeat, [J/kg·K]", fluid.specificHeat, "%.0f")
            propertyForm("β, expansionCoefficient, [K⁻¹]", fluid.expansionCoefficient, "%.2e")
            if air {
                propertyForm("T₀, cold temperatute, [ºС]", fluid.T_melt, "%.0f")
            } else {
                propertyForm("T₀, melting temperatute, [ºС]", fluid.T_melt, "%.0f")
                propertyForm("Lh, latentHeat, [W·s/kg]", fluid.latentHeat, "%.0f")
                propertyForm("ρ₁, solid density, [kg/m³]", fluid.rho_solid, "%.0f")
                propertyForm("λ₁ solid λ, [W/m·K]", fluid.lambda_solid, "%.2f")
                propertyForm("Cp₁, solid Cp, [J/kg·K]", fluid.Cp_solid, "%.0f")
            }
        }.font(.callout)
    }
    
    /// Свойства произвольного вещества
    private var customProperties: some View  {
        VStack/*(alignment: .leading)*/ {
            EditValue(text: "ρ₀, density, [kg/m³]", value: $solver.params.customFluidProperties.density)
            EditValue(text: "ν, viscosity, [m²/s]", value: $solver.params.customFluidProperties.viscosity)
            EditValue(text: "α, thermalDiffusivity, [m²/s]", value: $solver.params.customFluidProperties.thermalDiffusivity)
            EditValue(text: "λ, T Conductivity, [W/m·K]", value: $solver.params.customFluidProperties.thermalConductivity)
            EditValue(text: "Cp, specificHeat, [J/(kg·K)]", value: $solver.params.customFluidProperties.specificHeat)
            EditValue(text: "β, expansionCoefficient, [K⁻¹]", value: $solver.params.customFluidProperties.expansionCoefficient)
            EditValue(text: "T₀, melting temperatute, [ºС]", value: $solver.params.customFluidProperties.T_melt)
            EditValue(text: "Lh, latentHeat, [W·s/kg]", value: $solver.params.customFluidProperties.latentHeat)
            EditValue(text: "ρ₁, solid density, [kg/m³]", value: $solver.params.customFluidProperties.rho_solid)
            EditValue(text: "λ₁ solid λ, [W/m·K]", value: $solver.params.customFluidProperties.lambda_solid)
            EditValue(text: "Cp₁, solid Cp, [J/kg·K]", value: $solver.params.customFluidProperties.Cp_solid)
        }
        //        .font(.system(size: 14))
        .font(.callout)
    }
    
    /// Шаблон для свойств вещества
    private func propertyForm(_ property: String, _ value: Double, _ format: String) -> some View {
        HStack {
            Text(property).frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            Text("\(value, specifier: format)  ")
        }
        .padding(.bottom, 3)
        .font(.callout)
        .foregroundColor(.secondary)
    }

}
