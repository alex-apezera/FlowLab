//
//  ApplyState.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 07.02.2026.
//
//MARK: - Loading fraction state and temperature

import Foundation
import Combine

extension NavierStokesSolver {
    
    /// Загрузка состояния фракции и температуры
    func applyState(_ state: SimulationStateLiquidFraction) {
        DispatchQueue.main.async { [self] in
            objectWillChange.send()
            liquidFraction = state.liquidFraction
            T = state.T
        }
    }
}
