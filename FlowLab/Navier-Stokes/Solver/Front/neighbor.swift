//
//  neighbor.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 03.02.2026.
//

extension NavierStokesSolver {
    
    // Вспомогательная функция для определения "кожи" льда
    @inline(__always) func hasLiquidNeighbor(r: Int, c: Int) -> Bool {
        let neighbors = [(r-1, c), (r+1, c), (r, c-1), (r, c+1)]
        for (nr, nc) in neighbors {
            if nr >= 0 && nr < ny && nc >= 0 && nc < nx {
                if liquidFraction[idx(nc, nr)] >= (1-dTm) { return true }
            }
        }
        return false
    }
    
    
}
