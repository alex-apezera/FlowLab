//
//  updateInspector.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 17.03.2026.
//
//MARK: - Updating the cellInfoPopup(:) coordinate inspector

import SwiftUI
extension Visualizator {
    
    /// Обновление инспектора координат всплывающего окна cellInfoPopup(:)
    func updateInspector(at location: CGPoint, in size: CGSize) {
        // 1. Проверка границ (не выходим ли за рамки Canvas)
        guard location.x >= 0 && location.x <= size.width &&
              location.y >= 0 && location.y <= size.height else {
            self.selectedCell = nil
            return
        }

        // Считаем реальный аспект содержимого (тепловой карты)
        let maxY = solver.y.last ?? 1.0
        let maxX = solver.x.last ?? 1.0
        let maxRx = solver.rx.max() ?? 1.0
        let totalPhysWidth = maxX * maxRx
        let totalPhysHeight = solver.y.last ?? 1.0
        let contentAspect = totalPhysWidth / totalPhysHeight
        
        // Считаем аспект контейнера (экранной области)
        let containerAspect = size.width / size.height
        
        // Находим реальную ширину тепловой карты на экране (в пикселях)
        var canvasViewWidth: CGFloat
        var xOffset: CGFloat = 0
        
        if contentAspect > containerAspect {/// Карта уперлась в бока, отступов по X нет
            canvasViewWidth = size.width
        } else { /// Карта уперлась в верх/низ, по бокам пустые поля (центрирование)
            canvasViewWidth = size.height * contentAspect
            xOffset = (size.width - canvasViewWidth) / 2
        }

        // Корректируем X относительно начала тепловой карты
        let localX = location.x - xOffset
        
        // Проверка: если кликнули в "пустое поле" слева или справа
        guard localX >= 0 && localX <= canvasViewWidth else {
            self.selectedCell = nil
            return
        }

        // Пересчитываем PhysX на основе РЕАЛЬНОЙ ширины карты
        let scaleX = totalPhysWidth / canvasViewWidth
        let physX = localX * scaleX

        // Инвертируем Y, так как в SwiftUI 0 вверху, а в модели 0 внизу
        let physY = (size.height - location.y) * (maxY / size.height)
        
        // Находим индекс J (вертикаль)
        guard let j = solver.y.firstIndex(where: { $0 > physY }).map({ $0 - 1 }),
              j >= 0 && j < solver.ny else {
            self.selectedCell = nil
            return
        }

        // Находим индекс I (горизонталь)
        /// Так как сетка прижата к левому краю Canvas, xOffset = 0 относительно начала координат
        /// Но нам нужно учесть, что физическая ширина ряда j в "метрах" равна maxX•solver.rx[j]
        let currentRx = solver.rx[j]
        
        // Ищем узел, учитывая локальное расширение ALE в этом ряду
        guard let i = solver.x.firstIndex(where: { ($0 * currentRx) > physX }).map({ $0 - 1 }),
              i >= 0 && i < solver.nx else {
            self.selectedCell = nil
            return
        }

        // Запись результата
        let idx = j * solver.nx + i
        if idx >= 0 && idx < solver.isStone.count {
            self.selectedCell = CellInfo(fromIdx: idx, solver: solver)
            self.inspectorPos = location
        } else { self.selectedCell = nil }
    }
    
}
