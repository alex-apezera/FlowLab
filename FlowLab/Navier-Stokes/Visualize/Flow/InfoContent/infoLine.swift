//
//  infoLine.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 25.11.2025.
//
import SwiftUI
extension Visualizator {
    
    //MARK: - Вычисляемые, в ходе решения и трансляции истории, параметры
    var infoLine: some View {
        HStack(spacing: 20) {
            Text("Process").bold()
            Text("\(isSolving ? "💡" : "🅿️")")
                .blinking(duration: isSolving ? 0.2 : 1.0).bold()
            Text("Start \(timerManager.formattedStartDate())")
            Text("Spent \(timerManager.formattedElapsedTime())")
            if solver.useConcurrence || solver.useParallelPressure || solver.useEnthalpyMethod {
                HStack {Image(systemName: "cpu.fill")
                Text("\(solver.workerCount)")}
            }
            Text("Memory \(SystemMonitor.getMemoryUsage, specifier: "%.f")Mb  CPU \(SystemMonitor.getCPUUsage, specifier: "%.f")%")
           Spacer()
            Text("Frames \(history.frames.count)")
            if isSolving || history.frames.isEmpty {
                // Режим решения - используем текущие данные solver
                Text("step \(solver.step)")
                Text("t \(solver.t, specifier: "%.2f")[s]")
            } else {
                // Режим истории - используем выбранный кадр
                let frameIndex = min(currentFrameIndex, history.frames.count-1)
                let historyFrame = history.frames[frameIndex]
                Text("step \(historyFrame.step)")
                Text("t \(historyFrame.t, specifier: "%.2f")[s]")
            }
            rabbit
            buttonFreeze
        }
        .font(.system(.callout, design: .monospaced))
        .padding(.leading, 15)
    }
    
}
