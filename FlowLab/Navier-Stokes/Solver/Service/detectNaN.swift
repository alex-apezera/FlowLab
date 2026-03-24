//
//  detectNaN.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 28.11.2025.
//
@inline(__always)
func detectNaN(_ value: Double) -> Bool {
    guard !(value.isNaN || value.isInfinite) else {
        print("NaN detected: \(value)")
        return true
    }
    return false
}

