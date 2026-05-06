//
//  inlineGet.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 10.03.2026.
//
//MARK: - Get Value by Neumann

extension NavierStokesSolver {
    
    /// Вспомогательная функция для получения T с учетом границ (Нейман: dT/dn = 0)
    @inline(__always)
    func getT(_ j: Int, _ i: Int) -> Double {
        let jj = max(0, min(ny - 1, j))
        let ii = max(0, min(nx - 1, i))
        return T[idx(ii,jj)]
    }
    
    /// Вспомогательная функция для получения фракции с учетом границ (Нейман: dT/dn = 0)
    @inline(__always)
    func getF(_ j: Int, _ i: Int) -> Double {
        let jj = max(0, min(ny - 1, j))
        let ii = max(0, min(nx - 1, i))
        return liquidFraction[idx(ii, jj)]
    }
    
    /// Вспомогательная функция для логики "островов"
    @inline(__always)
    func getMaxNeighborF(_ j: Int, _ i: Int) -> Double {
        return max(getF(j, i+1), getF(j, i-1), getF(j+1, i), getF(j-1, i))
    }

}
