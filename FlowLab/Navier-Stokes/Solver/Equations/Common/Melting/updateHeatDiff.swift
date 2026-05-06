//
//  updateHeatDiff.swift
//  FlowLab
//
//  Created by Алексей Езерский on 14.06.2026.
//
//MARK: - Melting efficiency

extension NavierStokesSolver {
    /// КПД плавления <qCold>/<qHot> [%]
    func updateHeatDiff(_ heatW: Double, _ heatE: Double) -> Double {
        return abs(heatE / heatW)*100
    }
}
