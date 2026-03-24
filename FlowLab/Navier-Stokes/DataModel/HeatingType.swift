//
//  HeatingType.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 13.11.2025.
//

//import SwiftUI

enum HeatingType: String, Codable, CaseIterable, Sendable {
    case temperature = "Температура T (ºC)"  /// задана температура, [ºC]
    case heatFlux = "Тепловой поток q (Вт/м²)" /// q - удельный тепловой поток [W/m²]
    
    // Дополнительное вычисляемое свойство для красивого отображения
    // (если вам не нравятся raw values)
    var designation: String {
        switch self {
        case .temperature:
            return "∆T [ºC]"
        case .heatFlux:
            return "q [W/m²]"
        }
    }
}

import SwiftUI

struct HeatingSelectorView: View {
    // 1. Переменная состояния, которая хранит выбранное значение.
    // Устанавливаем значение по умолчанию, например, temperature.
    @State private var selectedHeatingType: HeatingType = .temperature
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Текущий метод задания условия:")
                .font(.headline)
            
            // 2. Использование Picker
            Picker("Выберите тип условия", selection: $selectedHeatingType) {
                // 3. Перебираем все возможные варианты перечисления
                ForEach(HeatingType.allCases, id: \.self) { type in
                    // Используем Text с localizedName для отображения
                    Text(type.designation)
                        .tag(type) // Связываем каждый Text с конкретным значением enum
                }
            }
            // 4. Применяем стиль segmented для отображения в виде кнопок-сегментов
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Визуальное подтверждение выбора
            Text("Выбрано: \(selectedHeatingType.designation)")
                .foregroundColor(selectedHeatingType == .temperature ? .blue : .red)
        }
    }
}
