//
//  HistoryStore.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 07.12.2025.
//

import Foundation
import Combine

class HistoryStore: ObservableObject {
    @Published var frames: [HistoryFrame] = []
    private let solver = NavierStokesSolver()
    
    func addFrame(frame: HistoryFrame) {
        frames.append(frame)
        if frames.count > solver.params.maxHistorySteps {
            frames.removeFirst()
        }
    }
    
    func clear() {
        frames.removeAll()
    }
}
