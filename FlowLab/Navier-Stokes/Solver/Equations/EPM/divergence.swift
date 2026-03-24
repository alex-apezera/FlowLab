//
//  divergence.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 18.01.2026.
//
import Foundation
extension NavierStokesSolver {
    
    // Оптимизированная версия Divergence (убираем лишние аллокации и vDSP)
    func calculateDivergence(uStar: [[Double]], vStar: [[Double]]) -> [[Double]] {
        var div = [[Double]](repeating: [Double](repeating: 0.0, count: nx), count: ny)
        let inv2h = 0.5 / h
        let localNX = nx
        let localNY = ny

        div.withUnsafeMutableBufferPointer { divRows in
            let divPtrs = (0..<localNY).map { j in divRows[j].withUnsafeMutableBufferPointer { $0.baseAddress! } }
            
            DispatchQueue.concurrentPerform(iterations: localNY - 2) { j_idx in
                let j = j_idx + 1
                let dPtr = divPtrs[j]
                // Прямой доступ к строкам входных массивов (уже запинены в вызывающем коде или пиним здесь)
                for i in 1..<(localNX - 1) {
                    let du = uStar[j][i+1] - uStar[j][i-1]
                    let dv = vStar[j+1][i] - vStar[j-1][i]
                    dPtr[i] = (du + dv) * inv2h
                }
            }
        }
        return div
    }

}
