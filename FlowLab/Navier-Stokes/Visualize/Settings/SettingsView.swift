//
//  SettingsView.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 13.11.2025.
//

import SwiftUI

// MARK: - Новое представление для иерархических настроек
struct SettingsView: View {
    @ObservedObject var solver: NavierStokesSolver
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Метод") {
                    MethodSettings(solver: solver)
                }
                NavigationLink("Геометрия") {
                    GridSettings(solver: solver)
                }

                NavigationLink("Гравитация") {
                    GravitySettings(solver: solver)
                }

                NavigationLink("Время") {
                    TimeSettings(solver: solver)
                }
                
                NavigationLink("Процесс") {
                    SolveSettings(solver: solver)
                }
                                
                NavigationLink("Объект") {
                    PhysicalSettings(solver: solver)
                }
                
            }
            .navigationModifier("Настройки")
            .navigationBarItems(trailing: Button("Готово") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
