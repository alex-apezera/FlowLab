//
//  editFractionContent.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 29.01.2026.
//
import SwiftUI
extension Visualizator {
    
    @ViewBuilder var editFractionContent: some View {
        
        if selectedVisualization == 5 {
            LiquidFractionEditor(rows: solver.ny, cols: solver.nx)
                .environmentObject(solver)
        }
    }
}
