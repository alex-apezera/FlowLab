//
//  liquidMap.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 28.01.2026.
//
import SwiftUI
extension LiquidFractionEditor {
    var liquidMap: some View {
        
        // Карта 1: Жидкость + твердое тело и Рисование
        VStack(alignment: .leading) {
            GeometryReader { geo in
                Canvas { context, size in
                    let cellW = size.width / CGFloat(cols)
                    let cellH = size.height / CGFloat(rows)
                    
                    for r in 0..<rows {
                        let rowIdx = r * cols
                        for c in 0..<cols {
                            let flatIdx = rowIdx + c

                            // ИНВЕРСИЯ ОСИ Y для корректного отображения
                            let drawR = (rows - 1) - r
                            let rect = CGRect(x: CGFloat(c) * cellW, y:  CGFloat(drawR) * cellH, width: cellW, height: cellH)
                            
                            // 1. Рисуем тело произвольной формы
                            let isSolid = solver.liquidFraction[flatIdx] < solver.dTm
                            context.fill(Path(rect), with: .color(isSolid ? .gray : .blue))
                            
                            // 2. Рисуем ПРЕДПРОСМОТР (Зеленый фантом)
                            // Он рисуется только если мы выбрали фигуру (2 или 3), но еще не нажали Enter
                            if currentTool == .circle || currentTool == .rectangle {
                                if isPointInsidePreview(col: c, row: r) {
                                    context.fill(Path(rect), with: .color(.green.opacity(0.4)))
                                }
                            }
                        }
                    }
                }
                .gesture( DragGesture(minimumDistance: 0).onChanged { value in
                    let cellW = geo.size.width / CGFloat(cols)
                    let cellH = geo.size.height / CGFloat(rows)
                    
                    if (currentTool == .circle || currentTool == .rectangle) {
                        // ПЕРЕМЕЩЕНИЕ: Привязываем центр фантома к курсору
                        let newCol = value.location.x / cellW
                        let newRow = (rows - 1) - Int(value.location.y / cellH)
                        solver.activeObjectPos = CGPoint(x: newCol, y: CGFloat(newRow))
                    } else {
                        // РИСОВАНИЕ: Стандартная логика freehand/eraser
                        handleInput(at: value.location, in: geo.size)
                    }
                })
                .drawingGroup() // Включает Metal-акселерацию для Canvas
            }
            .aspectRatio(CGFloat(cols)/CGFloat(rows), contentMode: .fit)
            .border(Color.black)
        }
    }
    


}
