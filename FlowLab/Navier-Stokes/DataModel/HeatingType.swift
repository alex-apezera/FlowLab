//
//  HeatingType.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 13.11.2025.
//

//import SwiftUI

enum HeatingType: String, Codable, CaseIterable, Sendable {
    case temperature = "Температура T (ºC)"  /// задана температура, [ºC]
    case heatFlux = "Тепловой поток q (Вт/м²)" /// q - удельный тепловой поток [W/m²]
    
    // Дополнительное вычисляемое свойство для красивого отображения
    // (если вам не нравятся raw values)
    var designation: String {
        switch self {
        case .temperature:
            return "∆T [ºC]"
        case .heatFlux:
            return "q [W/m²]"
        }
    }
}
