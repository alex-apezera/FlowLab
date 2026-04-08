//
//  aleDiffuse.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 18.07.2025.
//

extension NavierStokesSolver {
    
    /// Неявная диффузия с алгоритмом Томаса для НЕРАВНОМЕРНОЙ сетки
    func aleDiffuse(quantity: inout [Double], isMomentum: Bool = false) {
        let nx = self.nx, ny = self.ny
        
        // X-направление (внутренние точки по j)
        for j in 1..<ny-1 {
            let row = j * nx
            let rxJ = rx[j]
            // Заполняем коэффициенты для КАЖДОЙ точки i
            for i in 0..<nx {
                let idx = i + row
                if i == 0 || i == nx-1 {
                    a[i] = 0.0; b[i] = 1.0 /// Граничные условия
                    c[i] = 0.0; d[i] = quantity[idx]
                } else {
                    // ВНУТРЕННИЕ ТОЧКИ
                    /// dx[i] = x[i+1] - x[i]   see generateGrid()
                    let dx_west = dx[i-1] * rxJ /// dx до западного узла
                    let dx_east = dx[i] * rxJ /// dx до восточного узла
                    let dx_center = 0.5 * (dx_west + dx_east)///средний  шаг

                    // Коэффициент диффузии (может зависеть от T)
                    let T = T[idx]
                    let currentDiff = isMomentum ? nu(T) : alpha(T)
                    let diff_dt_current = currentDiff * dt
                    
                    let alpha_west = diff_dt_current / (dx_west * dx_center)
                    let alpha_east = diff_dt_current / (dx_east * dx_center)
                    
                    a[i] = -alpha_west; c[i] = -alpha_east
                    b[i] = 1.0 + alpha_west + alpha_east
                    d[i] = quantity[idx]
                }
            }
            // Решаем прогонкой для ряда j
            thomasSolveInPlace(a: a, b: b, c: c, d: d, count: nx, solution: &sol, cPrime: &cP, dPrime: &dP)

            // Обновляем ВСЕ точки (включая границы)
            for i in 0..<nx {
                quantity[row+i] = sol[i]
            }
        }
        
        // Y-направление (внутренние точки по i)
        for i in 1..<nx-1 {
            
            // Заполняем коэффициенты для КАЖДОЙ точки j
            for j in 0..<ny {
                let idx = j*nx + i
                if j == 0 || j == ny-1 {
                    // Граничные точки
                    a[j] = 0.0; b[j] = 1.0; c[j] = 0.0; d[j] = quantity[idx]
                } else {
                    // ВНУТРЕННИЕ ТОЧКИ - учитываем неравномерность по Y
                    let dy_south = dy[j-1] /// dy до южного узла
                    let dy_north = dy[j] /// dy до северного узла
                    let dy_center = 0.5 * (dy_south + dy_north) /// средний шаг
                    
                    // Коэффициент диффузии (может зависеть от T)
                    let T = T[idx]
                    let currentDiff = isMomentum ? nu(T) : alpha(T)
                    let diff_dt_current = currentDiff * dt

                    // Коэффициенты диффузии с учетом неравномерной сетки
                    let alpha_south = diff_dt_current / (dy_south * dy_center)
                    let alpha_north = diff_dt_current / (dy_north * dy_center)
                    
                    a[j] = -alpha_south; c[j] = -alpha_north
                    b[j] = 1.0 + alpha_south + alpha_north
                    d[j] = quantity[idx]
                }
            }
            // Решаем прогонкой для строки i
            thomasSolveInPlace(a: a, b: b, c: c, d: d, count: ny, solution: &sol, cPrime: &cP, dPrime: &dP)

            // Обновляем ВСЕ точки
            for j in 0..<ny {
                quantity[j*nx+i] = sol[j]
            }
        }
    }
}
