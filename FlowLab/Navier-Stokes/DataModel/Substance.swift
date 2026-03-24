//
//  Substance.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 13.11.2025.
//

import SwiftUI

//MARK: - Вещество для моделирования
enum Substance: String, Codable, CaseIterable, Sendable {
    case water, wax23, wax33, wax56, air, custom
    
    var localizedName: String {
        switch self {
        case .water: return "Вода"
        case .wax23: return "н-Эйкозан"
        case .wax33: return "н-Докозан"
        case .wax56: return "Парафин"
        case .air: return "Воздух"
        case .custom: return "Псевдо"
        }
    }
 
    var properties: FluidProperties {
        switch self {
        case .water: return .water
        case .wax23: return .wax23
        case .wax33: return .wax33
        case .wax56: return .wax56
        case .air: return .air
        case .custom: return .custom /// custom обрабатывается отдельно
        }
    }
}
