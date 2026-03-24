//
//  coldWallState.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 21.07.2025.
//

import SwiftUI

extension NavierStokesSolver {
    
    // Вычисление характеристик у правой границы (ALE)
    func coldWallState(_ heatFluxW: inout Double, _ heatFluxE: inout Double, _ heatDiff: inout Double) {
        
        var qE = [Double](repeating: 0, count: ny)
        var qW = [Double](repeating: 0, count: ny)
        
        let meltCoef = timeScale / rho / latentHeat
        let dtdx = dt / dx[0]
        
        // Внутренние точки -- в зависимости от dTdx
        for j in 1..<ny-1 {
            let rx_j = 1/rx[j] /// effective dx = grid dx•rx (приращение ширины при плавлении)

            let dTdx = wallDerivative(T[j][nx-1], T[j][nx-2], T[j][nx-3], dx[nx-2], dx[nx-3]) * rx_j ///  на границе плавления
            let dTdx_hot = wallDerivative(T[j][0], T[j][1], T[j][2], dx[0], dx[1]) * rx_j /// на горячей стенке
            
            /// Удельные тепловые потоки [W/m²]
            qE[j] = abs(lambda(T[j][nx-2]) * dTdx)  /// [W/m²]
            qW[j] = abs(lambda(T[j][1]) * dTdx_hot) /// [W/m²]
            
            /// Натуральная скорость движения фронта  плавления V melt [m/s]
            if allowMelt {
                if rx[j] >= Rx { /// запрет на  дальнейшее плавление
                    rx[j] = Rx /// ограничение по ширине
                    V_melt[j] = 0 /// теперь здесь - нулевая скорость границы
                    T[j][nx-1] = T[j][nx-2] /// теперь здесь -  адиабата
                } else {
                    ///  скорость продвижения границы [m/s]
                    V_melt[j] = qE[j] * meltCoef
                    /// прирост объема (ширины) с учетом коэф ускорения timeScale [1]
                    let widthIncrement = V_melt[j] * dtdx * rx_j
                    rx[j] += widthIncrement /// [1]
                }
            }
        }
        /// Крайние точки -- условие Неймана
        rx[0] = rx[1]
        rx[ny-1] = rx[ny-2]
        
        /// Вычисление средних величин объёма расплава и его приращения
        if allowMelt { updateMeltWidth() }
        
        // Добавление в статистику
        /// Средние тепловые потоки (удельная тепловая мощность) [W/m²]
        switch heatingType {
        case .temperature:
            heatFluxW = calculateAverageByHeight(value: qW)
        case .heatFlux:
            heatFluxW = calculateAverageByHeight(value: qW) /*heatingValue*/
        }
        heatFluxE = calculateAverageByHeight(value: qE)
        
        /// КПД плавления <qCold>/<qHot> [%]
        let q_diff = abs(heatFluxE / heatFluxW)*100
        heatDiff = q_diff
    }
    
}
