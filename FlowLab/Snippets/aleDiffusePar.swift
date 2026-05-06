//
//  diffuseParallel.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 14.01.2026.
//
/*
import Foundation
extension NavierStokesSolver {
    
    /// Многопоточное вычисление  коэффициентов TDMA для диффузионных членов  ALE
    func aleDiffusePar(quantity: inout [Double], isMomentum: Bool = false) {
        let nx = self.nx, ny = self.ny
        let dt = self.dt, T_cold = self.T_cold
        
        // ИЗВЛЕКАЕМ УКАЗАТЕЛИ (Pinning)
        var property: MutPtr!
        var T: Pntr!, dx: Pntr!, dy: Pntr!
        quantity.withUnsafeMutableBufferPointer { ptr in property = ptr.baseAddress! }
        self.T.withUnsafeBufferPointer { ptr in T = ptr.baseAddress! }
        self.dx.withUnsafeBufferPointer { ptr in dx = ptr.baseAddress! }
        self.dy.withUnsafeBufferPointer { ptr in dy = ptr.baseAddress!}
        
//        quantity.withUnsafeMutableBufferPointer { property in
//        T.withUnsafeBufferPointer { T in
//        dx.withUnsafeBufferPointer { dx in
//        dy.withUnsafeBufferPointer { dy in

        let workerCount = self.workerCount
        // 1. X-направление
        DispatchQueue.concurrentPerform(iterations: workerCount) { wID in
            let startY = 1 + (wID * (ny - 2) / workerCount)
            let endY = 1 + ((wID + 1) * (ny - 2) / workerCount)
            
            // СОЗДАЕМ БУФЕРЫ ОДИН РАЗ ДЛЯ ПОТОКА
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
                
                for i in 0..<nx {
                    let idx = row + i
                    let T = T[idx]
                    let quantity = property[idx]
                    
                    // ГРАНИЧНЫЕ УСЛОВИЯ, вертикальные стенки
                    if i == 0 { /// левая стенка
                        a[i] = 0.0; b[i] = 1.0; c[i] = 0.0;
                        d[i] = isMomentum ? 0.0 : T
                    } else if i == nx - 1 { /// правая стенка/граница
                        if isMomentum {
                            a[i] = 0; b[i] = 1; c[i] = 0; d[i] = 0
                        } else if allowMelt && rxJ >= Rx { /// фронт уперся в стенку:  dT/dx = 0
                            a[i] = -1; b[i] = 1; c[i] = 0; d[i] = 0
                        } else { /// плавления нет: простая конвекция: T = T cold
                            a[i] = 0; b[i] = 1; c[i] = 0; d[i] = T_cold
                        }
                        
                        // ВНУТРЕННИЕ ТОЧКИ
                    } else {
                        let dx_west = dx[i-1] * rxJ
                        let dx_east = dx[i] * rxJ
                        let dx_center = 0.5 * (dx_west + dx_east)
                        let currentDiff = isMomentum ? nu(T) : alpha(T)
                        let diff_dt_current = currentDiff * dt
                        let alpha_west = diff_dt_current / (dx_west * dx_center)
                        let alpha_east = diff_dt_current / (dx_east * dx_center)
                        
                        a[i] = -alpha_west; c[i] = -alpha_east
                        b[i] = 1.0 + alpha_west + alpha_east
                        d[i] = quantity
                    }
                }
                thomasSolveInPlace(a, b, c, d, count: nx, solution: &sol, cPrime: &cP, dPrime: &dP)

                for i in 0..<nx { property[row+i] = sol[i] }///фиксация
            }
        }
        
        // 2. Y-направление
        DispatchQueue.concurrentPerform(iterations: workerCount) { wID in
            let startX = 1 + (wID * (nx - 2) / workerCount)
            let endX = 1 + ((wID + 1) * (nx - 2) / workerCount)
            
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
                    let quantity = property[idx]
                    
                    // ГРАНИЧНЫЕ УСЛОВИЯ, горизонтальные стенки
                    if j == 0 { /// нижняя  (u, v = 0; dT/dy = 0)
                        a[j] = 0.0; b[j] = 1.0; c[j] = isMomentum ? 0.0 : -1.0; d[j] = 0.0
                        
                    } else if j == ny-1 { ///верхняя  (u, v = 0; dT/dy = 0)
                        a[j] = isMomentum ? 0.0 : -1.0; b[j] = 1.0; c[j] = 0.0; d[j] = 0.0
                        
                        // ВНУТРЕННИЕ ТОЧКИ
                    } else {
                        let dy_south = dy[j-1]
                        let dy_north = dy[j]
                        let dy_center = 0.5 * (dy_south + dy_north)
                        let currentDiff = isMomentum ? nu(T) : alpha(T)
                        let diff_dt_current = currentDiff * dt
                        let alpha_south = diff_dt_current / (dy_south * dy_center)
                        let alpha_north = diff_dt_current / (dy_north * dy_center)
                        
                        a[j] = -alpha_south; c[j] = -alpha_north
                        b[j] = 1.0 + alpha_south + alpha_north
                        d[j] = quantity
                    }
                }
                
                thomasSolveInPlace(a, b, c, d, count: ny, solution: &sol, cPrime: &cP, dPrime: &dP)

                for j in 0..<ny { property[j*nx+i] = sol[j] }///фиксация
            }
        }/*}}}}*/
    }
}
*/
