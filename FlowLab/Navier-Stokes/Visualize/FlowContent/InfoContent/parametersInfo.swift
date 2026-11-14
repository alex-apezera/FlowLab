//
//  parametersInfo.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 18.07.2025.
//
//MARK: Monitoring task parameters

import SwiftUI
extension Visualizator {
    
    /// Мониторинг параметров задачи.
    var parametersInfo: some View {
        VStack(alignment: .leading, spacing: 10) {
            methodsInfo
            numbers
            substance
            if solver.allowMelt { meltInfo }
            infoLine
        }
        .font(.system(.footnote, design: .monospaced))
        .padding(.horizontal)
    }
    
    /// Методы, геометрия, опции
    private var methodsInfo: some View {
        HStack {
            let epm = solver.useEnthalpyMethod
            let conc = solver.useConcurrence
            let pd = solver.useParallelDiffusion
            let pp = solver.useParallelPressure
            let ste = solver.useStephanScheme
            let adr = solver.useAdaptiveRelax
            let ws = solver.params.windSpeed*1000
            let wa = solver.params.windAngle
            let wt = solver.params.windDeltaTemp
            let sink = solver.params.leftSink
            Text("Solve. ").bold().font(.body)
            Text("Method:").bold()
            Text("\(epm ? "EPM" : "ALE").")
            Text("Domain. ").bold().font(.body)
            Text("Size w・h [mm]:").bold()
            Text("\(solver.params.Lx * 1000 , specifier: "%.0f")x\(solver.params.Ly * 1000, specifier: "%.0f").")
            Text("Grid:").bold()
            Text("\(solver.params.nx)x\(solver.params.ny), \(solver.useEnthalpyMethod ? "square" : "st= \(solver.stretch_x, specifier: "%.1f")x\(solver.stretch_y, specifier: "%.1f")").")
            if solver.params.useWind {
                Text("Wind:").bold()
                Text("speed \(ws, specifier: "%.0f")mm/s,")
                Text("direction \(wa, specifier: "%.0f")°,")
                Text("ΔT_in \(wt, specifier: "%.0f")°C,")
                Text(sink ? "left sink." : "top/bottom sink.")
            }
            if ste { Text("Ste scheme is ON. ") }
            if adr { Text("Adaptive p-realax.") }
            if conc || pd || pp {
                Image(systemName: "cpu.fill")
                Text("\(solver.workerCount):")
                if conc { Text("conv, 𝐕 corr & div,") }
                if pd  { Text("diff,") }
                if pp { Text("press.") }
            }

        }
    }
    
    /// Числа подобия
    private var numbers: some View {
        HStack {
            let inf = solver.allowMelt ? "front" : "cold"
            let q_hot = solver.q_hotWall.last ?? 0
            let q_cold = solver.q_coldWall.last ?? 0
            let Nu_hot = solver.Nu(q: q_hot, T: solver.averageTempHotwall)
            let Nu_cold = solver.Nu(q: q_cold, T: solver.T_melt)

            Text("Numbers.").bold().font(.body)
            Text("Ra: gβΔT·W³/(να)").bold()
            Text("\(solver.Ra, specifier: "%.3e"),")
            Text("Re: 𝐕ᵐW/ν \(solver.Re, specifier: "%.3e"),")
            Text("Pr: ν/α \(solver.Pr, specifier: "%.2f"),")
            if solver.allowMelt {
                Text("Ste: CpΔT/Lʰ \(solver.Ste, specifier: "%.2f"),")
                Text("Fo: αt/W² \(solver.Fo, specifier: "%.2f"),")
            }
            Text("Nu: q・W/(λ・ΔT)").bold()
            Text("hot \(Nu_hot, specifier: "%.3f")")
            Text("\(inf) \(Nu_cold, specifier: "%.3f").")
            Text("Q:").bold()
            Text("hot \(solver.q_hotWall.last ?? 0, specifier: "%.0f")")
            Text("\(inf) \(solver.q_coldWall.last ?? 0, specifier: "%.0f")")
        }
    }
    
    /// Праметры вещества и температуры
    private var substance: some View {
        HStack {
            let value = solver.params.heatingValue

            Text("Substance. ").bold().font(.body)
            Text("\(solver.substance.properties.name):").bold()
            Text("T₀ \(solver.T_melt, specifier: "%.0f")ºC,")
            switch solver.params.heatingType {
            case .temperature:
                Text("ΔT \(value, specifier: "%.0f")ºC,")
            case .heatFlux:
                Text("q₀ \(value, specifier: "%.0f")[W/m²],")
            }
            Text("α \(solver.alpha, specifier: "%.2e")[m²/s],")
            Text("β \(solver.beta, specifier: "%.1e")[K⁻¹],")
            Text("ν \(solver.nu, specifier: "%.2e")[m²/s],")
            Text("λ \(solver.lambda, specifier: "%.2f")[W/(m·K)],")
            Text("ρ \(solver.rho, specifier: "%.2f")[kg/m³],")
            if solver.allowMelt {
                Text("Lʰ \(solver.latentHeat, specifier: "%.2e")[W·s/kg].")
            }
        }
    }
    
