//
//  HistoryStep.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 08.12.2025.
//

import SwiftUI

struct HistoryStep: Codable, Identifiable, Sendable {
    var id = UUID()
    var t: Double
    var state: SimulationState
    var parameters: SimulationParameters
    var comment: String?
    var totalTimeElapsed: TimeInterval
    var startTime: Date?
}
