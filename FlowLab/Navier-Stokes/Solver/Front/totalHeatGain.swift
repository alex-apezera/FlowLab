//
//  heatGain.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 09.02.2026.
//

extension NavierStokesSolver {
    
    // Совокупный (конвекция + диффузия) прирост теплового потока [W/m²]
    func calculateTotalHeatGain(_ r: Int, _ c: Int) -> Double {
//        var lambda = lambda(T[r][c])
        let dx = h
        var totalHeatGain = 0.0
        let lambda = lambda(T_melt)
        let rho_Cp = rho * Cp
        
        // Проверяем 4 грани ячейки
        let neighbors = [
            (r, c+1, "L"), // Сосед справа (поток идет влево)
            (r, c-1, "R"), // Сосед слева (поток идет вправо)
            (r+1, c, "D"), // Сосед сверху (поток идет вниз)
            (r-1, c, "U")  // Сосед снизу (поток идет вверх)
        ]
        
        for (nr, nc, dir) in neighbors {
            if liquidFraction[idx(nc,nr)] > 0.5 {
                let localT = T[nr][nc]
                let deltaT = max(0, localT - T_melt)
                
                // 1. Диффузионный вклад (Теплопроводность) - 1й порядок
                let q_diff = lambda * (deltaT / dx) /// [W/m²]
                
                // 2. Конвективный вклад (Перенос массой), UpWind
                var q_conv = 0.0 /// [W/m²]
                if dir == "L" { /// Поток через правую грань
                    let velocity = -u[r][c+1]
                    q_conv = max(0, velocity * rho_Cp * deltaT)
                } else if dir == "R" { /// Через левую
                    let velocity = u[r][c-1]
                    q_conv = max(0, velocity * rho_Cp * deltaT)
                } else if dir == "D" { /// Через верхнюю
                    let velocity = -v[r+1][c]
                    q_conv = max(0, velocity * rho_Cp * deltaT)
                } else if dir == "U" { /// Через нижнюю
                    let velocity = v[r-1][c]
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
