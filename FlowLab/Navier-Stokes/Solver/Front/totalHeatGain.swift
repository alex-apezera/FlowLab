//
//  heatGain.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 09.02.2026.
//

extension NavierStokesSolver {
   /*
    /// Совокупный (конвекция + диффузия) прирост теплового потока [W/m²]
    func calculateTotalHeatGain(_ r: Int, _ c: Int) -> Double {
        // локальные константы
        let nx = nx
        let ny = ny
        let lambda = lambda(T[idx(r, c)])
        let dx = h
        let rhoCp = rho * Cp
        var totalHeatGain = 0.0
        
        // соседние позиции: Right, Left, Down, Up
        // dr, dc пары: (0, +1), (0, -1), (+1, 0), (-1, 0)
        let neighbors = [(0, 1), (0, -1), (1, 0), (-1, 0)]
        // вычисление составляющих вокруг узла
        for (dr, dc) in neighbors {
            let nr = r + dr
            let nc = c + dc
            /// проверка границ области
            if nr < 0 || nr >= ny || nc < 0 || nc >= nx {
                continue
            }
           
            let nIndex = idx(nr, nc)
            if liquidFraction[nIndex] > 0.5 {  /// если достаточно жидкости
                let localT = T[nIndex]
                let deltaT = max(0.0, localT - T_melt)
                
                /// диффузионный вклад (теплопроводность)
                let qDiff = lambda * (deltaT / dx)
                
                /// конвективный вклад (перенос массой) - UpWind
                var qConv = 0.0
                /// если сосед не на границе (внутренняя ячейка), считаем конвективную часть
                let isBoundary = (nr == 0 || nr == ny - 1 || nc == 0 || nc == nx - 1)
                if !isBoundary {
                    let vel: Double
                    if dr == 0 && dc == 1 {       /// сосед справа
                        vel = -u[idx(r, c + 1)]
                    } else if dr == 0 && dc == -1 { /// сосед слева
                        vel = u[idx(r, c - 1)]
                    } else if dr == 1 && dc == 0 {  /// сосед снизу
                        vel = -v[idx(r + 1, c)]
                    } else {                      /// dr == -1, dc == 0 — сосед сверху
                        vel = v[idx(r - 1, c)]
                    }
                    qConv = max(0.0, vel * rhoCp * deltaT)
                }
                
                totalHeatGain += (qDiff + qConv)
            }
        }
        return totalHeatGain
    }
    */
    
    // Совокупный (конвекция + диффузия) прирост теплового потока [W/m²]
    @inline(__always)
    func calculateTotalHeatGain(_ r: Int, _ c: Int, _ dx: Double, _ lambda: Double, _ rho_Cp: Double, _ u: UnsafeBufferPointer<Double>, _ v: UnsafeBufferPointer<Double>, T: UnsafeMutableBufferPointer<Double>, liquidFraction: UnsafeMutableBufferPointer<Double>) -> Double {
        
        // Проверяем 4 грани ячейки
        let neighbors = [
            (r, c+1, "L"), // Сосед справа (поток идет влево)
            (r, c-1, "R"), // Сосед слева (поток идет вправо)
            (r+1, c, "D"), // Сосед сверху (поток идет вниз)
            (r-1, c, "U")  // Сосед снизу (поток идет вверх)
        ]
        
        var totalHeatGain = 0.0
        for (nr, nc, dir) in neighbors {
            if liquidFraction[idx(nc,nr)] > 0.5 {
                let localT = T[idx(nc,nr)]
                let deltaT = max(0, localT - T_melt)
                
                // 1. Диффузионный вклад (Теплопроводность) - 1й порядок
                let q_diff = lambda * (deltaT / dx) /// [W/m²]
                
                // 2. Конвективный вклад (Перенос массой), UpWind
                var q_conv = 0.0 /// [W/m²]
                if dir == "L" { /// Поток через правую грань
                    let velocity = -u[idx(c+1,r)]
                    q_conv = max(0, velocity * rho_Cp * deltaT)
                } else if dir == "R" { /// Через левую
                    let velocity = u[idx(c-1,r)]
                    q_conv = max(0, velocity * rho_Cp * deltaT)
                } else if dir == "D" { /// Через верхнюю
                    let velocity = -v[idx(c,r+1)]
                    q_conv = max(0, velocity * rho_Cp * deltaT)
                } else if dir == "U" { /// Через нижнюю
                    let velocity = v[idx(c,r-1)]
                    q_conv = max(0, velocity * rho_Cp * deltaT)
                }
                // Внутри цикла по соседям
                if nr == 0 || nr == ny-1 || nc == 0 || nc == nx-1 {
                    q_conv = 0.0 /// Если сосед - физическая стенка полости
                }
                
                totalHeatGain += (q_diff + q_conv) /// [W/m²]
            }
        }
        return totalHeatGain
    }

}
