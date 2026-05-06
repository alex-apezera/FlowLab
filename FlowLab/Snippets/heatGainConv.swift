//
//  heatGainConv.swift
//  FlowLab
//
//  Created by Алексей Езерский on 17.05.2026.
//

// MARK: - Совокупный прирост теплового потока

extension NavierStokesSolver {
    
    /// Совокупный (конвекция + диффузия) прирост теплового потока [W/m²]
    /// - 1й порядок точности, подключение необходимо при ненулевых скоростях на границе
    @inline(__always)
    func heatGainConv(_ r: Int, _ c: Int, _ dx: Double, _ lambda: Double, _ rho_Cp: Double, _ u: [Double], _ v: [Double], T: [Double], liquidFraction: [Double]) -> Double {
        
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
                
                /// Диффузионный вклад (Теплопроводность)
                let q_diff = lambda * (deltaT / dx) /// [W/m²]
                
                /// Конвективный вклад (учитывается ненулевой поток через границу), UpWind
                var q_conv = 0.0 /// [W/m²]
//                if useGradientCorrection {
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
//                }
                
                totalHeatGain += (q_diff + q_conv) /// [W/m²]
            }
        }
        return totalHeatGain
    }
}
