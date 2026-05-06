//
//  initialize.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 21.02.2026.
//
//MARK: - Initial parameters State

extension NavierStokesSolver {
    
    /// Исходное состояние параметров решения
    func initialize () {
        dt = params.timeStep; step = 0; iterations = 0; t = 0
        rx_avg = 1.0; rx_avg_old = 1.0; V_melt_avg = 0.0
        params.relaxationFactor = relaxationFactor
        params.maxIterations = maxIterations

        /// Вычисление h - единого шага сетки (прямоугольная полость, квадратная сетка)
        if useEnthalpyMethod { calculateGridStep() }

    }
}
