//
//  solveEquations.swift
//  FlowLab
//
//  Created by Алексей Езерский on 02.05.2026.
//
//MARK: - Solve equations for all methods

import Foundation
extension NavierStokesSolver {
    
    /// Решение уравнений движения, неразрывности, энергии
    func solveΕquations() async throws {
        
        makeVelocitiesIsZero(&u, &v) /// при наличии выключателя
        
        if useEnthalpyMethod { /// EPM,  square grid
            
            var uNew = u, vNew = v
            epmMomentum(&uNew, &vNew)
            epmPressure(uNew, vNew) /// Gauss-Seidel, коррекция u, v
            epmEnergy()
            
            
        } else { /// ALE,  nonregular grid
            aleMomentum()/// конвекция с поправками скоростей  + диффузия
            alePressure()///уравнение для давления с итерациями Jacobi
            aleEnergy()/// конвекция +  диффузия
        }
    }
}
