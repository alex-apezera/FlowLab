//
//  TimeSettings.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 01.12.2025.
//
//MARK: - Adjustment of time parameters

import SwiftUI

/// Корректировка временнЫх параметров
struct TimeSettings: View {
    @ObservedObject var solver: NavierStokesSolver
    
    @State private var max_t = ""
    @State private var dt = ""
    @State private var dtInterval = ""
    @State private var time_scale = ""
    @State private var rangeX: String = ""
    @State private var meltVolumeLimit: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Time settings")) { timeSettings }
            }
        }
        .navigationModifier("Time")
        .onAppear(perform: loadSettings)
        .onDisappear(perform: saveSettings)
        .done
    }
    
    /// Загрузка настроек
    private func loadSettings() {
        // Загружаем существующие параметры
        max_t = "\(solver.params.maxTime)"
        dt = "\(solver.params.timeStep)"
        dtInterval = "\(solver.params.timeGap)"
        time_scale = "\(solver.params.timeScale)"
        rangeX = "\(solver.params.Rx)"
        meltVolumeLimit = "\(solver.meltVolumeLimit)"
    }
    
    /// Сохранение настроек
    private func saveSettings() {
        // Обновляем параметры решателя
        if let mt = Double(max_t) { solver.params.maxTime = mt }
        if let dt = Double(dt) { solver.params.timeStep = dt }
        if let di = Double(dtInterval) { solver.params.timeGap = di }
        if let ts = Double(time_scale) {  solver.params.timeScale = ts }
        if let rx = Double(rangeX) { solver.params.Rx = rx }
        if let dt = Double(dt) { solver.dt = dt }
        if let ml = Double(meltVolumeLimit) { solver.meltVolumeLimit = ml }
    }
    
    /// Редактирование настроек
    private var timeSettings: some View {
        VStack {
            editStringValue("End solving time, t [s]", $max_t)
            editStringValue("End melt volume", $meltVolumeLimit)
            editStringValue("Solving time step, Δt [s]", $dt)
            editStringValue("History time interval [s]", $dtInterval)
            editStringValue("Melting time scale", $time_scale)
            editStringValue("Melt volume range limit", $rangeX)
        }
        .padding()
    }
}
