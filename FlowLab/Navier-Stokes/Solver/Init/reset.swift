//
//  initialize+reset.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 18.07.2025.
//
import Foundation
extension NavierStokesSolver {
    
    //MARK: - Начальные условия
    
    /// Сброс в исходное состояние
    func reset() {
        initialize()
        initArrays()
        generateGrid()
        initTAndFraction()
        getSolidMask()
    }
}
