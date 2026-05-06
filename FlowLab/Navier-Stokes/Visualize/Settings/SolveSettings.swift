//
//  SolveSettings.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 28.11.2025.
//
//MARK: - Adjusting the computing process settings

import SwiftUI

/// Корректировка настроек вычислительного процесса
struct SolveSettings: View {
    @ObservedObject var solver: NavierStokesSolver
    
    @State private var maxIterations: String = ""
    @State private var relaxationFactor: String = ""
    @State private var criticalError: String = ""
    @State private var countsLimit: String = ""
    @State private var maxHistorySteps: String = ""
    @State private var deltaStable: Double = 0.1
    @State private var hiStabLimit: Double = 0.3
    @State private var lowStabLimit: Double = 0.2
    @State private var tolerancePsi: String = ""

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Adaptation of Δt by CFL" )) {
                        HStack {
                            Text("CFL: \(lowStabLimit, specifier: "%.2f") ÷ \(hiStabLimit, specifier: "%.2f")")
                            Slider(value: $lowStabLimit, in: 0.1...1)
                        }
                        HStack {
                            Text("ΔCFL: \(deltaStable, specifier: "%.2f")")
                            Slider(value: $deltaStable, in: 0.05...0.3)
                        }
                        Text("● CFL = Δt・𝐕ᵐ/Δx₀; CFL ≤ lowLimit -> Δt += 2%; CFL = lowLimit ÷ hiLimit -> Δt = const; CFL ≥ hiLimit -> Δt -= 3%")
                            .font(.footnote)
                        Toggle("ON/OFF gybbrid scheme", isOn: $solver.useHybridScheme)
                        if solver.useHybridScheme {
                            HStack {
                                Text("diffusion F: \(solver.d_Factor, specifier: "%.1f")")
                                Slider(value: $solver.d_Factor, in: 0.4...3)
                            }
                        }
                    }
                    .onChange(of: lowStabLimit) { _, newValue in
                        hiStabLimit = newValue + deltaStable
                    }
                    .onChange(of: deltaStable) { _, newValue in
                        hiStabLimit = lowStabLimit + newValue
                    }
                    Section(header: Text("Stream function ω (Poisson solving)")) {
                        editStringValue("Tolerable error", $tolerancePsi)
                    }
                    Section(header: Text("Iteration process for pressure")) {
                        VStack {
                            Toggle("Apply adaptive relaxation", isOn: $solver.params.useAdaptiveRelax)
                            editStringValue("Iterations limit",  $maxIterations)
                            editStringValue("Relaxation factor", $relaxationFactor)
                            editStringValue("Critical error", $criticalError)
                        }
                    }
                    Section(header: Text("Array lenghth limitation")) {
                        VStack {
                            editStringValue("Diagnostics counts limit", $countsLimit)
                            editStringValue("Max history steps", $maxHistorySteps)
                        }
                    }
                }
            }
        }
        .onAppear(perform: loadSettings)
        .onDisappear(perform: saveSettings)
        .navigationModifier("Process")
        .done
    }
    
    /// Загрузка параметров
    private func loadSettings() {
        hiStabLimit = solver.params.hiStabLimit
        lowStabLimit = solver.params.lowStabLimit
        deltaStable = hiStabLimit - lowStabLimit
        maxIterations = "\(solver.maxIterations)"
        relaxationFactor = "\(solver.relaxationFactor)"
        criticalError = "\(solver.params.criticalError)"
        countsLimit = "\(solver.params.countsLimit)"
        maxHistorySteps = "\(solver.params.maxHistorySteps)"
        tolerancePsi = "\(solver.tolerancePsi)"
    }
    
    /// Сохранение параметров
    private func saveSettings() {
        solver.params.hiStabLimit = hiStabLimit
        solver.params.lowStabLimit = lowStabLimit
        if let mi = Int(maxIterations) { solver.maxIterations = mi }
        if let rf = Double(relaxationFactor) {solver.relaxationFactor = rf}
        if let ce = Double(criticalError) {solver.params.criticalError = ce}
        if let tp = Double(tolerancePsi) { solver.tolerancePsi = tp }
        if let cl = Int(countsLimit) { solver.params.countsLimit = cl }
        if let mhs = Int(maxHistorySteps) {
            solver.params.maxHistorySteps = mhs }
        print("Новые параметры: \(solver.params)")
    }

}