    /// Параметры процесса плавления
    private var meltInfo: some View {
        HStack {
            if solver.latentHeat < 1e6 {
                Text("Melting. ").bold().font(.body)
                if isSolving || history.frames.isEmpty {
                    // Режим решения: используем текущие данные
                    let (avg, min, max) = solver.liquidWidth(solver.liquidFraction, solver.rx, solver.rx_avg)
                    displayParams(solver.initialTime, solver.fullMeltingTime, solver.dTime, avg, min, max, solver.V_melt_avg)

                } else {
                    // Режим истории: используем выбранный кадр
                    let frameIndex = min(currentFrameIndex, history.frames.count-1)
                    let historyFrame = history.frames[frameIndex]
                    let liquidFraction = historyFrame.liquidFraction
                    let rx = historyFrame.rx
                    let rx_avg = historyFrame.rx_avg
                    let (avg, min, max) = solver.liquidWidth(liquidFraction, rx, rx_avg)
                    let initialWidth = solver.params.initMeltWidth
                    let meltingTime = solver.meltingTime(from: avg * initialWidth)
                    let initTime = solver.initialTime
                    let fullTime = meltingTime > initTime ? meltingTime : initTime
                    let dTime = historyFrame.dTime
                    displayParams(initTime, fullTime, dTime, avg, min, max, historyFrame.V_melt_avg)
                }
            }
        }
    }

    /// Отображение параметров плавления
    private func displayParams(_ initTime: Double,_ fullTime: Double, _ dTime: Double, _ avg: Double, _ min: Double, _ max: Double, _ widthChange: Double) -> some View {
        HStack {
            let dimW = realSize ? "[mm]" : ""
            let width = realSize ? "W" : "W/W₀"
            let dimH = realSize ? "[mm/h]" : "[%/h]"
            let form = realSize ? "%.0f" : "%.2f"
            let initW = solver.initMeltWidth * 1000
            let widthAvg = realSize ? initW * avg : avg
            let minW = realSize ? initW * min : min
            let maxW = realSize ? initW * max : max
            let widthC = realSize ? initW * widthChange : widthChange
            let scale: Double = realSize ? 1 : 100
            
            Button {realSize.toggle()}
            label: {Text("Width:").bold().underline(false)}
                .keyboardShortcut("f", modifiers: [])

            Text("W₀ \(initW, specifier: "%.0f")mm,")
            Text("\(width) \(widthAvg, specifier: form)")
            Text("(min \(minW, specifier: form),")
            Text("max \(maxW, specifier: form))\(dimW);")
            Text("rise:").bold()
            Text("\(widthC*3600*scale, specifier: "%.2f")\(dimH).")
            Text("Time:").bold()
            Text("init \(formattedTime(initTime)),")
            Text("full \(formattedTime(fullTime)),")
            Text("pure \(formattedTime(fullTime-initTime)),")
            Text("step \(formattedTime(dTime)).")
        }
    }
    
    /// Статистика о ходе решения
    private var infoLine: some View {
        HStack {
            Text("Process.").bold().font(.body)
            Text("Start \(timerManager.formattedStartDate())")
            Text("Spent \(timerManager.formattedElapsedTime())")
            Text("Memory \(SystemMonitor.getMemoryUsage, specifier: "%3.0f")Mb  CPU \(SystemMonitor.getCPUUsage, specifier: "%3.0f")%")
                .padding(.trailing, 20)
            Text("Frames \(history.frames.count, specifier: "%3d")")
            if isSolving || history.frames.isEmpty {
                // Режим решения - используем текущие данные solver
                Text("step \(solver.step, specifier: "%04d")")
                Text("t \(solver.t, specifier: "%3.2f")[s]")
                rabbit
            } else {
                // Режим истории - используем выбранный кадр
                let frameIndex = min(currentFrameIndex, history.frames.count-1)
                let historyFrame = history.frames[frameIndex]
                Text("step \(historyFrame.step, specifier: "%04d")")
                Text("t \(historyFrame.t, specifier: "%3.2f")[s]")
                Text("Δt \(historyFrame.dt, specifier: "%0.5f")[s]")
            }
        }
    }

}
