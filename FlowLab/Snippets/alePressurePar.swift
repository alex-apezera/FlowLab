//
//  PressurePar.swift
//  FlowLab
//
//  Created by Алексей Езерский on 10.04.2026.
//
//MARK: - Solve continuity equation ∇u = 0 (ALE)
/*
import Foundation
extension NavierStokesSolver {
        
    /// Уравнение неразрывности ∇u = 0. Схема Jacobi+. Неравномерная сетка
    func alePressurePar() {
        guard !isFrozen else {return}
        
        /// Расчет массива дивергенции
        let divergence = calculateDivPar(uStar: u, vStar: v)
        
        // Прямой доступ к массивам
        var pNew: MutPtr!
        var div: Pntr!, dx: Pntr!, dy: Pntr!
        self.p.withUnsafeMutableBufferPointer { ptr in pNew = ptr.baseAddress! }
        divergence.withUnsafeBufferPointer { ptr in div = ptr.baseAddress! }
        self.dx.withUnsafeBufferPointer { ptr in dx = ptr.baseAddress! }
        self.dy.withUnsafeBufferPointer { ptr in dy = ptr.baseAddress! }

//        p.withUnsafeMutableBufferPointer { pNew in
//        divergence.withUnsafeBufferPointer { divergence in
//        dx.withUnsafeBufferPointer { dx in
//        dy.withUnsafeBufferPointer { dy in
//                                
        var iteration = 0
        let workerCount = self.workerCount
        repeat {
            
            /// Организация многопоточности
            /// 1. Создаем массив для хранения невязок от каждого потока
            var residuals = [Double](repeating: 0, count: workerCount)

            /// 2. Вычисляем
            DispatchQueue.concurrentPerform(iterations: workerCount) { wID in
                let startY = 1 + (wID * (ny - 2) / workerCount)
                let endY = 1 + ((wID + 1) * (ny - 2) / workerCount)
                
                residuals[wID] = redBlackJacobi(startY, endY, nx, ny, dx, dy, pNew, div, params.relaxationFactor, rho/dt)
            }

            /// 3. Находим максимум после завершения всех потоков
            maxPressureResidual = residuals.max() ?? 0
 
            iteration += 1

        } while maxPressureResidual > params.criticalError && iteration < params.maxIterations
        
        iterations = iteration

//        }}}}///указатели

        /// Коррекция скоростей учитывается в уравнении движения
//        aleCorrectVelPar(u, v)
        /// Граничные условия - избыточны (учтены при вычислении диффузии))
//        applyVelocityBoundaryConditions(&u, &v)
    }
}
*/
