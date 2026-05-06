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
            domain
            substance
            if solver.allowMelt { meltInfo }
            infoLine
        }
        .font(.system(.footnote, design: .monospaced))
        .padding(.horizontal)
    }
    
    /// Методы и опции
    private var methodsInfo: some View {
        HStack {
            let epm = solver.useEnthalpyMethod
            let conc = solver.useConcurrence
            let pd = solver.useParallelDiffusion
            let pp = solver.useParallelPressure
            let ste = solver.useStephanScheme
            let adr = solver.useAdaptiveRelax
            Text("Solve. ").bold().font(.body)
            Text("Method (by melting):").bold()
            Text("\(epm ? "Enthalpy-Porous Media (EPM)" : "Arbitrary Lagrangian-Eulerian (ALE)").")
            Text("Numbers:").bold()
            Text("Ra \(solver.Ra, specifier: "%.0f"),")
            Text("Re \(solver.Re, specifier: "%.0f"),")
            Text("Pr \(solver.Pr, specifier: "%.2f").")
            if solver.allowMelt {
                Text("Ste \(solver.Ste, specifier: "%.2f")")
                Text("Fo \(solver.Fo, specifier: "%.2f")")
            }
            if ste { Text("Ste scheme is ON. ") }
            if adr {
                Text("Adaptive").bold()
                Text("p-realax.")
            }
            if conc || pd || pp {
                Image(systemName: "cpu.fill")
                Text("\(solver.workerCount):")
                if conc { Text("conv, 𝐕 corr & div,") }
                if pd  { Text("diff,") }
                if pp { Text("press.") }
            }
        }
    }
    
    /// Геометрия, числа подобия
    private var domain: some View {
        HStack {
            let ws = solver.params.windSpeed*1000
            let wa = solver.params.windAngle
            let wt = solver.params.windDeltaTemp
            let sink = solver.params.leftSink
            Text("Domain. ").bold().font(.body)
            Text("Size w・h [mm]:").bold() /// •
            Text("\(solver.params.Lx * 1000 , specifier: "%.0f")x\(solver.params.Ly * 1000, specifier: "%.0f").")
            Text("N:").bold()
            Text("\(solver.params.nx)x\(solver.params.ny), \(solver.useEnthalpyMethod ? "square" : "st= \(solver.stretch_x, specifier: "%.1f")x\(solver.stretch_y, specifier: "%.1f")").")
            if solver.params.useWind {
                Text("Wind:").bold()
                Text("speed \(ws, specifier: "%.0f")mm/s,")
                Text("direction \(wa, specifier: "%.0f")°,")
                Text("ΔT_in \(wt, specifier: "%.0f")°C,")
                Text(sink ? "left sink." : "top/bottom sink.")
            }
            Text("Qwall [W/m²]:").bold()
            let inf = solver.allowMelt ? "front" : "cold"
            Text("hot \(solver.q_hotWall.last ?? 0, specifier: "%.0f")")
            Text("\(inf) \(solver.q_coldWall.last ?? 0, specifier: "%.0f")")
        }
    }
    
    /// Праметры вещества и температуры
    private var substance: some View {
        HStack {
            Text("Substance. ").bold().font(.body)
            Text("\(solver.substance.properties.name):").bold()
            Text("T₀ \(solver.substance.properties.T_melt, specifier: "%.0f")ºC")
            let value = solver.params.heatingValue
            switch solver.params.heatingType {
            case .temperature:
                Text("ΔT \(value, specifier: "%.0f")ºC")
            case .heatFlux:
                Text("q₀ \(value, specifier: "%.0f")[W/m²]")
            }
            Text("α \(solver.alpha, specifier: "%.2e")[m²/s]")
            Text("β \(solver.beta, specifier: "%.1e")[K⁻¹]")
            Text("ν \(solver.nu, specifier: "%.2e")[m²/s]")
            Text("λ \(solver.lambda, specifier: "%.2f")[W/(m·K)]")
            Text("ρ₀ \(solver.rho, specifier: "%.2f")[kg/m³]")
            if solver.allowMelt {
                Text("latent heat \(solver.latentHeat, specifier: "%.2e")[W·s/kg]")
            }
        }
    }
    
    /// Параметры процесса плавления
    private var meltInfo: some View {
        HStack {
            if solver.latentHeat < 1e6 {
                Text("Melting. ").bold().font(.body)
                if isSolving || history.frames.isEmpty {
                    let (avg, min, max) = solver.liquidWidth(solver.liquidFraction, solver.rx, solver.rx_avg)
                    // Режим решения - используем текущие данные solver
                    displayParams(solver.initialTime, solver.fullMeltingTime, solver.dTime, avg, min, max, solver.V_melt_avg)

                } else {
                    // Режим истории - используем выбранный кадр
                    let frameIndex = min(currentFrameIndex, history.frames.count-1)
                    let historyFrame = history.frames[frameIndex]
                    let liquidFraction = historyFrame.liquidFraction
                    let rx = historyFrame.rx
                    let rx_avg = historyFrame.rx_avg
                    let (avg, min, max) = solver.liquidWidth(liquidFraction, rx, rx_avg)
                    let initialWidth = solver.params.initMeltWidthRatio
                    let meltingTime = solver.meltingTime(from: avg * initialWidth * solver.Lx)
                    let initTime = solver.meltingTime(from: initialWidth * solver.Lx)
                    let fullTime = meltingTime > initTime ? meltingTime : initTime
                    let dTime = historyFrame.dTime
                    displayParams(initTime, fullTime, dTime, avg, min, max, historyFrame.V_melt_avg)
                }
            }
        }
    }

    /// Отображение параметров плавления
    private func displayParams(_ initTime: Double,_ fullTime: Double, _ dTime: Double, _ avg: Double, _ min: Double, _ max: Double, _ volumeChange: Double) -> some View {
        HStack {
            let dimV = realSize ? "[m]" : ""
            let Lx = solver.Lx
            let initVol = solver.initMeltWidthRatio
            let initV = realSize ? Lx*initVol : initVol
            let ratV = realSize ? "V" : "V/V₀"
            let dim = realSize ? "[mm/h]" : "[%/h]"
            let vol = realSize ? Lx*avg : avg
            let minV = realSize ? Lx*min : min
            let maxV = realSize ? Lx*max : max
            let volC = realSize ? volumeChange*Lx : volumeChange
            let scale: Double = realSize ? 1000 : 100
            Button {realSize.toggle()}
            label: {Text("Volume: \(dimV)").bold().underline(false)}
            Text("V₀ \(initV, specifier: "%.2f").")
            Text("\(ratV) \(vol, specifier: "%.2f")")
            Text("(min \(minV, specifier: "%.2f")")
            Text("max \(maxV, specifier: "%.2f"));")
            Text("rise:").bold()
            Text("\(volC*3600*scale, specifier: "%.2f")\(dim).")
            Text("Time:").bold()
            Text("init \(formattedTime(initTime)),")
            Text("full \(formattedTime(fullTime)),")
            Text("pure \(formattedTime(fullTime-initTime)),")
            Text("step \(formattedTime(dTime)).")
        }
    }
    
    /// Информация о ходе решения
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
