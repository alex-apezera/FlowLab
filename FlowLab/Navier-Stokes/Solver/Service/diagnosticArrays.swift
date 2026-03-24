//
//  diagnosticArrays.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 09.11.2025.
//

extension NavierStokesSolver {
    func diagnosticArrays(_ maxVelocityValue: Double, _ currentCourant: Double) {
        
        // Контроль предельного размера массивов со сдвигом FIFO
        if stabilityParams.count >= params.countsLimit {
            stabilityParams.removeFirst()
            pressureResiduals.removeFirst()
            maxVelocity.removeFirst()
            deltaTime.removeFirst()
            timeStep.removeFirst()
        }
        
        // Формирование массивов свойств отслеживания хода решения
        maxVelocity.append(maxVelocityValue)
        stabilityParams.append(currentCourant)
        pressureResiduals.append(maxPressureResidual)
        deltaTime.append(dt)
        timeStep.append(dTime)
    }
}
