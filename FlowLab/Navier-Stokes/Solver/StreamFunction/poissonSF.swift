//
//  updateSF.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 24.03.2025.
//
import Foundation
extension NavierStokesSolver {
    
    func updateStreamFunctionAsync(u: [[Double]], v: [[Double]], rx: [Double]) {
        // Запускаем расчет в фоновом потоке
        DispatchQueue.main.async {
            self.isCalculatingStream = true
        }
        Task.detached(priority: .userInitiated) {
            // Выполняем тяжелый расчет Пуассона
            let newPsi = await self.solvePoissonStreamFunction(u: u, v: v, rx: rx, tolerance: self.tolerancePsi)
            
            // Возвращаемся в MainActor, чтобы обновить UI через @Published
            await MainActor.run {
                self.psi = newPsi
                self.isCalculatingStream = false // Убираем индикатор
            }
            try await Task.sleep(nanoseconds: 100_000_000)
        }
    }
    
    func solvePoissonStreamFunction(u: [[Double]], v: [[Double]], rx: [Double], tolerance: Double)  -> [[Double]] {
        // КЭШ
        let nx = x.count
        let ny = y.count
        var psi = Array(repeating: Array(repeating: 0.0, count: nx), count: ny)
        var rhs = Array(repeating: Array(repeating: 0.0, count: nx), count: ny)
        
        // 1. Правая часть (Vorticity) - без изменений
        for j in 1..<ny-1 {
            let dyInv = 1.0 / (y[j+1] - y[j-1])
            let rx_j = rx[j]
            for i in 1..<nx-1 {
                let dxInv = 1.0 / ((x[i+1] - x[i-1]) * rx_j)
                rhs[j][i] = ((u[j+1][i] - u[j-1][i]) * dyInv) - ((v[j][i+1] - v[j][i-1]) * dxInv)
            }
        }
        
        // 2. Итерации с проверкой сходимости
        let maxIterations = 2000 // Страховка от бесконечного цикла
        for iteration in 0...maxIterations {
            var maxDiff = 0.0
            
            for j in 1..<ny-1 {
                let dy = y[j+1] - y[j-1]
                let dy2 = dy*dy
                let rx_j = rx[j]
                for i in 1..<nx-1 {
                    let dx = (x[i+1] - x[i]) * rx_j
                    let dx2 = dx*dx
                    let alpha = 1.0 / dx2
                    let beta = 1.0 / dy2
                    
                    let oldVal = psi[j][i]
                    let newVal = (alpha * (psi[j][i+1] + psi[j][i-1]) +
                                  beta * (psi[j+1][i] + psi[j-1][i]) - rhs[j][i]) / (2 * (alpha + beta))
                    
                    psi[j][i] = newVal
                    maxDiff = max(maxDiff, abs(newVal - oldVal))
                }
            }
            iterationsPsi = iteration
            // Если максимальное изменение меньше порога — выходим
            if maxDiff < tolerance { break }
        }
        
        return psi
    }
}
