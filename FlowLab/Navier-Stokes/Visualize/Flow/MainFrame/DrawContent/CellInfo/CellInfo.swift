//
//  CellInfo.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 17.03.2026.
//
import SwiftUI
/*
struct CellInfo {
    var x: Int, y: Int
    var u: Double, v: Double, p: Double
    var T: Double, liq: Double, stone: Bool
}
*/

struct CellInfo: Identifiable {
    let id = UUID()
    let xIndex: Int
    let yIndex: Int
    let u: Double
    let v: Double
    let p: Double
    let T: Double
    let liq: Double
    let isStone: Bool

    init?(fromIdx idx: Int, solver: NavierStokesSolver) { // Сделали init? (опциональным)
        let nx = solver.nx
        let ny = solver.ny
        
        let i = idx % nx
        let j = idx / nx
        
        // Проверка границ для двумерных массивов
        guard j >= 0 && j < ny,
              i >= 0 && i < nx else {
            return nil
        }
        
        self.xIndex = i
        self.yIndex = j
        
        // Двумерные данные -> 1D
        self.u = solver.u[idx]
        self.v = solver.v[idx]
        self.T = solver.T[idx]
        self.p = solver.p[idx]
        self.liq = solver.liquidFraction[idx]
        self.isStone = solver.isStone[idx] == 1
    }

}

