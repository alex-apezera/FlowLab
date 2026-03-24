//
//  Pressure.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 18.07.2025.
//
//MARK: - Solve continuity (pressure) equation

extension NavierStokesSolver {
    
    /// Уравнение неразрывности ∇u = 0 и давления
    /// Метод ALE, работает на неравномерной сетке
    func solvePressureEquation() async throws {
        var iteration = 0
        let relax = params.relaxationFactor
        var pNew = p
        let rho_dt = rho / dt

        repeat {
            var maxDiff: Double = 0.0
            let pPrev = pNew

            for j in 1..<(ny-1) { /// ряды
                let (jCell, jTop, jBot) = yOffsets(j) /// КЭШ для индексов

                // Вычисляем "дивергенцию расширения" для данного ряда
                let expansionSource = V_melt[j] / (Lx * rx[j])

                for i in 1..<(nx-1) { /// столбцы
                    let idx = jCell + i, idxT = jTop + i, idxB = jBot + i

                    /// КЭШ коэффициенты для трапецевидной ячейки
                    let dx_local = dx[i] * rx[j]
                    let dy_local = dy[j]
                    let denom = 2/(dx_local * dx_local) + 2/(dy_local * dy_local)
                    let coeffX = 1 / (dx_local * dx_local * denom)
                    let coeffY = 1 / (dy_local * dy_local * denom)

                    // --- СТАБИЛИЗАЦИЯ RHIE-CHOW ---
                    /// Вычисляем дивергенцию скорости
                    let div_V = derivativeX(u, j, i) + derivativeY(v, j, i)
                    
                    /// КЭШ давление вокруг ячейки 
                    let pC = pPrev[idx], pC2 = pC * 2.0
                    let pE = pPrev[idx+1], pW = pPrev[idx-1]
                    let pN = pPrev[idxT], pS = pPrev[idxB]
                    
                    /// Добавляем фильтр осцилляций
                    /// Этот член "связывает" соседей и убирает шахматный эффект
                    let p_stabilization = 0.02 * (pE - pC2 + pW + pN - pC2 + pS)

                    // Уравнение Пуассона: pj][i] = (f(соседи)-Источник)
                    /// Источник здесь: (rho/dt)・(du/dx + dv/dy + Vf/L)
                    let source = rho_dt * (div_V + expansionSource)
                    
                    let newValue = coeffX * (pE + pW) + coeffY * (pN + pS) - (source / denom) + p_stabilization
                    
                    let diff = abs(newValue - pC)
                    if diff > maxDiff { maxDiff = diff }
                    
                    pNew[idx] = newValue * relax + pC * (1.0 - relax)
                }
            }
            
            //  Граничные условия (Нейман)
            applyPressureBoundaryConditions(&pNew)
            
            maxPressureResidual = maxDiff
            iteration += 1
        } while maxPressureResidual > params.criticalError && iteration < params.maxIterations
        
        p = pNew
        
        correctVelocities()
        
        iterations = iteration
    }
 
    // Коррекция скоростей
    fileprivate func correctVelocities() {
        let dt_rho = dt / rho
        for j in 1..<(ny-1) {
            for i in 1..<(nx-1) {
                u[j][i] -= dt_rho * derivativePX(p, j, i)
                v[j][i] -= dt_rho * derivativePY(p, j, i)
            }
        }
    }

}
