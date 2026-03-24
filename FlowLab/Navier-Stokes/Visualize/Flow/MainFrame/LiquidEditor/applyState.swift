//
//  ApplyState.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 07.02.2026.
//

import Foundation
import Combine

extension NavierStokesSolver {
    // Метод загрузки данных из файла
    func applyState(_ state: SimulationStateLiquidFraction) {
        DispatchQueue.main.async { [self] in
            objectWillChange.send()
            liquidFraction = state.liquidFraction
            T = state.T
        }
    }
}
