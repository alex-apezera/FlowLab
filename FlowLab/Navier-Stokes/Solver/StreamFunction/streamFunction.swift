//
//  streamFunction.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 22.03.2026.
//
extension NavierStokesSolver {
 
    /// Вычисление функции тока из уравнений u = ∂ψ/∂y, v = - ∂ψ/∂x
    func streamFunction(u: [Double], v: [Double], rx: [Double], fl: [Double]) -> [Double] {
        let nx = self.nx, ny = self.ny
        var psi = [Double](repeating: 0.0, count: nx * ny)
        let totalH = y[ny-1] - y[0]
        // Интегрируем по горизонтали вдоль нижней стенки (j=0)
        // d psi = -v * dx * rx (учитываем расширение rx)
        var currentPsiX = 0.0
        for i in 1..<nx {
            let dx = x[i] - x[i-1]
            let vAvg = 0.5 * (v[idx(i,0)] + v[idx(i-1,0)])
            currentPsiX -= vAvg * dx * rx[0]
            psi[idx(i,0)] = currentPsiX
        }
        // Интегрируем по вертикали от нижней границы вверх
        // d psi = u * dy * rx (учитываем rx на каждом уровне)
        for i in 0..<nx {
            var currentPsiY = psi[idx(i,0)]
            for j in 1..<ny {
                let dy = y[j] - y[j-1]
                /// Берем скорость u на грани (MAC-сетка) ???
                let uAvg = 0.5 * (u[idx(i,j)] + u[idx(i,j-1)])
                let rAvg = 0.5 * (rx[j] + rx[j-1])
                currentPsiY += uAvg * dy * rAvg
                psi[idx(i,j)] = currentPsiY
            }
            // КОРРЕКЦИЯ ОШИБКИ (с учетом физической высоты y)
            let error = psi[idx(i,ny-1)] /// Значение на верхней крышке (= const)
            for j in 0..<ny {
                let heightFactor = (y[j] - y[0]) / totalH
                psi[idx(i,j)] -= error * heightFactor
            }
        }
        // АДАПТИВНОЕ СГЛАЖИВАНИЕ (убирает "изломы" в зоне ГРФ)
        var smoothedPsi = psi
        for j in 1..<(ny-1) {
            let row = nx*j
            
            for i in 1..<(nx-1) {
                let idx = row+i
                // Если мы в зоне плавления (0 < fl < 1), сглаживаем сильнее
                let phase = fl[idx]
                if phase > dTm && phase < 1-dTm {
                    let neighbors = (psi[idx+1] + psi[idx-1] + psi[idx+nx] + psi[idx-nx])
                    /// Смешиваем исходное значение и среднее по соседям (коэффициент 0.5)
                    smoothedPsi[idx] = 0.5 * psi[idx] + 0.125 * neighbors
                }
            }
        }
        return smoothedPsi
    }
}
