//
//  addToStatistics.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 25.02.2026.
//
//MARK: - Add elements into Diagnostics and History

extension NavierStokesSolver {
    
    /// Добавление в диагностику и историю, принцип FIFO
    func addToStatistics(_ heatFluxW: Double, _ heatFluxE: Double, _ heatDiff: Double, _ maxVelocityValue: Double, _ currentCourant: Double) {
        
        avgTemp = showAvgTemp ? averageTemperature() : T_cold
                
        maxVelocity.append(maxVelocityValue)
        stabilityParams.append(currentCourant)
        pressureResiduals.append(maxPressureResidual)
        deltaTime.append(dt)
        timeStep.append(dTime)
        q_residual.append(heatDiff)
        T_avg_hotWall.append(averageTempHotwall)
        T_avg_volume.append(avgTemp)

        if stabilityParams.count > params.countsLimit {
            stabilityParams.removeFirst()
            pressureResiduals.removeFirst()
            maxVelocity.removeFirst()
            deltaTime.removeFirst()
            timeStep.removeFirst()
            q_residual.removeFirst()
            T_avg_hotWall.removeFirst()
            T_avg_volume.removeFirst()
        }
        
        // Добавление в историю
        if t.truncatingRemainder(dividingBy: params.timeGap) <= dt {
            q_coldWall.append(heatFluxE)
            q_hotWall.append(heatFluxW)
            timePoints.append(allowMelt ? initialTime + time : t)
            if q_coldWall.count > params.maxHistorySteps {
                q_coldWall.removeFirst()
                q_hotWall.removeFirst()
                timePoints.removeFirst()
            }
        }
        
        // Статистика по средней температуре вычисляется в методе applyTemperatureBoundaryConditions(:)
    }
}
