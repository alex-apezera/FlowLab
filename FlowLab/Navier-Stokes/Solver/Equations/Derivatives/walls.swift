//
//  walls.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 25.02.2026.
//

// Первая производная на границе, формула квадратичной интерполяции 2 порядка

/// Для неравноменой сетки
@inline(__always) func wallDerivative(_ T0: Double, _ T1: Double, _ T2: Double, _ dx0: Double, _ dx1: Double) -> Double {
    
    let dxW = dx0, dxW1 = dx1 + dxW
    let dxW_2 = dxW * dxW, dxW1_2 = dxW1 * dxW1
    let denom = dxW_2 * dxW1 - dxW1_2 * dxW
    
    return (T2 * dxW_2 - T1 * dxW1_2 + T0 * (dxW1_2 - dxW_2)) / denom
}

/// Для равномерной сетки
@inline(__always) func frontDerivative(_ value0: Double, _ value1: Double, _ value2: Double, _ dx_inv2: Double) -> Double {
    
    // dx_inv2 = 0.5 / dx
    return (4 * value1 - 3 * value0 - value2) * dx_inv2
}


/// Вычисление температуры на стенке 2 порядка на основе заданного среднего теплового потока
@inline(__always) func wallTempByFlux(_ T1: Double, _ T2: Double, _ dx0: Double, _ dx1: Double, heatFlux: Double, lambda: Double) -> Double {
    let h0 = dx0
    let h1 = dx1
    let denom = h0 * h1 * (h0 + h1)
    
    let RHS = -heatFlux / lambda // q = -lambda * dT/dx
    
    let coeffT0 = -(2 * h0 + h1) * (h0 + h1) / denom
    let coeffT1 = (h0 + h1) * (h0 + h1) / denom
    let coeffT2 = -h0 * h0 / denom
    
    return (RHS - coeffT1 * T1 - coeffT2 * T2) / coeffT0

}
