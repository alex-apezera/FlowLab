//
//  aleCorrectVel.swift
//  FlowLab
//
//  Created by Алексей Езерский on 26.04.2026.
//
/*
import Foundation
extension NavierStokesSolver {
    /// Не используется в текущем методе ALE (применяется метод Якоби)
    /// Коррекция скорости ALE
    func aleCorrectVel(_ p: [Double], _ dt_rho: Double) {
        for j in 1..<(ny-1) {
            let row = j * nx
            for i in 1..<(nx-1) {
                let idx = i + row
                u[idx] -= dt_rho * derivativeX(p, j, i, idx)
                v[idx] -= dt_rho * derivativeY(p, j, i, idx)
            }
        }
    }
    
    /// Многопоточная коррекция скорости ALE
    func aleCorrectVelPar(_ uNew: [Double], _ vNew: [Double]) {
        let nx = self.nx, ny = self.ny, workerCount = self.workerCount
        let dt_rho = dt / rho
        
        u.withUnsafeMutableBufferPointer { uPtrs in
        v.withUnsafeMutableBufferPointer { vPtrs in
        p.withUnsafeBufferPointer { p in
        uNew.withUnsafeBufferPointer { uNew in
        vNew.withUnsafeBufferPointer { vNew in
            // Распараллеливаем внешний цикл по числу потоков
            DispatchQueue.concurrentPerform(iterations: workerCount) { wID in
                let startY = 1 + (wID * (ny - 2) / workerCount)
                let endY = 1 + ((wID + 1) * (ny - 2) / workerCount)

                for j in startY..<endY {
                    let row = nx*j, prevRow = row-nx, nextRow = row+nx
                    
                    let dy = y[j+1] - y[j]
                    let rxJ = rx[j]
                    
                    for i in 1..<nx-1 {
                        let idx = row + i
                        
                        let dx = (x[i+1] - x[i]) * rxJ
                        let dpdx = (p[idx+1] - p[idx-1]) / dx
                        let dpdy = (p[nextRow+i] - p[prevRow+i]) / dy
                        
                        uPtrs[idx] = uNew[idx] - dt_rho * dpdx
                        vPtrs[idx] = vNew[idx] - dt_rho * dpdy
                    }
                }
            }
        }}}}}
    }

}
*/
