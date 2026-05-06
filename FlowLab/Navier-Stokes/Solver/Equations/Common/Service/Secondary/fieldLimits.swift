//
//  fieldLimits.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 06.11.2025.
//

//MARK: - Calculating the minimum and maximum value from an array

/// Вычисление минимального и максимального значения из 1D массива
func fieldLimits(_ field: [Double]) -> (min: Double, max: Double) {
    return field.min(by: <) != nil ? (field.min()!, field.max()!) : (0.0, 0.0)
}
