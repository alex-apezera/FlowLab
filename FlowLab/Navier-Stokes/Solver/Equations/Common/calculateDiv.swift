//
//  calculateDiv.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 18.01.2026.
//
//MARK: - Solve Divergence = du/dx + dv/dy

import Foundation
extension NavierStokesSolver {
    
    /// Оптимизированная версия Divergence = du/dx + dv/dy (должна -> 0)
    func calculateDivergence(uStar: [Double], vStar: [Double]) -> [Double] {
        let nx = self.nx, ny = self.ny
        let inv2h = 0.5 / h
        
        var div = [Double](repeating: 0.0, count: nx*ny)
        
        for j in 1..<ny-1 {
            let row = j * nx
            
            if useEnthalpyMethod {
                
                for i in 1..<nx-1 {
                    let idx = row+i, idxS = idx-nx, idxN = idx+nx
                    let du = uStar[idx+1] - uStar[idx-1]
                    let dv = vStar[idxN] - vStar[idxS]
                    
                    div[idx] = (du + dv) * inv2h
                }
                
            } else {
                
                let dy = y[j+1] - y[j-1]
                let rxJ = rx[j]
                
                for i in 1..<nx-1 {
                    let idx = row+i, idxS = idx-nx, idxN = idx+nx
                    let dx = (x[i+1] - x[i-1]) * rxJ
                    let du = uStar[idx+1] - uStar[idx-1]
                    let dv = vStar[idxN] - vStar[idxS]
                    
                    div[idx] = du / dx + dv / dy
                }
            }
        }
        return div
    }
    
}
