//
//  derivatives.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 05.11.2025.
//
//MARK: - Производные второго порядка на неравномерной сетке

extension NavierStokesSolver {
    
    /// Производная по x
    @inline(__always)
    func derivativeX(_ array: [Double], _ j: Int, _ i: Int, _ idx: Int) -> Double {
        
        return (array[idx+1] - array[idx-1]) / ((x[i+1] - x[i-1]) * rx[j])
    }

    /// Производная по y
    @inline(__always)
    func derivativeY(_ array: [Double], _ j: Int, _ i: Int, _ idx: Int) -> Double {
        let nx = self.nx
        return (array[idx+nx] - array[idx-nx]) / (y[j+1] - y[j-1])
    }
/*
    /// Вторая производная по x
    @inline(__always)
    func secondDerivativeX(_ array: [[Double]], _ j: Int, _ i: Int) -> Double {
        guard i > 0 && i < nx-1 else { return 0 }
        let dx_left = (x[i] - x[i-1]) * rx[j]
        let dx_right = (x[i+1] - x[i]) * rx[j]
        
        return 2 * (array[j][i+1] - array[j][i]) / (dx_right * (dx_left + dx_right)) -
        2 * (array[j][i] - array[j][i-1]) / (dx_left * (dx_left + dx_right))
    }
    
    /// Вторая производная по y
    @inline(__always)
    func secondDerivativeY(_ array: [[Double]], _ j: Int, _ i: Int) -> Double {
        guard j > 0 && j < ny-1 else { return 0 }
        let dy_bottom = y[j] - y[j-1]
        let dy_top = y[j+1] - y[j]
        
        return 2 * (array[j+1][i] - array[j][i]) / (dy_top * (dy_bottom + dy_top)) -
        2 * (array[j][i] - array[j-1][i]) / (dy_bottom * (dy_bottom + dy_top))
    }
    */
}
