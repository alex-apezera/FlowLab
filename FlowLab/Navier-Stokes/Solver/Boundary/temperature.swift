//
//  temperature.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 05.01.2026.
//

extension NavierStokesSolver {
    
    // Температура
    func applyTemperatureBoundaryConditions(_ T: inout [Double]) {
        
        for j in 0..<ny {
            /// Горячая стенка
            switch heatingType {
            case .heatFlux: /// постоянный тепловой поток [W/m²]
                let T_near_wall = T[idx(1,j)]
                T[idx(0,j)] = T_near_wall + heatingValue * x[1] * rx[j] / lambda(T_near_wall) /// первый порядок точности
//                T[j][0] = wallTempByFlux(T_near_wall, T[j][2], x[1] * rx[j], (x[2]-x[1]) * rx[j], heatFlux: heatingValue, lambda: lambda(T_near_wall))
            case .temperature: /// постоянная температура [ºC]
                T[idx(0,j)] = heatingValue + T_melt
            }
            
            /// Холодная стенка
            T[idx(nx-1,j)] = T_cold

            /// Учет плавления
            if useEnthalpyMethod && liquidFraction[idx(nx-2, j)] > dTm && allowMelt {
                /// Если ячейка у правой стенки всё еще твердая - держим T cold
                /// Если фронт подошел близко - изолируем её (адиабата)
                T[idx(nx-1,j)] = T[idx(nx-2,j)] /// условие Неймана  (поток тепла вправо 0)
            } else {
                T[idx(nx-1,j)] = T_cold // Твердое тело остается холодным
            }
        }
//        print("Step: \(step)")
//        print("T_hot-ПЕРВЫЙ порядок точности \(T[ny/2][0])")
//        print("T_hot-ВТОРОЙ порядок точности \(T[ny/2][0])")

        // Адиабатические условия вблизи границ y = 0, y = Ly
        for i in 0..<nx {
            T[idx(i,0)] = T[idx(i,1)]
            T[idx(i,ny-1)] = T[idx(i,ny-2)]
        }
        
        // Угловые точки
        T[idx(nx-1,0)] = T_cold
        T[idx(nx-1,ny-1)] = T_cold
        
    }
}
