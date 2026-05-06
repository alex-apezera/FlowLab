//
//  redBlackJacobi.swift
//  FlowLab
//
//  Created by Алексей Езерский on 21.06.2026.
//
//MARK: - Red-Black scheme for Pressure

extension NavierStokesSolver {
    
    /// Jacobi scheme (iterations)
    func redBlackJacobi(_ startY: Int, _ endY: Int, _ nx: Int, _ ny: Int, _ dx: ReadOnly, _ dy: ReadOnly, _ pNew: Mutable, _ divergence: ReadOnly, _ relax: Double, _ rho_dt: Double) -> Double {
        
        /// Накапливаемая погрешность
        var maxDiff: Double = 0.0

        // Red-Black Jacobi+
        for color in 0...1 {
            /// Buffer for Pressure.
            let pPrev = pNew

            for j in startY..<endY { /// ряды
                let row = j*nx, rxJ = rx[j]
                
                // Вычисляем "дивергенцию расширения" для данного ряда
                let expansionSource = V_melt[j] / (Lx * rxJ)
                
                // Определяем начальный i (шахматный порядок)
                let startI = 1 + ((color + 2 - (1 + j % 2)) % 2)
                
                for i in stride(from: startI, to: nx-1, by: 2) {
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
                pNew[i] = pNew[nx+i]                    // Низ
                pNew[lastRowOff+i] = pNew[prevRowOff+i] // Верх
            }
        }/// Color
        return maxDiff
        
    }
    
    ///Gauss-Seidel (Iterations)
    func redBlackGaussSeidel(_ startY: Int, _ endY: Int, _ pNew: Mutable, _ mask: PtrUInt8, _ divergence: ReadOnly, _ nx: Int, _ ny: Int, _ relax: Double, _ h2_rho_dt: Double) -> Double {
        
        /// Накапливаемая погрешность
        var maxDiff: Double = 0.0
        
        // Red-Black Gauss-Seidel
        for color in 0...1 {
            
            for j in startY..<endY {
                let row = j * nx
                
                /// Определяем начальное i  от j и текущего цвета
                /// (i + j) % 2 == color  =>  i = color - j (по модулю 2)
                let startI = 1 + ((color + 2 - (1 + j%2)) % 2)
                
                /// Использование stride убирает  "if % 2" внутри цикла
                for i in stride(from: startI, to: nx-1, by: 2) {
                    let idx = row + i
                    
                    /// если маска указывает на твердое тело - пропускаем
                    if mask[idx] == 1 { pNew[idx] = 0; continue }
                    /// Соседи: если твердое тело - берем p old (dp/dn = 0)
                    let p_old = pNew[idx]
                    let west = idx - 1, east = idx + 1
                    let south = idx - nx, north = idx + nx
                    let pW = (mask[west] == 1) ? p_old : pNew[west]
                    let pE = (mask[east] == 1) ? p_old : pNew[east]
                    let pN = (mask[north] == 1) ? p_old : pNew[north]
                    let pS = (mask[south] == 1) ? p_old : pNew[south]
                    
                    /// Вычисляем источник скорости
                    let div_V = divergence[idx]
                    
                    /// Стабилизация Rhie-Chow.
                    let p_neighbors = pE + pW + pN + pS
                    let p_stab = 0.02 * (p_neighbors - 4*p_old)
                    
                    /// Вычисление давления с релаксацией
                    let newValue = 0.25 * (p_neighbors - h2_rho_dt * div_V) + p_stab
                    let p_rel = newValue*relax + p_old*(1 - relax)
                    
                    /// Заполнение буфера
                    pNew[idx] = p_rel
                    
                    /// Вычисление погрешности
                    let diff = abs(p_rel - p_old)
                    if diff > maxDiff { maxDiff = diff }
                    
                }
                /// Граничные условия (Лево/Право) - Инлайново
                pNew[row] = pNew[row+1]
                pNew[row+nx-1] = pNew[row+nx-2]
            }
            
            /// Граничные условия (Верх/Низ)
            let lastRowOff = (ny - 1) * nx
            let prevRowOff = (ny - 2) * nx
            for i in 0..<nx {
                pNew[i] = pNew[nx + i]
                pNew[lastRowOff + i] = pNew[prevRowOff + i]
            }
        }/// Color
        return maxDiff
    }
}
