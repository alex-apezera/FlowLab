//
//  walls.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 25.02.2026.
//
//MARK: - First derivative at the boundary, 2nd order interpolation

/// Первая производная на границе для неравноменой сетки
@inline(__always)
func wallDerivative(_ T0: Double, _ T1: Double, _ T2: Double, _ dx0: Double, _ dx1: Double) -> Double {
    
    let dxW = dx0, dxW1 = dx1 + dxW
    let dxW_2 = dxW * dxW, dxW1_2 = dxW1 * dxW1
    let denom = dxW_2 * dxW1 - dxW1_2 * dxW
    
    return (T2 * dxW_2 - T1 * dxW1_2 + T0 * (dxW1_2 - dxW_2)) / denom
}

/// Первая производная на границе для равномерной сетки
@inline(__always)
func frontDerivative(_ value0: Double, _ value1: Double, _ value2: Double, _ dx_inv2: Double) -> Double {
    // dx_inv2 = 0.5 / dx
    return (4 * value1 - 3 * value0 - value2) * dx_inv2
}
