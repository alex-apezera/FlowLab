//
//  density.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 18.07.2025.
//

extension NavierStokesSolver {
    
    // Вычисление плотности по температуре
    func density(T: Double) -> Double {
        let T_ref = 0.5 * (T_max + T_cold) /// опорная плотность берется при T_ref
        return rho * (1 - beta * (T - T_ref))
    }
    
}
