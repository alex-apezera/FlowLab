//
//  epmPressure.swift
//  FlowLab
//
//  Created by Алексей Езерский on 14.01.2026.
//
//MARK: - Solve continuity equation ∇u = 0 (EPM)

import Foundation
extension NavierStokesSolver {
    
    /// Уравнение неразрывности ∇u = 0. Метод Гаусса-Зейделя. Квадратная сетка
    func epmPressure(_ uNew: [Double], _ vNew: [Double]) {
        guard !isFrozen else {return}

        // Расчет массива дивергенции
        let divergence = calculateDivergence(uStar: uNew, vStar: vNew)

        getSolidMask() /// Получение условий твердости
        
        /// Используем указатели, чтобы избежать проверки границ
        p.withUnsafeMutableBufferPointer { pNew in
        solidMask.withUnsafeBufferPointer { mask in
        divergence.withUnsafeBufferPointer { div in
        
        var iteration = 0
        repeat {
            
            if useParallelPressure { /// Многопоточные вычисления
                /// Создаем массив для хранения невязок от каждого потока
                var residuals = [Double](repeating: 0, count: workerCount)
                
                DispatchQueue.concurrentPerform(iterations: workerCount) { wID in
                    let startY = 1 + (wID * (ny - 2) / workerCount)
                    let endY = 1 + ((wID + 1) * (ny - 2) / workerCount)
                    
                    residuals[wID] = redBlackGaussSeidel(startY, endY, pNew, mask, div, nx, ny,params.relaxationFactor, h*h*rho/dt)
                }
                    
                maxPressureResidual = residuals.max() ?? 0.0

            } else {
                maxPressureResidual = redBlackGaussSeidel(1, ny-1, pNew, mask, div, nx, ny, params.relaxationFactor, h*h*rho/dt)
            }
            
            iteration += 1
            
        } while maxPressureResidual > params.criticalError && iteration < params.maxIterations
        
        iterations = iteration

        }}}///указатели
 
        //коррекция скоростей ∂𝐕/∂t = -(1/ρ)∇p
        epmCorrectVel(uNew, vNew)

        applyVelocityBoundaryConditions(&u, &v)
    }

}
