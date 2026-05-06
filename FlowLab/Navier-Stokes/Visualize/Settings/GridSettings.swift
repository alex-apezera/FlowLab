//
//  GridSettings.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 13.11.2025.
//
//MARK: - Correction of geometric parameters

import SwiftUI

/// Корректировка геометрических параметров
struct GridSettings: View {
    @ObservedObject var solver: NavierStokesSolver
    
    @State private var nodesX: Int = 100
    @State private var nodesY: Int = 100
    @State private var stretchX: Double = 0
    @State private var stretchY: Double = 0
    @State private var lenghtX: Double = 1
    @State private var lenghtY: Double = 1
    @State private var initMeltWidthRatio: Double = 1
        
    var body: some View {
        let settingsNotActive: Bool = solver.step > 0
        NavigationView {
            Form {
                Section(header: Text("Geometry")) {
                    VStack {
                        EditIntValue(text: "Width nodes", value: $nodesX)
                        if !solver.params.useEnthalpyMethod {
                            EditIntValue(text: "Height nodes", value: $nodesY)
                            EditValue(text: "Width stretch", value: $stretchX)
                            EditValue(text: "Height stretch", value: $stretchY)
                        }
                        EditValue(text: "Width [m]", value: $lenghtX)
                        if solver.params.useEnthalpyMethod {
                            EditValue(text: "Initial melt thickness 0.1 ÷ 1:", value: $initMeltWidthRatio)
                        }
                        EditValue(text: "Height [m]", value: $lenghtY)
                    }
                    .foregroundStyle(settingsNotActive ? .tertiary : .primary)
                    .disabled(settingsNotActive)
                    .padding()
                }
            }
        }
        .navigationModifier("Domain")
        .onAppear(perform: loadSettings)
        .onDisappear(perform: saveSettings)
        .onDisappear(perform: solver.reset)
        .done
    }
    
    private func loadSettings() {
        // Загружаем существующие параметры
        nodesX = solver.params.nx
        nodesY = solver.params.ny
        stretchX = solver.params.stretch_x
        stretchY = solver.params.stretch_y
        lenghtX = solver.params.Lx
        lenghtY = solver.params.Ly
        initMeltWidthRatio = solver.params.initMeltWidthRatio
    }
    
    private func saveSettings() {
        // Обновляем параметры решателя
        solver.params.nx = nodesX
        solver.params.ny = nodesY
        solver.params.stretch_x = stretchX
        solver.params.stretch_y = stretchY
        solver.params.Lx = lenghtX
        solver.params.Ly = lenghtY
        solver.params.initMeltWidthRatio = initMeltWidthRatio        
    }
}

