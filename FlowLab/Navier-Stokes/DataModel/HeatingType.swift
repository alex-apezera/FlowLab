//
//  HeatingType.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 13.11.2025.
//
// MARK: - Determine Heat Type

/// Тип подогрева левой границы
enum HeatingType: String, Codable, CaseIterable, Sendable {
    case temperature = "T (ºC)"  /// задана температура, [ºC]
    case heatFlux = "q (Вт/м²)" /// q - задан удельный тепловой поток [W/m²]
    
    /// Вычисляемая переменная для отображения свойства
    var designation: String {
        switch self {
        case .temperature:
            return "∆T [ºC]"
        case .heatFlux:
            return "q [W/m²]"
        }
    }
}
