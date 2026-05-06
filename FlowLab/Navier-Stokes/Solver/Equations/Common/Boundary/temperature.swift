//
//  temperature.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 05.01.2026.
//
//MARK: - Граничные условия для температуры

extension NavierStokesSolver {
    
    /// Явные Граничные условия для Температуры
    func applyTemperatureBoundaryConditions(_ T: inout [Double]) {
        let jStart = Int(params.y_start * Double(ny))
        let jEnd = Int(params.y_end * Double(ny))
        T.withUnsafeMutableBufferPointer { T in
            
        for j in 0..<ny {
            let row = j*nx, idxW = row, idxE = row+nx-1
            let rxJ = useEnthalpyMethod ? 1.0 : rx[j]
            /// Горячая стенка
            switch heatingType {
            case .heatFlux: /// постоянный тепловой поток [W/m²]
                let T_near_wall = T[idxW+1]
                T[idxW] = T_near_wall + heatingValue * x[1] * rxJ / lambda(T_near_wall) /// первый порядок точности
            case .temperature: /// постоянная температура [ºC]
                let inletCondition = params.useWind && (j>=jStart && j<=jEnd)
                if inletCondition {
                    T[idxW] = heatingValue + params.windDeltaTemp + T_melt
                } else {
                    T[idxW] = heatingValue + T_melt
                }
            }
            
            /// Холодная стенка
            /// ALE - фронт коснулся стенки
            if params.useNeiman && !useEnthalpyMethod && rx.max()! >= Rx {
                T[idxE] = T[idxE-1] /// теперь здесь -  адиабата (условие Неймана)
            /// ALE + EPM: стандартное условие
            } else { /// условие Дирихле
                T[idxE] = T_cold
            }
            
            /// Учет плавления с условием Неймана  (поток тепла вправо 0)
            if useEnthalpyMethod && liquidFraction[idxE-1] > dTm && params.useNeiman && allowMelt {
                /// Если ячейка у правой стенки всё еще твердая - держим T cold
                /// Если фронт подошел близко - изолируем её (адиабата)
                T[idxE] = T[idxE-1]
            }
        }
        
        // Адиабатические условия вблизи границ y = 0, y = Ly
        // Первый порядок
        for i in 0..<nx {
            T[idx(i,0)] = T[idx(i,1)]
            T[idx(i,ny-1)] = T[idx(i,ny-2)]
        }
        
        // Угловые точки
        T[idx(0,0)] = T[idx(0,1)]
        T[idx(0,ny-1)] = T[idx(0,ny-2)]
        T[idx(nx-1,0)] = T_cold
        T[idx(nx-1,ny-1)] = T_cold
        
//        print("T[row=50] = \(T[idx(0,ny/2)])")
    }
    }///ptr
}
//    var T: MutPtr!
//    self.T.withUnsafeMutableBufferPointer { ptr in T = ptr.baseAddress! }
