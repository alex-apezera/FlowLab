//
//  editFractionContent.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 29.01.2026.
//
//MARK: - Drawing and editing solid phase distribution

import SwiftUI
extension Visualizator {
    
    /// Отрисовка и редактирование распределения твердой фазы
    @ViewBuilder var editFractionContent: some View {
        
        if selectedVisualization == 5 {
            if solver.useEnthalpyMethod {
                LiquidFractionEditor(rows: solver.ny, cols: solver.nx)
                    .environmentObject(solver)
            } else {
                disableView
            }
        }
    }
}
