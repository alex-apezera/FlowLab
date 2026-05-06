//
//  Substance.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 13.11.2025.
//
//MARK: - Вещество для моделирования

import SwiftUI

enum Substance: String, Codable, CaseIterable, Sendable {
    case water, eicosane, docosane, wax56, air, custom
    
    var localizedName: String {
        switch self {
        case .water: return "Water"
        case .eicosane: return "Eicosane"
        case .docosane: return "Docosane"
        case .wax56: return "Wax"
        case .air: return "Air"
        case .custom: return "Custom"
        }
    }
 
    var properties: FluidProperties {
        switch self {
        case .water: return .water
        case .eicosane: return .eicosane
        case .docosane: return .docosane
        case .wax56: return .wax56
        case .air: return .air
        case .custom: return .custom /// custom обрабатывается отдельно
        }
    }
}
