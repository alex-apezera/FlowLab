//
//  epmCorrectVelPar.swift
//  FlowLab
//
//  Created by Алексей Езерский on 25.04.2026.
//
import Foundation
extension NavierStokesSolver {
    
    /// Многопоточная коррекция скорости EPM
    func epmCorrectVelPar(_ uNew: [Double], _ vNew: [Double]) {
        let nx = self.nx, ny = self.ny, workerCount = self.workerCount
        let dt_rho_inv2h = dt / (rho * 2.0 * h)
        
        u.withUnsafeMutableBufferPointer { uPtrs in
        v.withUnsafeMutableBufferPointer { vPtrs in
        p.withUnsafeBufferPointer { p in
        uNew.withUnsafeBufferPointer { uNew in
        vNew.withUnsafeBufferPointer { vNew in
        solidMask.withUnsafeBufferPointer { mask in
            
            // Распараллеливаем внешний цикл по числу потоков
            DispatchQueue.concurrentPerform(iterations: workerCount) { wID in
                let startY = 1 + (wID * (ny - 2) / workerCount)
                let endY = 1 + ((wID + 1) * (ny - 2) / workerCount)

                for j in startY..<endY {
                    let row = nx*j, prevRow = row-nx, nextRow = row+nx

                    for i in 1..<nx-1 {
                        let idx = row + i
                        
                        /// Если ячейка твердая — скорость всегда 0
                        if mask[idx] == 1 {uPtrs[idx] = 0; vPtrs[idx] = 0
                            continue
                        }
                        
                        /// Если  соседи — камень, используем p old
                        let p_old = p[idx]
                        let west = idx - 1, east = idx + 1
                        let south = prevRow+i, north = nextRow+i
                        
                        /// Соседи: если твердое тело - берем p old (dp/dn = 0)
                        let pW = (mask[west] == 1) ? p_old : p[west]
                        let pE = (mask[east] == 1) ? p_old : p[east]
                        let pN = (mask[north] == 1) ? p_old : p[north]
                        let pS = (mask[south] == 1) ? p_old : p[south]
                        
                        uPtrs[idx] = uNew[idx] - dt_rho_inv2h * (pE-pW)
                        vPtrs[idx] = vNew[idx] - dt_rho_inv2h * (pN-pS)
                    }
                }
            }
            
        }}}}}}
    }
}
