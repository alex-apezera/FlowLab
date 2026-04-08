//
//  epmPressurePar.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 14.01.2026.
//
//MARK: - Solve continuity equation ∇u = 0 (EPM) use concurrence

import Foundation
extension NavierStokesSolver {
    
    /// Уравнение неразрывности ∇u = 0. Метод Гаусса-Зейделя. Квадратная сетка
    func epmPressurePar(_ uNew: [Double], _ vNew: [Double]) {
        guard !isFrozen else {return}

        let nx = self.nx, ny = self.ny, workerCount = self.workerCount
        let relax = params.relaxationFactor
        let h2_rho_dt = (h * h) * (rho / dt)
        
        // Расчет массива дивергенции
        let divergence = calculateDivPar(uStar: uNew, vStar: vNew)
        
        // Получение условий твердости
        getSolidMask()
        
        // Прямой доступ на основе указателей (предотвращение Bad Access)
        p.withUnsafeMutableBufferPointer { pPtr in
        solidMask.withUnsafeBufferPointer { mask in
        divergence.withUnsafeBufferPointer { divergence in
            
            var iteration = 0
            repeat {
                /// Массив погрешностей:  выделяем слоты под каждый цвет
                var threadMaxDiffs = [Double](repeating: 0.0, count: workerCount*2)
                
                // Red-Black Gauss-Seidel
                for color in 0...1 {
                    DispatchQueue.concurrentPerform(iterations: workerCount) { wID in
                        let startY = 1 + (wID * (ny - 2) / workerCount)
                        let endY = 1 + ((wID + 1) * (ny - 2) / workerCount)

                        var localMax = 0.0
                        for j in startY..<endY {
                            let row = j * nx
                            
                            /// Определяем начальное i  от j и текущего цвета
                            /// (i + j) % 2 == color  =>  i = color - j (по модулю 2)
                            let startI = 1 + ((color + 2 - (1 + j%2)) % 2)
                            
                            /// Использование stride убирает  "if % 2" внутри цикла
                            for i in stride(from: startI, to: nx-1, by: 2) {
                                let idx = row + i
                                
                                /// если маска указывает на твердое тело - пропускаем
                                if mask[idx] == 1 { pPtr[idx] = 0; continue }
                                /// Соседи: если твердое тело - берем p old (dp/dn = 0)
                                let p_old = pPtr[idx]
                                let west = idx - 1, east = idx + 1
                                let south = idx - nx, north = idx + nx
                                let pW = (mask[west] == 1) ? p_old : pPtr[west]
                                let pE = (mask[east] == 1) ? p_old : pPtr[east]
                                let pN = (mask[north] == 1) ? p_old : pPtr[north]
                                let pS = (mask[south] == 1) ? p_old : pPtr[south]
                                
                                /// Вычисляем источник скорости
                                let div_V = divergence[idx]
                                
                                /// Стабилизация Rhie-Chow.
                                let p_neighbors = pE + pW + pN + pS
                                let p_stab = 0.02 * (p_neighbors - 4*p_old)
                                
                                /// Вычисление давления с релаксацией
                                let newValue = 0.25 * (p_neighbors - h2_rho_dt * div_V) + p_stab
                                let p_rel = newValue*relax + p_old*(1 - relax)
                                
                                /// Заполнение буфера
                                pPtr[idx] = p_rel
                                
                                /// Вычисление погрешности
                                let diff = abs(p_rel - p_old)
                                if diff > localMax { localMax = diff }
                                
                            }
                            /// Граничные условия (Лево/Право) - Инлайново
                            pPtr[row] = pPtr[row+1]
                            pPtr[row+nx-1] = pPtr[row+nx-2]
                        }
                        threadMaxDiffs[wID + color*workerCount] = max(threadMaxDiffs[wID + color*workerCount], localMax)
                    }
                }
                /// Граничные условия (Верх/Низ)
                let lastRowOff = (ny - 1) * nx
                let prevRowOff = (ny - 2) * nx
                for i in 0..<nx {
                    pPtr[i] = pPtr[nx + i]
                    pPtr[lastRowOff + i] = pPtr[prevRowOff + i]
                }
                /// Погрешность
                maxPressureResidual = threadMaxDiffs.max() ?? 0.0
                iteration += 1
                
            } while maxPressureResidual > params.criticalError && iteration < params.maxIterations
            
            iterations = iteration
        }}}
        // Коррекция скоростей и граничные условия
        epmCorrectVelPar(uNew, vNew)
        applyVelocityBoundaryConditions(&u, &v)
    }
    
}
