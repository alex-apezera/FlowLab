//
//  SimulationState.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 13.11.2025.
//

//MARK: - Состояние симуляции (решения) для Истории

struct SimulationState: Codable, Sendable {
    var t: Double = 0.0
    var dt: Double = 0.001, dTime: Double = 0.0
    var step: Int = 0
    var rx: [Double] = []
    var rx_avg: Double = 1.0, rx_avg_old: Double = 1.0
    var V_melt_avg: Double = 0.0
    var gravityAngle: Double = 0.0
    var temperature: [[Double]] = []
    var velocityX: [[Double]] = []
    var velocityY: [[Double]] = []
//    var pressure: [[Double]] = []
    var pressure: [Double] = []
    var liquidFraction: [Double] = []
    var isStone: [UInt8] = []
    var heatFluxE: [Double] = []
    var heatFluxW: [Double] = []
    var temperatureHotWall: [Double] = []
    var temperatureVolume: [Double] = []
}

struct SimulationStateLiquidFraction: Codable, Sendable {
    let liquidFraction: [Double]
    let T: [[Double]]
}
