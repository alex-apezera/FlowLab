//
//  initialize+reset.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 18.07.2025.
//
//MARK: - Initial conditions

extension NavierStokesSolver {
        
    /// Сброс в исходное состояние
    func reset() {
        initialize()
        initArrays()
        generateGrid()
        initTAndFraction()
        applyVelocityBoundaryConditions(&u, &v)
    }
}
