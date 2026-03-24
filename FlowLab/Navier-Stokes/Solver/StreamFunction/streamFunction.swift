//
//  streamFunction.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 22.03.2026.
//
extension NavierStokesSolver {
 
    /// Вычисление функции тока из уравнений u = ∂ψ/∂y, v = - ∂ψ/∂x
    func streamFunction(u: [[Double]], v: [[Double]], rx: [Double], fl: [Double]) -> [[Double]] {
        var psi = Array(repeating: Array(repeating: 0.0, count: nx), count: ny)
        let totalH = y[ny-1] - y[0]
        // Интегрируем по горизонтали вдоль нижней стенки (j=0)
        // d psi = -v * dx * rx (учитываем расширение rx)
        var currentPsiX = 0.0
        for i in 1..<nx {
            let dx = x[i] - x[i-1]
            let vAvg = 0.5 * (v[0][i] + v[0][i-1])
            currentPsiX -= vAvg * dx * rx[0]
            psi[0][i] = currentPsiX
        }
        // Интегрируем по вертикали от нижней границы вверх
        // d psi = u * dy * rx (учитываем rx на каждом уровне)
        for i in 0..<nx {
            var currentPsiY = psi[0][i]
            for j in 1..<ny {
                let dy = y[j] - y[j-1]
                // Берем скорость u на грани (MAC-сетка)
                let uAvg = 0.5 * (u[j][i] + u[j-1][i])
                let rAvg = 0.5 * (rx[j] + rx[j-1])
                currentPsiY += uAvg * dy * rAvg
                psi[j][i] = currentPsiY
            }
            // КОРРЕКЦИЯ ОШИБКИ (с учетом физической высоты y)
            let error = psi[ny-1][i] /// Значение на верхней крышке (должно быть const)
            for j in 0..<ny {
                let heightFactor = (y[j] - y[0]) / totalH
                psi[j][i] -= error * heightFactor
            }
        }
        // АДАПТИВНОЕ СГЛАЖИВАНИЕ (убирает "изломы" в зоне ГРФ)
        var smoothedPsi = psi
        for j in 1..<(ny-1) {
            let offset = yCell(j)
            for i in 1..<(nx-1) {
                // Если мы в зоне фазового перехода (0 < fl < 1) или жидкости, сглаживаем сильнее
                let phase = fl[offset + i]
                if phase > dTm && phase < 1-dTm {
                    let neighbors = (psi[j][i+1] + psi[j][i-1] + psi[j+1][i] + psi[j-1][i])
                    /// Смешиваем исходное значение и среднее по соседям (коэффициент 0.5)
                    smoothedPsi[j][i] = 0.5 * psi[j][i] + 0.125 * neighbors
                }
            }
        }
        return smoothedPsi
    }
}
