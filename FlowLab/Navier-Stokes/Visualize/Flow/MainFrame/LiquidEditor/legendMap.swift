//
//  legendMap.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 28.01.2026.
//
import SwiftUI
extension LiquidFractionEditor {
    
    // View box: Легенда и управление
    var legendMap: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("КОМАНДЫ управления твердой фазой").font(.headline).bold()
            Text("ESC: Очистить (возврат к исходному)")
            Text(solver.makeSolid ? "R: ВЫКЛ режим <камень>" : "R: ВКЛ режим <камень>")

            Text("ФОРМА: \(String(describing: currentTool))").bold().padding(.top, 10)
            Text("1: Кисть | 2: Цилиндр | 3: Блок | 4: Ластик")
            Text("Размер кисти: [ + ] / [ - ]").font(.caption)
            
            Text("ОБЪЕКТ: \(solver.activeObjectType == .circle ? "Цилиндр" : "Блок")").bold().padding(.top, 10)
            Text("Стрелки и курсор: Перемещение")
            Text("WSAD: Размер")
            Text("Enter: Зафиксировать (Bake)")
            
            Text("ФАЙЛЫ:").bold().padding(.top, 10)
            Text("Cmd+S: Сохранить | Cmd+O: Открыть")
    
            Text("ПРОЦЕСС решения:").bold().padding(.top, 10)
            Text("Tab: ВКЛ/ВЫКЛ макс ускорение")
            Text("Ctrl+S: ЗАПУСК/ПАУЗА")

        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(8)
        .padding()
    }
}
