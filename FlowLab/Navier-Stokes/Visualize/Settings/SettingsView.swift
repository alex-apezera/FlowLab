//
//  SettingsView.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 13.11.2025.
//
// MARK: - View for hierarchical settings

import SwiftUI

/// Представление для иерархических настроек
struct SettingsView: View {
    @ObservedObject var solver: NavierStokesSolver
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Methods") {
                    MethodSettings(solver: solver)
                }
                NavigationLink("Geometry") {
                    GridSettings(solver: solver)
                }

                NavigationLink("Gravity") {
                    GravitySettings(solver: solver)
                }

                NavigationLink("Time") {
                    TimeSettings(solver: solver)
                }
                
                NavigationLink("Process") {
                    SolveSettings(solver: solver)
                }
                                
                NavigationLink("Subject") {
                    PhysicalSettings(solver: solver)
                }
                
                NavigationLink("Wind") {
                    Wind(solver: solver)
                }
                
            }
            .navigationModifier("Settings")
            .done
        }
    }
}
