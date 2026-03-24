//
//  drawPlotsContent.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 18.11.2025.
//
import SwiftUI
extension Visualizator {
    
    //MARK: - Графики для температуры и тепловых потоков
    @ViewBuilder
    var drawPlotsContent: some View {
        if isSolving || history.frames.isEmpty {
            
            if selectedVisualization == 3 { // T(x, Y=const)
                TemperaturePlotView(x: solver.x, y: solver.y, T: solver.T, avgTemp: solver.avgTemp) }
            
            if selectedVisualization == 4 {// <q>(time, Y=const)
                let meltWidth = solver.liquidWidth(solver.liquidFraction, solver.rx, solver.rx_avg).avg * solver.Lx * solver.params.initMeltWidthRatio
                let time = solver.allowMelt ? solver.meltingTime(from: meltWidth) : solver.t
                heatFluxPlot(solver.q_coldWall, solver.q_hotWall, time) }
                        
        } else {
            let frameIndex = min(currentFrameIndex, history.frames.count-1)
            let historyFrame = history.frames[frameIndex]
            let meltWidth = solver.liquidWidth(historyFrame.liquidFraction, historyFrame.rx, historyFrame.rx_avg).avg * solver.Lx * solver.params.initMeltWidthRatio
            let time = solver.allowMelt ? solver.meltingTime(from: meltWidth) : historyFrame.t
            
            if selectedVisualization == 3 { // T(x, Y=const)
                TemperaturePlotView(x: solver.x, y: solver.y, T: historyFrame.temperature, avgTemp: historyFrame.temperatureVolume.last ?? solver.avgTemp) }
            
            if selectedVisualization == 4 {// <q>(time, Y=const)
                heatFluxPlot(historyFrame.heatFluxE, historyFrame.heatFluxW, time)}
        }
    }
}
