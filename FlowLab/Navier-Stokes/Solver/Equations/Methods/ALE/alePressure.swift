//
//  Pressure.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 18.07.2025.
//
//MARK: - Solve continuity equation ∇u = 0. (ALE)

import Foundation
extension NavierStokesSolver {
    
    /// Уравнение неразрывности ∇u = 0. Схема Якоби. Неравномерная сетка.
    func alePressure() {
        guard !isFrozen else {return}
        
        /// Расчет массива дивергенции
        let divergence = calculateDivergence(uStar: u, vStar: v)
        
        // Прямой доступ к массивам
        self.p.withUnsafeMutableBufferPointer { pNew in
        divergence.withUnsafeBufferPointer { div in
        self.dx.withUnsafeBufferPointer { dx in
        self.dy.withUnsafeBufferPointer { dy in
        
        var iteration = 0
        repeat {
            
            if useParallelPressure { /// Многопоточные вычисления
                
                /// 1. Создаем массив для хранения невязок от каждого потока
                var residuals = [Double](repeating: 0, count: workerCount)

                /// 2. Вычисляем
                DispatchQueue.concurrentPerform(iterations: workerCount) { wID in
                    let startY = 1 + (wID * (ny - 2) / workerCount)
                    let endY = 1 + ((wID + 1) * (ny - 2) / workerCount)
                    
                    residuals[wID] = redBlackJacobi(startY, endY, nx, ny, dx, dy, pNew, div, params.relaxationFactor, rho/dt)
                }
                /// 3. Находим максимум невязок после завершения всех потоков
                maxPressureResidual = residuals.max() ?? 0

            } else { /// Вычисления без многопоточности
 
                maxPressureResidual = redBlackJacobi(1, ny-1, nx, ny, dx, dy, pNew, div, params.relaxationFactor, rho/dt)
            }
  
            iteration += 1

        } while maxPressureResidual > params.criticalError && iteration < params.maxIterations
            
        iterations = iteration
        }}}}///ptr

        // Коррекция скоростей учитывается в aleMomentum
        // Граничные условия - избыточны (учтены aleDiffuse)
    }
}
