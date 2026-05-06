//
//  SolverState.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 14.11.2025.
//
//MARK: - Auxiliary structure of the solution state

/// Вспомогательая структура состояния решения
struct SolverState {
    let t: Double
    let u, v, p, T, liquidFraction : [Double]
    let isStone: [UInt8]
    let rx: [Double]
    let dt: Double
}
