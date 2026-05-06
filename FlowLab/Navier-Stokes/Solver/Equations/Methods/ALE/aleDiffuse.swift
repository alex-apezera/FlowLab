//
//  aleDiffuse.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 18.07.2025.
//
//MARK: - Diffusion for 𝐕 and T (ALE)

import Foundation
extension NavierStokesSolver {
    
    /// Подготовка потоков для диффузионных членов  ALE.
    func aleDiffuse(quantity: inout [Double], isMomentum: Bool = false) {

        // ИЗВЛЕКАЕМ УКАЗАТЕЛИ (Pinning)
        quantity.withUnsafeMutableBufferPointer { property in
        self.T.withUnsafeBufferPointer { T in
        self.dx.withUnsafeBufferPointer { dx in
        self.dy.withUnsafeBufferPointer { dy in

        if useParallelDiffusion {
            DispatchQueue.concurrentPerform(iterations: workerCount) { wID in
                let startY = 1 + (wID * (ny - 2) / workerCount)
                let endY = 1 + ((wID + 1) * (ny - 2) / workerCount)
                diffuseX(property, nx, ny, startY, endY, T, dx, dy, isMomentum)
            }
            DispatchQueue.concurrentPerform(iterations: workerCount) { wID in
                let startX = 1 + (wID * (nx - 2) / workerCount)
                let endX = 1 + ((wID + 1) * (nx - 2) / workerCount)
                diffuseY(property, nx, ny, startX, endX, T, dx, dy, isMomentum)
            }
            
        } else {
            diffuseX(property, nx, ny, 1, ny-1, T, dx, dy, isMomentum)
            diffuseY(property, nx, ny, 1, nx-1, T, dx, dy, isMomentum)
        }
        }}}}///ptr
    }
    
    /// Вычисление коэффициентов для прогонки по строкам по оси X
    fileprivate func diffuseX(_ quantity: Mutable, _ nx: Int, _ ny: Int, _ startY: Int, _ endY: Int, _ T: ReadOnly, _ dx: ReadOnly, _ dy: ReadOnly, _ isMomentum: Bool) {
        
        let dt = self.dt, T_cold = self.T_cold

        var a = [Double](repeating: 0.0, count: nx)
        var b = [Double](repeating: 0.0, count: nx)
        var c = [Double](repeating: 0.0, count: nx)
        var d = [Double](repeating: 0.0, count: nx)
        var cP = [Double](repeating: 0.0, count: nx)
        var dP = [Double](repeating: 0.0, count: nx)
        var sol = [Double](repeating: 0.0, count: nx)

        for j in startY..<endY {
            let row = j * nx
            let rxJ = rx[j]
            
            let jStart = Int(params.y_start * Double(ny))
            let jEnd = Int(params.y_end * Double(ny))
            let isTempAdiabat = !isMomentum && params.useWind && outlet(jStart, jEnd, j)
            
            for i in 0..<nx {
                let idx = row + i
                let quantity = quantity[idx]
                
                // ГРАНИЧНЫЕ УСЛОВИЯ, вертикальные стенки
                if i == 0 { /// левая стенка
 
                    /// для всех переменных
                    a[i] = 0.0; b[i] = 1.0
                    if isTempAdiabat {c[i] = -1.0; d[i] = 0.0}///вдув/сток
                    else { c[i] = 0.0; d[i] = quantity }

                } else if i == nx - 1 { /// правая стенка/граница

                    /// прилипание для скоростей
                    if isMomentum {
                        a[i] = 0; b[i] = 1; c[i] = 0; d[i] = 0
                    /// условия для температуры
                    } else if allowMelt && rxJ >= Rx {///фронт уперся в стенку
                        if params.useNeiman { /// условие Неймана dT/dx=0
                            a[i] = -1; b[i] = 1; c[i] = 0; d[i] = 0
                        } else { /// условие Дирихле T = T cold
                            a[i] = 0; b[i] = 1; c[i] = 0; d[i] = T_cold
                        }
                    } else { /// плавления нет: простая конвекция: T = T cold
                        a[i] = 0; b[i] = 1; c[i] = 0; d[i] = T_cold
                    }
                    
                    // ВНУТРЕННИЕ ТОЧКИ
                } else {
                    let T = T[idx]

                    let dx_west = dx[i-1] * rxJ
                    let dx_east = dx[i] * rxJ
                    let dx_center = 0.5 * (dx_west + dx_east)
                    let currentDiff = isMomentum ? nu(T) : alpha(T)
                    let diff_dt_current = currentDiff * dt
                    let alpha_west = diff_dt_current / (dx_west * dx_center)
                    let alpha_east = diff_dt_current / (dx_east * dx_center)
                    
                    a[i] = -alpha_west
                    c[i] = -alpha_east
                    b[i] = 1.0 + alpha_west + alpha_east
                    d[i] = quantity
                }
            }
            thomasSolveInPlace(a, b, c, d, count: nx, solution: &sol, cPrime: &cP, dPrime: &dP)

            for i in 0..<nx { quantity[row+i] = sol[i] }///фиксация
        }
    }
    
