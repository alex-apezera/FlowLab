//
//  refreshLF.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 18.03.2026.
//
import Foundation
extension NavierStokesSolver {
    
    // Сразу после загрузки массива T из файла:
    func refreshLiquidFraction() {
//        var grid = [Double](repeating: 0.0, count: nx * ny)
        let grid = flatten(grid: T, nx: nx, ny: ny)
//        DispatchQueue.concurrentPerform(iterations: nx * ny) { idx in
            // EPM: fl = (T - T_solid) / (T_liquid - T_solid)
        for idx in 0..<nx*ny {
        
        let temp = grid[idx]
            if temp >= dTm * (T_max - T_cold) {
                liquidFraction[idx] = 1.0
            } else if temp <= T_cold {
                liquidFraction[idx] = 0.0
            } else {
                liquidFraction[idx] = (temp - T_cold) / (T_max - T_cold)
            }
        }
    }
}
