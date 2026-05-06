//
//  HistoryFrame.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 08.12.2025.
//
//MARK: - Helper methods for storing the solution in the current session

import SwiftUI

/// Кадр  истории только для текущего сеанса (в файл не сохраняется)
struct HistoryFrame: Identifiable {
    let id = UUID()
    let t: Double
    let dt: Double, dTime: Double
    let step: Int
    let rx: [Double]
    let rx_avg: Double, rx_avg_old: Double
    let V_melt_avg: Double
    let gravityAngle: Double
    let temperature: [Double]
    let velocityX: [Double]
    let velocityY: [Double]
    let pressure: [Double]
    let liquidFraction: [Double]
    let isStone: [UInt8]
    let heatFluxE: [Double]
    let heatFluxW: [Double]
    let timePoints: [Double]
    let temperatureHotWall: [Double]
    let temperatureVolume: [Double]
    let totalTimeElapsed: TimeInterval
    let startTime: Date?
    
}