    /// Вычисление коэффициентов для прогонки по столбцам по оси Y
    fileprivate func diffuseY(_ quantity: Mutable, _ nx: Int, _ ny: Int, _ startX: Int, _ endX: Int, _ T: ReadOnly, _ dx: ReadOnly, _ dy: ReadOnly, _ isMomentum: Bool) {
 
        let dt = self.dt, useWind = self.params.useWind

        
        // СОЗДАЕМ БУФЕРЫ ОДИН РАЗ ДЛЯ ПОТОКА
        var a = [Double](repeating: 0.0, count: ny)
        var b = [Double](repeating: 0.0, count: ny)
        var c = [Double](repeating: 0.0, count: ny)
        var d = [Double](repeating: 0.0, count: ny)
        var cP = [Double](repeating: 0.0, count: ny)
        var dP = [Double](repeating: 0.0, count: ny)
        var sol = [Double](repeating: 0.0, count: ny)
        
        for i in startX..<endX {
            // РАБОТА СО СТОЛБЦОМ
            for j in 0..<ny {
                let idx = j*nx + i
                let T = T[idx]
                let quantity = quantity[idx]
                
                // ГРАНИЧНЫЕ УСЛОВИЯ, горизонтальные стенки
                if j == 0 {
                    /// нижняя --  dT/dy = 0; u, v = 0; есть сток: du/dy,  dv/dy = 0
                    a[j] = 0.0; b[j] = 1.0; c[j] = isMomentum && !useWind ? 0.0 : -1.0; d[j] = 0.0
                } else if j == ny-1 { ///верхняя -- аналогично нижней
                    a[j] = isMomentum && !useWind ? 0.0 : -1.0; b[j] = 1.0; c[j] = 0.0; d[j] = 0.0
                    
                    // ВНУТРЕННИЕ ТОЧКИ
                } else {
                    let dy_south = dy[j-1]
                    let dy_north = dy[j]
                    let dy_center = 0.5 * (dy_south + dy_north)
                    let currentDiff = isMomentum ? nu(T) : alpha(T)
                    let diff_dt_current = currentDiff * dt
                    let alpha_south = diff_dt_current / (dy_south * dy_center)
                    let alpha_north = diff_dt_current / (dy_north * dy_center)
                    
                    a[j] = -alpha_south
                    c[j] = -alpha_north
                    b[j] = 1.0 + alpha_south + alpha_north
                    d[j] = quantity
                }
            }
            
            thomasSolveInPlace(a, b, c, d, count: ny, solution: &sol, cPrime: &cP, dPrime: &dP)

            for j in 0..<ny { quantity[j*nx+i] = sol[j] }///фиксация
        }
    }

}
