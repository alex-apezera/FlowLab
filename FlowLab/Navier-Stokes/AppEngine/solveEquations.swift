//
//  solveEquations.swift
//  FlowLab
//
//  Created by Алексей Езерский on 02.05.2026.
//
import Foundation
extension NavierStokesSolver {
    
    /// Решение уравнений движения, неразрывности, энергии
    func solveΕquations() async throws {
        
        makeVelocitiesIsZero(&u, &v) /// при наличии выключателя
        
        if useEnthalpyMethod { /// EPM, Gauss-Seidel, square grid
            var uNew = u, vNew = v, TNew = T

            useConcurrence ?
            epmMomentumPar(&uNew, &vNew) : epmMomentum(&uNew, &vNew)
            
            epmPressurePar(uNew, vNew)/// ⬅︎  u, v обновлены внутри

            useConcurrence ?
            epmEnergyPar(&TNew) : epmEnergy(&TNew); T = TNew

            updatePhaseChange()/// обновление фазы (+ плавление)

        } else { /// ALE, Jacobi, nonregular grid
            
            aleMomentum()/// ⬅︎  + параллельность диффузии внутри
            
            useParallelPressure ? ///уравнение для p с поправками u, v
            alePressurePar() : alePressure()
            
            aleEnergy()/// ⬅︎  + параллельность диффузии внутри
        }
    }
}
