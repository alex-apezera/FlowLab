//
//  updateSF.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 24.03.2025.
//
//MARK: - Calculate Stream Function by Poisson ∇²ψ = ∂v/∂x - ∂u/∂y (= ω)

import Foundation
extension NavierStokesSolver {
    
    /// Расчет функции тока  в фоновом потоке
    func updateStreamFunctionAsync(u: [Double], v: [Double], rx: [Double]) {
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
            try await Task.sleep(nanoseconds: 500_000_000)
        }
    }
    /// Решение уравнения Пуассона ∇²ψ = ∂v/∂x - ∂u/∂y
    func solvePoissonStreamFunction(u: [Double], v: [Double], rx: [Double], tolerance: Double)  -> [Double] {
        // КЭШ
        let nx = self.nx, ny = self.ny
        var psi = [Double](repeating: 0.0, count: nx * ny)
        var rhs = [Double](repeating: 0.0, count: nx * ny)
        // Ptrs
        u.withUnsafeBufferPointer { u in
        v.withUnsafeBufferPointer { v in
        x.withUnsafeBufferPointer { x in
        y.withUnsafeBufferPointer { y in
        rx.withUnsafeBufferPointer { rx in
        psi.withUnsafeMutableBufferPointer { psi in
        rhs.withUnsafeMutableBufferPointer { rhs in
        
        // 1. Правая часть (Calculate Stream Function by Integral method) - без изменений
        for j in 1..<ny-1 {
            let row = nx * j
            let dyInv = 1.0 / (y[j+1] - y[j-1])
            let rx_j = rx[j]
            
            for i in 1..<nx-1 {
                let idx = row + i
                let dxInv = 1.0 / ((x[i+1] - x[i-1]) * rx_j)
                rhs[idx] = ((u[idx+nx] - u[idx-nx]) * dyInv) - ((v[idx+1] - v[idx-1]) * dxInv)
            }
        }
        
        // 2. Итерации с проверкой сходимости
        let maxIterations = 2000 // Страховка от бесконечного цикла
        for iteration in 1...maxIterations {
            var maxDiff = 0.0
            
            for j in 1..<ny-1 {
                let row = nx * j
                let dy = y[j+1] - y[j-1]
                let dy2 = dy*dy
                let rx_j = rx[j]
                
                for i in 1..<nx-1 {
                    let idx = row + i
                    let dx = (x[i+1] - x[i]) * rx_j
                    let dx2 = dx*dx
                    let alpha = 1.0 / dx2
                    let beta = 1.0 / dy2
                    
                    let oldVal = psi[idx]
                    let newVal = (alpha * (psi[idx+1] + psi[idx-1]) + beta * (psi[idx+nx] + psi[idx-nx]) - rhs[idx]) / (2 * (alpha + beta))
                    
                    psi[idx] = newVal
                    maxDiff = max(maxDiff, abs(newVal - oldVal))
                }
            }
            iterationsPsi = iteration
            // Если максимальное изменение меньше порога — выходим
            if maxDiff < tolerance { break }
        }
        
        }}}}}}}///ptr
        
        return psi
    }
}
