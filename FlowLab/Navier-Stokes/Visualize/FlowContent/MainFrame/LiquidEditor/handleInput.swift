//
//  handleInput.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 28.01.2026.
//
//MARK: - Manual drawing of solid phase in the computational domain

import Foundation
import Combine
extension LiquidFractionEditor {
    
    /// Ручная отрисовка включений твердой фазы врасчетной области
    func handleInput(at location: CGPoint, in size: CGSize) {
        let cellW = size.width / CGFloat(cols)
        let cellH = size.height / CGFloat(rows)
        
        let cIdx = Int(location.x / cellW)
        // ИНВЕРСИЯ при вводе: переводим экранный Y в индекс массива r
        let rIdx = (rows - 1) - Int(location.y / cellH)
        // Для квадрата/круга используем brushSize как диаметр
        let radius = Int(brushSize / 2)
        DispatchQueue.main.async {
            
            for r in (rIdx - radius)...(rIdx + radius) {
                for c in (cIdx - radius)...(cIdx + radius) {
                    guard r >= 0 && r < rows && c >= 0 && c < cols else { continue }
                    
                    let dx = Double(c - cIdx)
                    let dy = Double(r - rIdx)
                    
                    var shouldApply = false
                    switch currentTool {
                    case .freehand, .circle:
                        // Круглая кисть или Цилиндр
                        shouldApply = sqrt(dx*dx + dy*dy) <= Double(radius)
                    case .rectangle:
                        // Прямоугольник
                        shouldApply = true
                    case .eraser:
                        shouldApply = sqrt(dx*dx + dy*dy) <= Double(radius)
                    }
                    
                    if shouldApply {
                        
                        let flatIdx = r * cols + c
                        
                        if currentTool == .eraser { ///Ластик
                            // Делаем зону жидкой и убираем камень
                            solver.liquidFraction[flatIdx] = 1.0
                            solver.isStone[flatIdx] = 0
                        } else {
                            // РИСОВАНИЕ:
                            if solver.makeSolid {
                                // Если это "вечный" камень
                                solver.isStone[flatIdx] = 1
                                solver.liquidFraction[flatIdx] = 0.0
                            } else {
                                // Если это принудительная заморозка
                                solver.liquidFraction[flatIdx] = 0.0
                                solver.isStone[flatIdx] = 0
                            }
                            
                            // Обнуляем физику в этой точке
                            solver.T[flatIdx] = solver.T_cold
                            solver.u[flatIdx] = 0.0
                            solver.v[flatIdx] = 0.0
                        }

                    }
                }
            }
            print("Stone cells count: \(solver.isStone.filter{$0==1}.count)")
            solver.objectWillChange.send()
        }
    }
}
