//
//  HistoryStep.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 08.12.2025.
//

import SwiftUI

/// Данные шага моделирования для сохранения/загрузки в/из файл(а) Истории
struct HistoryStep: Codable, Identifiable, Sendable {
    var id = UUID()
    var t: Double
    var state: SimulationState
    var parameters: SimulationParameters
    var comment: String?
    var totalTimeElapsed: TimeInterval
    var startTime: Date?
}
