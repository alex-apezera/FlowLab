//
//  Pressure.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 18.07.2025.
//
//MARK: - Solve continuity (pressure) equation (ALE)

extension NavierStokesSolver {
    
    /// Уравнение неразрывности ∇u = 0. Схема Якоби. Неравномерная сетка.
    func alePressure() {
        guard !isFrozen else {return}

        let nx = self.nx, ny = self.ny
        let relax = params.relaxationFactor
        var pNew = p
        let rho_dt = rho / dt
        
        // Расчет массива дивергенции
        let divergence = calculateDivergence(uStar: u, vStar: v)
        
        var iteration = 0
        repeat {
            // Jacobi scheme
            let pPrev = pNew
            
            var maxDiff: Double = 0.0
            for j in 1..<(ny-1) { /// ряды
                let row = j*nx, rxJ = rx[j]
                
                // Вычисляем "дивергенцию расширения" для данного ряда
                let expansionSource = V_melt[j] / (Lx * rxJ)
                
                for i in 1..<nx-1 { /// столбцы
                    let idx = row+i, idxS = idx-nx, idxN = idx+nx
                    
                    /// КЭШ коэффициенты для трапецевидной ячейки
                    let dx_local = dx[i] * rxJ
                    let dy_local = dy[j]
                    let denom = 2/(dx_local * dx_local) + 2/(dy_local * dy_local)
                    let coeffX = 1 / (dx_local * dx_local * denom)
                    let coeffY = 1 / (dy_local * dy_local * denom)
                    
                    /// КЭШ давление в ячейке и вокруг неё
                    let p_old = pPrev[idx]
                    let pE = pPrev[idx+1], pW = pPrev[idx-1]
                    let pN = pPrev[idxN], pS = pPrev[idxS]
                    
                    /// Вычисляем источник скорости
                    let div_V = divergence[idx]
                    let source = rho_dt * (div_V + expansionSource)
                    
                    /// Стабилизация Rhie-Chow.
                    let p_neighbors = pE + pW + pN + pS
                    let p_stab = 0.02 * (p_neighbors - 4*p_old)
                    
                    /// Вычисление давления с релаксацией
                    let newValue = coeffX * (pE + pW) + coeffY * (pN + pS) - (source / denom) + p_stab
                    let p_rel = newValue*relax + p_old*(1 - relax)
                    
                    pNew[idx] = p_rel/// фиксация
                    
                    /// Вычисление погрешности
                    let diff = abs(p_rel - p_old)
                    if diff > maxDiff { maxDiff = diff }
                }
                /// Граничные условия (Лево/Право) - Инлайново
                pNew[row] = pNew[row+1]
                pNew[row+nx-1] = pNew[row+nx-2]
            }
            /// Граничные условия (Верх/Низ)
            let lastRowOff = (ny-1) * nx
            let prevRowOff = (ny-2) * nx
            for i in 0..<nx {
                pNew[i] = pNew[nx+i]                      // Низ
                pNew[lastRowOff+i] = pNew[prevRowOff+i] // Верх
            }
            /// Погрешность
            maxPressureResidual = maxDiff
            iteration += 1
        } while maxPressureResidual > params.criticalError && iteration < params.maxIterations
        
        p = pNew
        
        aleCorrectVel(p, dt/rho)
        
        iterations = iteration
    }
    
}
