//
//  averageTemp.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 06.03.2026.
//
extension NavierStokesSolver {
    
    //MARK: - Вычисление средне объёмной температуры в расплаве
    
    func averageTemperature() -> Double {
        if useEnthalpyMethod {
            var totalTemperature: Double = 0.0
            var totalLiquidPoints: Double = 0.0
            
            for j in 0..<ny {
                let jCell = j * nx
                for i in 0..<nx {
                    let idx = jCell + i
                    
                    let fraction = liquidFraction[idx]
                    if fraction > 0 { /// Учитываем только те ячейки, где есть жидкость
                        totalTemperature += T[idx] * fraction
                        totalLiquidPoints += fraction
                    }
                }
            }
            
            // Защита от деления на ноль, если расплава еще нет
            return totalLiquidPoints>0 ? totalTemperature / totalLiquidPoints : 0
            
        } else {
            var totalWeightedSum: Double = 0.0
            var totalAreaContribution: Double = 0.0 // Будем суммировать "вклад" каждой ячейки.

            for j in 0..<ny {
                let jCell = j * nx

                for i in 0..<nx {
                    let idx = jCell + i
                    
                    let cellValue = T[idx]
                    var weightCell: Double = 0.0
                    var numCells = 0.0

                    // Ячейка 1: (x[i], y[j]) - верхний левый угол
                    if j + 1 < ny && i + 1 < nx {
                        let dy = y[j+1] - y[j]
                        let dx = x[i+1] - x[i]
                        let rx = 0.5 * (rx[j] + rx[j+1])
                        weightCell += dx * dy * rx
                        numCells += 1.0
                    }
                    // Ячейка 2: (x[i], y[j]) - нижний левый угол
                    if j - 1 >= 0 && i + 1 < nx {
                        let dy = y[j] - y[j-1]
                        let dx = x[i+1] - x[i]
                        let rx = 0.5 * (rx[j] + rx[j-1])
                        weightCell += dx * dy * rx
                        numCells += 1.0
                    }
                    // Ячейка 3: (x[i], y[j]) - верхний правый угол
                    if j + 1 < ny && i - 1 >= 0 {
                        let dy = y[j+1] - y[j]
                        let dx = x[i] - x[i-1]
                        let rx = 0.5 * (rx[j] + rx[j+1])
                        weightCell += dx * dy * rx
                        numCells += 1.0
                    }
                    // Ячейка 4: (x[i], y[j]) - нижний правый угол
                    if j - 1 >= 0 && i - 1 >= 0 {
                        let dy = y[j] - y[j-1]
                        let dx = x[i] - x[i-1]
                        let rx = 0.5 * (rx[j] + rx[j-1])
                        weightCell += dx * dy * rx
                        numCells += 1.0
                    }
                    let totalWeight = weightCell / numCells
                    
                    totalWeightedSum += cellValue * totalWeight
                    totalAreaContribution += totalWeight
                }
            }

            return totalWeightedSum / totalAreaContribution
        }
    }
    
}
