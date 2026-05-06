//
//  divergence.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 18.01.2026.
//
//MARK: - Solve Divergence = du/dx + dv/dy (->0)

import Foundation
extension NavierStokesSolver {
    /// Дивергенция du/dx + dv/dy
    func divergence(startY: Int, endY: Int, _ divBuf: inout Mutable, _ uBuf: ReadOnly, _ vBuf: ReadOnly, _ x: ReadOnly, _ y: ReadOnly, _ rx: ReadOnly) {
        
        let nx = self.nx, dt = self.dt
        let inv2h = 0.5 / self.h
        
        for j in startY..<endY {
            let row = j * nx
            
            if useEnthalpyMethod { /// EPM Method
                for i in 1..<nx-1 {
                    let idx = row+i, idxS = idx-nx, idxN = idx+nx
                    let du = uBuf[idx+1] - uBuf[idx-1]
                    let dv = vBuf[idxN] - vBuf[idxS]
                    
                    divBuf[idx] = (du + dv) * inv2h
                }
            } else { /// ALE Method
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
        }
        
        // Добавляем sourceMass для inlet (только при forced convection)
        if params.useWind {
            // левая стенка (i=0)
            let jStart = Int(params.y_start * Double(ny)) /// начало вдува
            let jEnd = Int(params.y_end * Double(ny))     /// конец вдува
            let dy = self.dy[0]
            for j in startY..<endY {
                let idx = j * nx + 0  // сама граничная ячейка
                if inlet(jStart, jEnd, j) || outlet(jStart, jEnd, j) {
                    let u_inlet = uBuf[idx]
                    if u_inlet > 0 {
                        let sourceMass = u_inlet * dy
                        divBuf[idx] += sourceMass / dt
                    }
                }
            }
            if !params.leftSink {
                // верхняя граница (j=ny-1) и нижняя (j=0)
                let dx = self.dx[0]
                for i in 1..<nx-1 {
                    // верхняя
                    let idxTop = (ny-1) * nx + i
                    let v_top = vBuf[idxTop]
                    if v_top < 0 {
                        let sourceMass = -v_top * dx
                        divBuf[idxTop] += sourceMass / dt
                    }
                    // нижняя
                    let idxBot = 0 * nx + i
                    let v_bot = vBuf[idxBot]
                    if v_bot > 0 {
                        let sourceMass = v_bot * dx
                        divBuf[idxBot] += sourceMass / dt
                    }
                }
            }
        }

    }
    
    /// Оптимизированная версия Divergence = du/dx + dv/dy (должна -> 0)
    func calculateDivergence(uStar: [Double], vStar: [Double]) -> [Double] {
        
        var div = [Double](repeating: 0.0, count: nx*ny)

        /// Используем указатели, чтобы избежать проверки границ
        uStar.withUnsafeBufferPointer { uBuf in
        vStar.withUnsafeBufferPointer { vBuf in
        div.withUnsafeMutableBufferPointer { divBuf in
        x.withUnsafeBufferPointer { x in
        y.withUnsafeBufferPointer { y in
        rx.withUnsafeBufferPointer { rx in

        if useConcurrence {
            DispatchQueue.concurrentPerform(iterations: workerCount) { wID in
                let startY = 1 + (wID * (ny - 2) / workerCount)
                let endY = 1 + ((wID + 1) * (ny - 2) / workerCount)
                
                divergence(startY: startY, endY: endY, &divBuf, uBuf, vBuf, x, y, rx)
            }
        } else {
            divergence(startY: 1, endY: ny-1, &divBuf, uBuf, vBuf, x, y, rx)
        }
        }}}}}}
        return div
    }
}
