//
//  GridSettings.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 13.11.2025.
//

import SwiftUI

//MARK: - Корректировка геометрических параметров

struct GridSettings: View {
    @ObservedObject var solver: NavierStokesSolver
    @Environment(\.presentationMode) var presentationMode
    
    @State private var nodesX: Int = 100
    @State private var nodesY: Int = 100
    @State private var stretchX: Double = 0
    @State private var stretchY: Double = 0
    @State private var lenghtX: Double = 1
    @State private var lenghtY: Double = 1
    @State private var initMeltWidthRatio: Double = 1
    
//    init() { loadSettings() }
    
    var body: some View {
        let settingsNotActive: Bool = solver.step > 0
        NavigationView {
            Form {
                Section(header: Text("Параметры области")) {
                    VStack {
                        EditIntValue(text: "Число узлов по ширине", value: $nodesX)
                        if !solver.params.useEnthalpyMethod {
                            EditIntValue(text: "Число узлов по высоте", value: $nodesY)
                            EditValue(text: "Растяжение от границы к центру области по X", value: $stretchX)
                            EditValue(text: "Растяжение от границы к центру области по Y", value: $stretchY)
                        }
                        EditValue(text: "Ширина области по X [m]", value: $lenghtX)
                        if solver.params.useEnthalpyMethod {
                            EditValue(text: "Начальная толщина расплава 0.1 ÷ 1:", value: $initMeltWidthRatio)
                        }
                        EditValue(text: "Высота области по Y [m]", value: $lenghtY)
                    }
                    .foregroundStyle(settingsNotActive ? .tertiary : .primary)
                    .disabled(settingsNotActive)
                    .padding()
                }
            }
        }
        .navigationModifier("Геометрия")
        .navigationBarItems(
            trailing: Button("Готово") {
                saveSettings()
                presentationMode.wrappedValue.dismiss()
            }
        )
        .onAppear(perform: loadSettings)
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
        
        // Регенерируем сетку и начальные условия
        solver.reset()
    }
}

