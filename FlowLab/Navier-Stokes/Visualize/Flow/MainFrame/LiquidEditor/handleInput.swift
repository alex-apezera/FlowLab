//
//  handleInput.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 28.01.2026.
//
import Foundation
import Combine
extension LiquidFractionEditor {
    // --- ЛОГИКА РИСОВАНИЯ И КОЛЛИЗИЙ ---
    func handleInput(at location: CGPoint, in size: CGSize) {
        let cellW = size.width / CGFloat(cols)
        let cellH = size.height / CGFloat(rows)
        
        let cIdx = Int(location.x / cellW)
        // ИНВЕРСИЯ при вводе: переводим экранный Y в индекс массива r
        let rIdx = (rows - 1) - Int(location.y / cellH)
        // Для квадрата/круга используем brushSize как диаметр
        let radius = Int(brushSize / 2)
        DispatchQueue.main.async {
//            solver.objectWillChange.send()
            
            for r in (rIdx - radius)...(rIdx + radius) {
                for c in (cIdx - radius)...(cIdx + radius) {
                    guard r >= 0 && r < rows && c >= 0 && c < cols else { continue }
//                    solver.objectWillChange.send()
                    
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
                        
                        if currentTool == .eraser {
                            // ЛАСТИК: Делаем зону жидкой и убираем камень
                            solver.liquidFraction[flatIdx] = 1.0
                            solver.isStone[flatIdx] = 0
//                            solver.T[r][c] = solver.T_hot // Опционально: подогреваем, чтобы не замерзло сразу
                        } else {
                            // РИСОВАНИЕ:
                            if solver.makeSolid {
                                // Если это "вечный" камень
                                solver.isStone[flatIdx] = 1
                                solver.liquidFraction[flatIdx] = 0.0 // Внутри камня жидкости нет
                            } else {
                                // Если это просто принудительная заморозка (лед)
                                solver.liquidFraction[flatIdx] = 0.0
                                solver.isStone[flatIdx] = 0
                            }
                            
                            // Обнуляем физику в этой точке
                            solver.T[r][c] = solver.T_cold
                            solver.u[r][c] = 0.0
                            solver.v[r][c] = 0.0
                        }

                        /*
                        if currentTool == .eraser {
                            solver.liquidFraction[r][c] = 1.0
                            if solver.makeSolid {
                                solver.isStone[solver.idx(c, r)] = 0 }
                        } else {
                            solver.liquidFraction[r][c] = 0.0
                            if solver.makeSolid {
                                solver.isStone[solver.idx(c, r)] = 1 }
                            solver.T[r][c] = solver.T_cold
                            solver.u[r][c] = 0.0
                            solver.v[r][c] = 0.0
                        }
                        */
                    }
                }
            }
            print("Stone cells count: \(solver.isStone.filter{$0==1}.count)")
            solver.objectWillChange.send()
        }
    }
}
