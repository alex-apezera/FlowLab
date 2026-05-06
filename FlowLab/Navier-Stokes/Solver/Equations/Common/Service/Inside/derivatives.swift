//
//  derivatives.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 05.11.2025.
//
//MARK: - Производные (центральные разности) на неравномерной сетке

extension NavierStokesSolver {
    
    /// Производная по x
    @inline(__always)
    func derivativeX(_ array: [Double], _ j: Int, _ i: Int, _ idx: Int) -> Double {
        
        return (array[idx+1] - array[idx-1]) / ((x[i+1] - x[i-1]) * rx[j])
    }
    
    /// Производная по y
    @inline(__always)
    func derivativeY(_ array: [Double], _ j: Int, _ i: Int, _ idx: Int) -> Double {
        
        return (array[idx+nx] - array[idx-nx]) / (y[j+1] - y[j-1])
    }
}
