//
//  temperature.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 05.01.2026.
//

extension NavierStokesSolver {
    
    // Температура
    func applyTemperatureBoundaryConditions(_ T: inout [[Double]]) {
        
        for j in 0..<ny {
            /// Горячая стенка
            switch heatingType {
            case .heatFlux: /// постоянный тепловой поток [W/m²]
                let T_near_wall = T[j][1]
                T[j][0] = T_near_wall + heatingValue * x[1] * rx[j] / lambda(T_near_wall) /// первый порядок точности
//                T[j][0] = wallTempByFlux(T_near_wall, T[j][2], x[1] * rx[j], (x[2]-x[1]) * rx[j], heatFlux: heatingValue, lambda: lambda(T_near_wall))
            case .temperature: /// постоянная температура [ºC]
                T[j][0] = heatingValue + T_melt
            }
            
            /// Холодная стенка
            T[j][nx-1] = T_cold

            /// Учет плавления
            if useEnthalpyMethod && liquidFraction[idx(nx-2, j)] > dTm && allowMelt {
                /// Если ячейка у правой стенки всё еще твердая - держим T cold
                /// Если фронт подошел близко - изолируем её (адиабата)
                T[j][nx-1] = T[j][nx-2] /// условие Неймана  (поток тепла вправо 0)
            } else {
                T[j][nx-1] = T_cold // Твердое тело остается холодным
            }
        }
//        print("Step: \(step)")
//        print("T_hot-ПЕРВЫЙ порядок точности \(T[ny/2][0])")
//        print("T_hot-ВТОРОЙ порядок точности \(T[ny/2][0])")

        // Адиабатические условия вблизи границ y = 0, y = Ly
        for i in 0..<nx {
            T[0][i] = T[1][i]
            T[ny-1][i] = T[ny-2][i]
        }
        
        // Угловые точки
        T[0][nx-1] = T_cold
        T[ny-1][nx-1] = T_cold
        
        // Контроль пределов
    }
}
