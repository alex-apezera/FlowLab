//
//  Thomas.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 13.10.2025.
//
// MARK: - Thomas Algorithm (TDMA - Трехдиагональная прогонка)

/// Алгоритм Томаса
func thomasSolve(_ a: [Double], _ b: [Double], _ c: [Double], _ d: [Double], count n: Int) -> [Double] {
    var cPrime = [Double](repeating: 0, count: n)
    var dPrime = [Double](repeating: 0, count: n)
    var x = [Double](repeating: 0, count: n)
    
    // Прямой ход
    cPrime[0] = c[0] / b[0]
    dPrime[0] = d[0] / b[0]
    
    for i in 1..<n {
        let denominator = b[i] - a[i] * cPrime[i-1]
        cPrime[i] = c[i] / denominator
        dPrime[i] = (d[i] - a[i] * dPrime[i-1]) / denominator
    }
    
    // Обратный ход
    x[n-1] = dPrime[n-1]
    for i in (0..<n-1).reversed() {
        x[i] = dPrime[i] - cPrime[i] * x[i+1]
    }
    
    return x
}

/// Оптимизированный Алгоритм Томаса
@inline(__always)
func thomasSolveInPlace(_ a: [Double], _ b: [Double], _ c: [Double], _ d: [Double], count n: Int, solution: inout [Double], cPrime: inout [Double], dPrime: inout [Double]) {
    
    // Прямой ход
    let b0 = b[0]
    cPrime[0] = c[0] / b0
    dPrime[0] = d[0] / b0
    
    for i in 1..<n {
        let m = 1.0 / (b[i] - a[i] * cPrime[i-1])
        cPrime[i] = c[i] * m
        dPrime[i] = (d[i] - a[i] * dPrime[i-1]) * m
    }
    
    // Обратный ход
    solution[n-1] = dPrime[n-1]
    for i in stride(from: n-2, through: 0, by: -1) {
        solution[i] = dPrime[i] - cPrime[i] * solution[i+1]
    }
}

/// Оптимизированный Алгоритм Томаса с указателями
@inline(__always)
func thomasSolvePtr( _ a: Mutable, _ b: Mutable, _ c: Mutable, _ d: Mutable, count n: Int, solution: inout Mutable, cPrime: inout Mutable, dPrime: inout Mutable) {
    
    // Прямой ход
    let b0 = b[0]
    cPrime[0] = c[0] / b0
    dPrime[0] = d[0] / b0
    
    for i in 1..<n {
        let m = 1.0 / (b[i] - a[i] * cPrime[i-1])
        cPrime[i] = c[i] * m
        dPrime[i] = (d[i] - a[i] * dPrime[i-1]) * m
    }
    
    // Обратный ход
    solution[n-1] = dPrime[n-1]
    for i in stride(from: n-2, through: 0, by: -1) {
        solution[i] = dPrime[i] - cPrime[i] * solution[i+1]
    }
}
