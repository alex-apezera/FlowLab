//
//  bake.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 28.01.2026.
//
import Foundation
import Combine

extension LiquidFractionEditor {
    
    func bakeCurrentPreviewIntoGrid() {
        DispatchQueue.main.async {
            solver.objectWillChange.send()
            for r in 0..<rows {
                let offset = r * cols
                for c in 0..<cols {
                    let idx = offset + c
                    
                    if isPointInsidePreview(col: c, row: r) {
                        solver.liquidFraction[idx] = 0.0
                        solver.u[r][c] = 0; solver.v[r][c] = 0
                        solver.T[r][c] = solver.T_cold
                        solver.isStone[solver.idx(c,r)] = solver.makeSolid ? 1 : 0
                    }
                }
            }
            // После запекания можно сбросить активный инструмент на кисть
            currentTool = .freehand
        }
    }
}
