//
//  getSolidMask.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 16.03.2026.
//
extension NavierStokesSolver {
    
    /// Получение условий твердости:
    /// либо камень, либо застывшая фаза, включая границы
    @inline(__always) func getSolidMask() {
        for j in 0..<ny {
            let offset = j * nx
            for i in 0..<nx {
                let idx = offset + i
                if i == 0 || i == nx-1 || j == 0 || j == ny-1 ||  isStone[idx] == 1 || liquidFraction[idx] < dTm {
                    solidMask[idx] = 1 /// твердое тело
                } else {
                    solidMask[idx] = 0 /// любая субстанция
                }
            }
        }
    }
    
}
