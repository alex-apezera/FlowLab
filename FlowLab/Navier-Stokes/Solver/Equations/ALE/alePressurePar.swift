//
//  PressurePar.swift
//  FlowLab
//
//  Created by Алексей Езерский on 10.04.2026.
//
//MARK: - Solve continuity equation ∇u = 0 (ALE)

import Foundation
extension NavierStokesSolver {

    /// Уравнение неразрывности ∇u = 0. Схема Гаусса-Зейделя. Неравномерная сетка
    func alePressurePar() {
        guard !isFrozen else {return}

        let nx = self.nx, ny = self.ny, workerCount = self.workerCount
        let relax = params.relaxationFactor
        let rho_dt = rho / dt

        // Расчет массива дивергенции
        let divergence = calculateDivPar(uStar: u, vStar: v)

        // Прямой доступ к буферу p (предотвращение Bad Access)
        p.withUnsafeMutableBufferPointer { pPtr in
        divergence.withUnsafeBufferPointer { divergence in
                
            var iteration = 0
            repeat {
                /// Массив погрешностей:  выделяем слоты под каждый цвет
                var threadMaxDiffs = [Double](repeating: 0.0, count: workerCount*2)
                
                // Red-Black Gauss-Seidel scheme
                for color in 0...1 {
                    DispatchQueue.concurrentPerform(iterations: workerCount) { wID in
                        let startY = 1 + (wID * (ny - 2) / workerCount)
                        let endY = 1 + ((wID + 1) * (ny - 2) / workerCount)

                        var localMax: Double = 0.0
                        for j in startY..<endY {
                            let row = j*nx
                            
                            // Вычисляем "источник расширения(ALE)" для ряда
                            let expansionSource = V_melt[j] / (Lx * rx[j])
                            
                            // Определяем начальный i (шахматный порядок)
                            let startI = 1 + ((color + 2 - (1 + j % 2)) % 2)
                            
                            for i in stride(from: startI, to: nx-1, by: 2) {
                                let idx = row+i
                                
                                /// КЭШ коэффициенты для трапецевидной ячейки
                                let dx_local = dx[i] * rx[j]
                                let dy_local = dy[j]
                                let denom = 2/(dx_local * dx_local) + 2/(dy_local * dy_local)
                                let coeffX = 1 / (dx_local * dx_local * denom)
                                let coeffY = 1 / (dy_local * dy_local * denom)
                                
                                /// КЭШ давление в ячейке и вокруг неё
                                let p_old = pPtr[idx]
                                let pE = pPtr[idx+1], pW = pPtr[idx-1]
                                let pN = pPtr[idx+nx], pS = pPtr[idx-nx]
                                
                                /// Вычисляем источник скорости
                                let div_V = divergence[idx]
                                let source = rho_dt*(div_V + expansionSource)
                                
                                /// Стабилизация Rhie-Chow.
                                let p_neighbors = pE + pW + pN + pS
                                let p_stab = 0.02 * (p_neighbors - 4*p_old)
                                
                                /// Вычисление давления с релаксацией
                                let newValue = coeffX * (pE + pW) + coeffY * (pN + pS) - (source / denom) + p_stab
                                let p_rel = newValue*relax + p_old*(1 - relax)
                                
                                pPtr[idx] = p_rel/// фиксация
                                
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
                let lastRowOff = (ny-1) * nx
                let prevRowOff = (ny-2) * nx
                for i in 0..<nx {
                    pPtr[i] = pPtr[nx+i]                      // Низ
                    pPtr[lastRowOff+i] = pPtr[prevRowOff+i] // Верх
                }
                /// Погрешность
                maxPressureResidual = threadMaxDiffs.max() ?? 0.0
                iteration += 1
                
            } while maxPressureResidual > params.criticalError && iteration < params.maxIterations
            
            iterations = iteration
        }}
        // Коррекция скоростей и граничные условия
        aleCorrectVelPar(u, v)
        applyVelocityBoundaryConditions(&u, &v)
    }
}
