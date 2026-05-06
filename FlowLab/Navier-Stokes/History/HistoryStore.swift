//
//  HistoryStore.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 07.12.2025.
//

import Foundation
import Combine
/// Управление кадрами Истории для хранения на диске
class HistoryStore: ObservableObject {
    @Published var frames: [HistoryFrame] = []
    private let solver = NavierStokesSolver()
    
    /// Формирование массива кадров Истории
    func addFrame(frame: HistoryFrame) {
        frames.append(frame)
        if frames.count > solver.params.maxHistorySteps {
            frames.removeFirst()
        }
    }
    /// Удаление всех кадров Истории
    func clear() {
        frames.removeAll()
    }
}
