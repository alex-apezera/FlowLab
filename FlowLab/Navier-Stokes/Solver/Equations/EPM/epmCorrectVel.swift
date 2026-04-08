//
//  epmCorrectVel.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 12.01.2026.
//

import Foundation
extension NavierStokesSolver {
    
    /// Коррекция скорости (for Gauss-Seidel scheme)
    func epmCorrectVel(_ uNew: [Double], _ vNew: [Double]) {
        let nx = self.nx, ny = self.ny
        let dt_rho_inv2h = dt / (rho * 2.0 * h)

        let mask = solidMask
        
        for j in 1..<ny-1 {
            let row = nx*j
            
            for i in 1..<nx-1 {
                let idx = row + i
                
                /// Если ячейка твердая — скорость всегда 0
                if mask[idx] == 1 { u[idx] = 0; v[idx] = 0; continue }
                
                /// Если  соседи — камень, используем p old
                let p_old = p[idx]
                let west = idx - 1, east = idx + 1
                let south = idx - nx, north = idx + nx
                
                /// Соседи: если твердое тело - берем p old (dp/dn = 0)
                let pW = (mask[west] == 1) ? p_old : p[west]
                let pE = (mask[east] == 1) ? p_old : p[east]
                let pN = (mask[north] == 1) ? p_old : p[north]
                let pS = (mask[south] == 1) ? p_old : p[south]
                
                u[idx] = uNew[idx] - dt_rho_inv2h * (pE-pW)
                v[idx] = vNew[idx] - dt_rho_inv2h * (pN-pS)
                
            }
        }
    }
}
