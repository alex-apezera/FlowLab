//
//  correctVelocities.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 12.01.2026.
//

import Foundation
extension NavierStokesSolver {
    /// Коррекция скорости для solvePressureEnthalpy
    // Pinning
    func correctVelocities(_ uNew: [[Double]], _ vNew: [[Double]]) {
        let dt_rho_inv2h = dt / (rho * 2.0 * h)
        let dt_rho_h = dt_rho_inv2h
        let localNX = nx
        let localNY = ny

        getSolidMask()
        
        // ИЗВЛЕКАЕМ УКАЗАТЕЛИ (Pinning)
        // Это гарантирует, что адреса строк не изменятся внутри блока
        u.withUnsafeMutableBufferPointer { uRows in
            let uPtrs = (0..<localNY).map { j in uRows[j].withUnsafeMutableBufferPointer { $0.baseAddress! } }
            
            v.withUnsafeMutableBufferPointer { vRows in
                let vPtrs = (0..<localNY).map { j in vRows[j].withUnsafeMutableBufferPointer { $0.baseAddress! } }
                
                solidMask.withUnsafeBufferPointer { maskPtr in
                    nonisolated(unsafe) let m = maskPtr.baseAddress!
 
                    // Striding - параллельные вычисления
                    DispatchQueue.concurrentPerform(iterations: localNY - 2) { j_idx in
                        let j = j_idx + 1 /// цикл по j
//                        let offset = j * localNX
                        let (jCell, jTop, jBot) = yOffsets(j)
                        
                        for i in 1..<localNX-1 {
                            let idx = jCell + i, idxT = jTop + i, idxB = jBot + i
                            
                            let m_row = m + jCell
                            let m_next = m + jTop
                            let m_prev = m + jBot

                            // Если ячейка твердая — скорость всегда 0
                            if m_row[i] == 1 { uPtrs[j][i] = 0; vPtrs[j][i] = 0; continue }
                            
                            // --- КОРРЕКЦИЯ U (горизонтальная) ---
                            // Если сосед справа/слева — камень, берем давление текущей ячейки (p_cell)
                            let p_cell = p[idx]
                            let p_right = (m_row[i+1] == 1) ? p_cell : p[idx+1]
                            let p_left  = (m_row[i-1] == 1) ? p_cell : p[idx-1]
                            uPtrs[j][i] = uNew[j][i] - dt_rho_h * (p_right - p_left)
                            
                            // --- КОРРЕКЦИЯ V (вертикальная) ---
                            // Если сосед сверху/снизу — камень, используем p_cell
                            let p_top = (m_next[i] == 1) ? p_cell : p[idxT]
                            let p_bot = (m_prev[i] == 1) ? p_cell : p[idxB]
                            vPtrs[j][i] = vNew[j][i] - dt_rho_h * (p_top - p_bot)
   
                        }
                    }
                }
            }
        }
    }
}
