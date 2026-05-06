//
//  GridStep.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 23.12.2025.
//
//MARK: - Generating mesh step and cavity height (for a square mesh)

import Foundation
extension NavierStokesSolver {
    
    /// Генерация сеточного шага и высоты полости (для квадратной сетки)
    func calculateGridStep() {
        
        // Вычисляем эталонный шаг квадратной сетки
        let h = Lx / Double(nx - 1)
        
        // Вычисляем, сколько целых шагов h уместится в текущую Ly
        // Используем округление до ближайшего целого
        let ny = Int(Darwin.round(params.Ly / h)) + 1
        
        // Вычисляем НОВУЮ Ly,точно соответствующей квадратной сетке
        let correctedLy = Double(ny - 1) * h
        
        // Обновляем параметры решателя
        self.h = h /// Сохраняем как константу для всех расчетов
        params.ny = ny; params.Ly = correctedLy
        // Теперь сетка - равномерная (требуется для Генератора сетки)
        params.stretch_x = 0; params.stretch_y = 0
    }
}
