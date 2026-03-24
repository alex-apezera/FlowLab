//
//  inlineGet.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 10.03.2026.
//
extension NavierStokesSolver {
    
    /// Вспомогательная функция для получения T, lf с учетом границ (условие Неймана: dT/dn = 0)
    @inline(__always)
    func getT(_ j: Int, _ i: Int) -> Double {
        let jj = max(0, min(ny - 1, j))
        let ii = max(0, min(nx - 1, i))
        return T[jj][ii]
    }
    
    @inline(__always)
    func getF(_ j: Int, _ i: Int) -> Double {
        let jj = max(0, min(ny - 1, j))
        let ii = max(0, min(nx - 1, i))
        return liquidFraction[idx(ii, jj)]
    }
    
    
}
