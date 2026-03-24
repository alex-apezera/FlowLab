//
//  addToStatistics.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 25.02.2026.
//
extension NavierStokesSolver {
    
    func addToStatistics(_ heatFluxW: Double, _ heatFluxE: Double, _ heatDiff: Double, _ maxVelocityValue: Double, _ currentCourant: Double) {
        
//        let T_hotwall_avg = averageTempHotwall
        avgTemp = showAvgTemp ? averageTemperature() : 0
        
        // Добавление в диагностику и историю, принцип FIFO
        
        // Формирование массивов свойств отслеживания хода решения
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
            if q_coldWall.count > params.maxHistorySteps {
                q_coldWall.removeFirst()
                q_hotWall.removeFirst()
            }
        }
        
        // Статистика по средней температуре вычисляется в методе applyTemperatureBoundaryConditions(:)
    }
}
