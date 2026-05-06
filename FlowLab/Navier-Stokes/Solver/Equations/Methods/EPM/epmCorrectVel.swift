//
//  epmCorrectVel.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 12.01.2026.
//
//MARK: - Convection for 𝐕 (EPM)

import Foundation
extension NavierStokesSolver {
    
    /// Коррекция скорости ∂𝐕/∂t  = -(1/ρ)∇p)
    func epmCorrectVel(_ uNew: [Double], _ vNew: [Double]) {
        
        u.withUnsafeMutableBufferPointer { u in
        v.withUnsafeMutableBufferPointer { v in
        p.withUnsafeBufferPointer { p in
        uNew.withUnsafeBufferPointer { uNew in
        vNew.withUnsafeBufferPointer { vNew in
        solidMask.withUnsafeBufferPointer { mask in
        
        if useConcurrence {
            DispatchQueue.concurrentPerform(iterations: workerCount) { wID in
                let startY = 1 + (wID * (ny - 2) / workerCount)
                let endY = 1 + ((wID + 1) * (ny - 2) / workerCount)
                
                correctionV(startY: startY, endY: endY, &u, &v, p, uNew, vNew, mask)
            }
        } else {
            correctionV(startY: 1, endY: ny-1, &u, &v, p, uNew, vNew, mask)
        }
        }}}}}}/// Ptr
    }
    /// Коррекция указателей скоростей
    fileprivate func correctionV(startY: Int, endY: Int, _ u: inout Mutable, _ v: inout Mutable, _ p: ReadOnly, _ uNew: ReadOnly, _ vNew: ReadOnly, _ mask: PtrUInt8) {
        
        let dt_rho_inv2h = dt / (rho * 2.0 * h), nx = self.nx

        for j in startY..<endY {
            let row = nx*j
            
            for i in 1..<nx-1 {
                let idx = row + i
                
                /// Если ячейка твердая — скорость всегда 0
                if mask[idx] == 1 {u[idx] = 0; v[idx] = 0; continue }
                
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
