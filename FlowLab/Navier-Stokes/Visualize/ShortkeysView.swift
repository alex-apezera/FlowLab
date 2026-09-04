//
//  ShortkeysView.swift
//  FlowLab
//
//  Created by Алексей Езерский on 19.09.2026.
//

// MARK: - View for keyboardShortcut info

import SwiftUI

/// Представление для информации о горячих клавишах
struct ShortKeysView: View {
    
    var body: some View {
        NavigationView {
            Form {
                // Управление контрольной панелью
                Section(header: Text("Control panel buttons").font(.headline)) {
                    Text("q: Start/Pause solving")
                    Text("z: Diagnostics view")
                    Text("x: Reset solver")
                    Text("c: Shortkeys info")
                    Text("/: Settings view")
                    Text(".tab: Accelerate mode")
                }
                // Информация о процессе плавления
                Section(header: Text("Melting")) {
                    Text("m: Activate/deactivate melting process")
                    Text("f: Change dimension info")
                }
                // Заморозка скоростей
                Section(header: Text("Velocity")) {
                    Text("v: Velocity freezing/unfreezing")
                }
                // Управление шагом по времени
                Section(header: Text("Time step Δt")) {
                    Text("t: Set default time step")
                    Text("[: Time step reduce")
                    Text("]: Time step increase")
                }
                // Действия в строке-переключателе объекта
                Section(header: Text("Switching raw")) {
                    Text("?: Shortkeys info")
                    Text("1..7: Selection of the object")
                    Text(".escape: Reset thermal map transformation ")
                    // Редактирование объектов в жидкости
                    Text("For editing objects in liquid, see 🟦")
                }
                // Опции в окне диагностики и истории
                Section(header: Text("Diagnostics")) {
                    Text("p: Pressure iterations increase/reduce")
                    Text(">: Toggle plots group")
                    Text(".space: Play/Pause History frames")
                }
            }
            .navigationModifier("Shortkeys info")
            .done
        }
    }
}
