//
//  drawPlotsContent.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 18.11.2025.
//
//MARK: - Temperature and heat flow graphs

import SwiftUI
extension Visualizator {
    
    /// Графики для температуры и тепловых потоков
    @ViewBuilder var drawPlotsContent: some View {
        if isSolving || history.frames.isEmpty {
            
            if selectedVisualization == 3 { // T(x, Y=const)
                let temperature = unflattenIdiomatic(flatArray: solver.T, nx: solver.nx, ny: solver.ny)
                TemperaturePlotView(x: solver.x, y: solver.y, T: temperature, avgTemp: solver.avgTemp) }
            
            if selectedVisualization == 4 {// <q>(time, Y=const)
                let meltWidth = solver.liquidWidth(solver.liquidFraction, solver.rx, solver.rx_avg).avg * solver.Lx * solver.params.initMeltWidthRatio
                let time = solver.allowMelt ? solver.meltingTime(from: meltWidth) : solver.t
                let timeFirst = solver.timePoints.first ?? (solver.allowMelt ? solver.initialTime : 0.0)
                heatFluxPlot(solver.q_coldWall, solver.q_hotWall, time, timeFirst) }
                        
        } else {
            let frameIndex = min(currentFrameIndex, history.frames.count-1)
            let historyFrame = history.frames[frameIndex]

            if selectedVisualization == 3 { // T(x, Y=const)
                let temperature = unflattenIdiomatic(flatArray: historyFrame.temperature, nx: solver.nx, ny: solver.ny)
                TemperaturePlotView(x: solver.x, y: solver.y, T: temperature, avgTemp: historyFrame.temperatureVolume.last ?? solver.avgTemp) }
            
            if selectedVisualization == 4 {// <q>(time, Y=const)
                let meltWidth = solver.liquidWidth(historyFrame.liquidFraction, historyFrame.rx, historyFrame.rx_avg).avg * solver.Lx * solver.params.initMeltWidthRatio
                let time = solver.allowMelt ? solver.meltingTime(from: meltWidth) : historyFrame.t
                let timeFirst = historyFrame.timePoints.first ?? (solver.allowMelt ? solver.initialTime : 0.0)

                heatFluxPlot(historyFrame.heatFluxE, historyFrame.heatFluxW, time, timeFirst)}
        }
    }
}
