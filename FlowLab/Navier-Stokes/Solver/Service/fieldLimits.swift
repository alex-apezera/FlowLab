//
//  fieldLimits.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 06.11.2025.
//

//MARK: - Вычисление минимального и максимального значения из массива

/// Работа через указатели + vDSP
import Accelerate
func fieldValueLimits(_ field: [[Double]]) -> (min: Double, max: Double) {
    var globalMin = Double.infinity
    var globalMax = -Double.infinity
    
    for j in 0..<field.count {
        // Пиннинг строки защищает от COW-краша
        field[j].withUnsafeBufferPointer { rowPtr in
            guard let base = rowPtr.baseAddress else { return }
            let n = vDSP_Length(rowPtr.count)
            
            var rowMin = 0.0
            var rowMax = 0.0
            
            // vDSP делает поиск мгновенно
            vDSP_minvD(base, 1, &rowMin, n)
            vDSP_maxvD(base, 1, &rowMax, n)
            
            if rowMin < globalMin { globalMin = rowMin }
            if rowMax > globalMax { globalMax = rowMax }
        }
    }
    return (globalMin == Double.infinity ? 0.0 : globalMin,
            globalMax == -Double.infinity ? 0.0 : globalMax)
}

func fieldLimits(_ field: [Double]) -> (min: Double, max: Double) {
    return field.min(by: <) != nil ? (field.min()!, field.max()!) : (0.0, 0.0)
}
