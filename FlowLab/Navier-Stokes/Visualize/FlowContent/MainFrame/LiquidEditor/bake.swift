//
//  bake.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 28.01.2026.
//
//MARK: - Fixation (baking) of the formed solid phase body

import Foundation
import Combine

extension LiquidFractionEditor {
    
    /// Фиксация (запекание) сформированного тела твердой фазы
    func bakeCurrentPreviewIntoGrid() {
        DispatchQueue.main.async {
            solver.objectWillChange.send()
            for r in 0..<rows {
                let offset = r * cols
                for c in 0..<cols {
                    let idx = offset + c
                    
                    if isPointInsidePreview(col: c, row: r) {
                        solver.liquidFraction[idx] = 0.0
                        solver.u[idx] = 0; solver.v[idx] = 0
                        solver.T[idx] = solver.T_cold
                        solver.isStone[idx] = solver.makeSolid ? 1 : 0
                    }
                }
            }
            // После запекания можно сбросить активный инструмент на кисть
            currentTool = .freehand
        }
    }
}
