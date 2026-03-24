//
//  stateManager.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 14.11.2025.
//

import Foundation
extension NavierStokesSolver {
    
    // методы для копирования и восстановления при расходимости
    
    func backupState() -> SolverState {
        return SolverState(t: t, u: u, v: v, p: p, T: T, liquidFraction: liquidFraction, isStone: isStone, rx: rx, dt: dt)
    }
    
    func restoreState(from state: SolverState) {
        t = state.t
        u = state.u
        v = state.v
        p = state.p
        T = state.T
        liquidFraction = state.liquidFraction
        isStone = state.isStone
        rx = state.rx
        dt = state.dt
    }
    
    
//    func updateDisplayData() {
//        // Обновление данных для визуализации в главном потоке
//        DispatchQueue.main.async { [self] in
//            displayData.updateFromSolver(
//                u: u,
//                v: v,
//                p: p,
//                T: T,
//                l_f: liquidFraction,
//                time: time
//            )
//        }
//    }
}

