//
//  thomasSolve.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 18.07.2025.
//

extension NavierStokesSolver {
    
    // Неявная диффузия с алгоритмом Томаса для НЕРАВНОМЕРНОЙ сетки
    
    func diffuse(quantity: inout [[Double]], isMomentum: Bool = false) {
        let maxInd: Int = max(nx, ny)
        var a = [Double](repeating: 0.0, count: maxInd)
        var b = [Double](repeating: 0.0, count: maxInd)
        var c = [Double](repeating: 0.0, count: maxInd)
        var d = [Double](repeating: 0.0, count: maxInd)
        
        // X-направление (внутренние точки по j)
        for j in 1..<ny-1 {
            
            // Заполняем коэффициенты для КАЖДОЙ точки i
            for i in 0..<nx {
                if i == 0 || i == nx-1 {
                    a[i] = 0.0; b[i] = 1.0 /// Граничные условия
                    c[i] = 0.0; d[i] = quantity[j][i]
                } else {
                    // ВНУТРЕННИЕ ТОЧКИ
                    let dx_west = (x[i] - x[i-1]) * rx[j] /// dx до западного узла
                    let dx_east = (x[i+1] - x[i]) * rx[j] /// dx до восточного узла
                    let dx_center = 0.5 * (dx_west + dx_east) /// средний  шаг
                    
                    // Коэффициент диффузии (может зависеть от T)
                    let currentDiff = isMomentum ? nu(T[j][i]) : alpha(T[j][i])
                    let diff_dt_current = currentDiff * dt
                    
                    let alpha_west = diff_dt_current / (dx_west * dx_center)
                    let alpha_east = diff_dt_current / (dx_east * dx_center)
                    
                    a[i] = -alpha_west; c[i] = -alpha_east
                    b[i] = 1.0 + alpha_west + alpha_east
                    d[i] = quantity[j][i]
                }
            }
            // Решаем прогонкой для ряда j
            let solution = thomasSolve(a, b, c, d, count: nx)
            
            // Обновляем ВСЕ точки (включая границы)
            for i in 0..<nx {
                quantity[j][i] = solution[i]
            }
        }
        
        // Y-направление (внутренние точки по i)
        for i in 1..<nx-1 {
            
            // Заполняем коэффициенты для КАЖДОЙ точки j
            for j in 0..<ny {
                if j == 0 || j == ny-1 {
                    // Граничные точки
                    a[j] = 0.0; b[j] = 1.0; c[j] = 0.0; d[j] = quantity[j][i]
                } else {
                    // ВНУТРЕННИЕ ТОЧКИ - учитываем неравномерность по Y
                    let dy_south = y[j] - y[j-1] /// dy до южного узла
                    let dy_north = y[j+1] - y[j] /// dy до северного узла
                    let dy_center = 0.5 * (dy_south + dy_north) /// средний шаг
                    
                    // Коэффициент диффузии (может зависеть от T)
                    let currentDiff = isMomentum ? nu(T[j][i]) : alpha(T[j][i])
                    let diff_dt_current = currentDiff * dt

                    // Коэффициенты диффузии с учетом неравномерной сетки
                    let alpha_south = diff_dt_current / (dy_south * dy_center)
                    let alpha_north = diff_dt_current / (dy_north * dy_center)
                    
                    a[j] = -alpha_south; c[j] = -alpha_north
                    b[j] = 1.0 + alpha_south + alpha_north
                    d[j] = quantity[j][i]
                }
            }
            
            let solution = thomasSolve(a, b, c, d, count: ny)
            
            // Обновляем ВСЕ точки
            for j in 0..<ny {
                quantity[j][i] = solution[j]
            }
        }
    }
}
