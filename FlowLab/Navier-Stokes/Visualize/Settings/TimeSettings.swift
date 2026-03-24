//
//  TimeSettings.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 01.12.2025.
//


import SwiftUI

//MARK: - Корректировка временнЫх параметров

struct TimeSettings: View {
    @ObservedObject var solver: NavierStokesSolver
    @Environment(\.presentationMode) var presentationMode
    
    @State private var max_t = ""
    @State private var dt = ""
    @State private var dtInterval = ""
    @State private var time_scale = ""
    @State private var rangeX: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Временнӹе параметры")) { timeSettings }
            }
        }
        .navigationModifier("Время")
        .navigationBarItems(
            trailing: Button("Готово") {
                saveSettings()
                presentationMode.wrappedValue.dismiss()
            }
        )
        .onAppear(perform: loadSettings)
    }
    
    private func loadSettings() {
        // Загружаем существующие параметры
        max_t = "\(solver.params.maxTime)"
        dt = "\(solver.params.timeStep)"
        dtInterval = "\(solver.params.timeGap)"
        time_scale = "\(solver.params.timeScale)"
        rangeX = "\(solver.params.Rx)"
    }
    
    private func saveSettings() {
        // Обновляем параметры решателя
        if let mt = Double(max_t) { solver.params.maxTime = mt }
        if let dt = Double(dt) { solver.params.timeStep = dt }
        if let di = Double(dtInterval) { solver.params.timeGap = di }
        if let ts = Double(time_scale) {  solver.params.timeScale = ts }
        if let rx = Double(rangeX) { solver.params.Rx = rx }
        if let dt = Double(dt) { solver.dt = dt }
    }
    
     private var timeSettings: some View {
        VStack {
            Text("Конечное время решения уравнений, t [s]")
            TextField("Введите число ≃ 10÷3600", text: $max_t)
                .editText()
            Text("Приращение по времени, Δt [s]")
            TextField("Введите число ≲ 0.01", text: $dt)
                .editText()
            Text("Интервал времени занесения решения в историю")
            TextField("Введите число ≥ Δt [s]", text: $dtInterval)
                .editText()
            Text("Масштаб времени при движении границы")
            TextField("Введите число ≃ 1.0÷1e6", text: $time_scale)
                .editText()
            Text("Коэффициент максимальной толщины расплава")
            TextField("Введите число ≃ 2.0÷10.0", text: $rangeX)
                .editText()
        }
        .padding()
    }
}
