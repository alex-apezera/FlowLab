//
//  clamped.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 10.03.2026.
//
//MARK: - Variable range limiter

extension Comparable {
    /// Ограничитель диапазона изменения переменной
    func clamped(to range: ClosedRange<Self>) -> Self {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}
