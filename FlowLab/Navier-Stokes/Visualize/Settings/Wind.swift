//
//  Wind.swift
//  FlowLab
//
//  Created by Алексей Езерский on 02.07.2026.
//
//MARK: - Adjusting forced convection (wind) settings

import SwiftUI

/// Корректировка настроек forced convection (wind)
struct Wind: View {
    @ObservedObject var solver: NavierStokesSolver
    
    var body: some View {
        NavigationView {
            Form {
                Toggle("Wind mode", isOn: $solver.params.useWind)
                    .disabled(solver.heatingType == .heatFlux)
                if (solver.heatingType == .heatFlux) {
                    Text("The Wind mode only works when the heatingType is set to .temperature.")
                }
                if solver.params.useWind {
                    Section(header: Text("Wind configuration")) {
                        Toggle("ON/OFF: sink in hotwall", isOn: $solver.params.leftSink)
                        EditValue(text: "wind speed [m/s]", value: $solver.params.windSpeed)
                        EditValue(text: "inlet temperature delta [ºC]", value: $solver.params.windDeltaTemp)
                        EditValue(text: "wind direction [º]", value: $solver.params.windAngle)
                        EditValue(text: "wind Y-pos-start", value: $solver.params.y_start)
                        EditValue(text: "wind Y-pos-end", value: $solver.params.y_end)
                    }
                }
            }
            .padding()
        }
        .navigationModifier("Wind")
        .done
    }

}

