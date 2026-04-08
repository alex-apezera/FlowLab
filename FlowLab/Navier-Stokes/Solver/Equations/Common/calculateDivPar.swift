//
//  calculateDivPar.swift
//  FlowLab
//
//  Created by Алексей Езерский on 01.05.2026.
//
import Foundation
extension NavierStokesSolver {
    
    /// Многопоточная  версия Divergence = du/dx + dv/dy (должна -> 0)
    func calculateDivPar(uStar: [Double], vStar: [Double]) -> [Double] {
        let nx = self.nx, ny = self.ny, workerCount = self.workerCount
        let inv2h = 0.5 / h
        var div = [Double](repeating: 0.0, count: nx * ny)
        
        /// Используем указатели для всех массивов, чтобы избежать проверки границ
        uStar.withUnsafeBufferPointer { uBuf in
        vStar.withUnsafeBufferPointer { vBuf in
        div.withUnsafeMutableBufferPointer { divBuf in
                    
            DispatchQueue.concurrentPerform(iterations: workerCount) { wID in
                let startY = 1 + (wID * (ny - 2) / workerCount)
                let endY = 1 + ((wID + 1) * (ny - 2) / workerCount)
                
                for j in startY..<endY {
                    let row = j * nx
                    
                    if useEnthalpyMethod {
                        for i in 1..<nx-1 {
                            let idx = row+i, idxS = idx-nx, idxN = idx+nx
                            let du = uBuf[idx+1] - uBuf[idx-1]
                            let dv = vBuf[idxN] - vBuf[idxS]
                            
                            divBuf[idx] = (du + dv) * inv2h
                        }
                    } else {
                        let dy = y[j+1] - y[j-1]
                        let rxJ = rx[j]
                        for i in 1..<nx-1 {
                            let idx = row+i, idxS = idx-nx, idxN = idx+nx
                            let dx = (x[i+1] - x[i-1]) * rxJ
                            let du = uBuf[idx+1] - uBuf[idx-1]
                            let dv = vBuf[idxN] - vBuf[idxS]
                            
                            divBuf[idx] = du / dx + dv / dy
                        }
                    }
                    
                }}}
            }
        }
        return div
    }
}
