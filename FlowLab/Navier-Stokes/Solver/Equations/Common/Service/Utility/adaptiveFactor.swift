//
//  adaptiveFactor.swift
//  FlowLab
//
//  Created by Алексей Езерский on 21.06.2026.
//
//MARK: - Adaptive correction relaxationFactor & maxIterations for pressure

extension NavierStokesSolver {

    /// Адаптивная коррекция после цикла repeat-while.
    func adaptiveFactor(_ maxPressureResidual: Double) {
        let maxItersLimit = 1200
        let minRelax = 0.1
        let curRelax = params.relaxationFactor
        let curIters = params.maxIterations
        if maxPressureResidual > params.criticalError {
            // Не сошлось — увеличиваем лимит, снижаем релаксацию
            params.maxIterations = min(maxItersLimit, Int(Double(curIters) * 1.2))
            params.relaxationFactor = max(minRelax, curRelax * 0.9)
        } else {
            // Сошлось — плавно возвращаем к базовым настройкам
            params.maxIterations = max(maxIterations, Int(Double(curIters) * 0.95))
            params.relaxationFactor = min(relaxationFactor,  curRelax * 1.05)
        }
    }
}
