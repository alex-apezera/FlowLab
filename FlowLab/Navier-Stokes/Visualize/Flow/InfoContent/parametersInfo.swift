//
//  parametersInfo.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 18.07.2025.
//
import SwiftUI
extension Visualizator {
    
    //MARK: - Исходные параметры
    var parametersInfo: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Методы и опции
            methodsInfo
            // Геометрия, числа подобия
            region
            // Праметры вещества и температуры
            substance
            // Параметры процесса плавления
            if solver.allowMelt { meltInfo }
        }
        .font(.system(.footnote, design: .monospaced))
        .padding(.horizontal)
    }
    
    private var methodsInfo: some View {
        HStack {
            Text("Решение. ").bold().font(.body)
            Text("Метод").bold()
            Text("\(solver.useEnthalpyMethod ? "Энтальпии-пористости (EPM)" : "Раздвижной стенки (ALE)").")
            if solver.useEnthalpyMethod && solver.params.useGradientCorrection {
                Text("Коррекция II на границе включена. ").bold() }
            Text("Многопоточность").bold()
            if solver.useEnthalpyMethod {
                Text("используется в вычислениях.")
            } else if solver.useConcurrence && solver.useParallelPressure { Text("для диффузии и давления.")
            } else if solver.useConcurrence {
                Text("для диффузии.")
            } else if solver.useParallelPressure {
                Text("для давления.")
            } else {
                Text("не используется.")
            }
            if !solver.params.comment.isEmpty {
                Text("Ещё").bold()
                Text(solver.params.comment)
            }
        }
    }
    
    private var region: some View {
        HStack {
            Text("Область. ").bold().font(.body)
            Text("Размеры w•h [mm]:").bold()
            Text("\(solver.params.Lx * 1000 , specifier: "%.0f")x\(solver.params.Ly * 1000, specifier: "%.0f").")
            Text("Сетка:").bold()
            Text("\(solver.params.nx)x\(solver.params.ny), \(solver.useEnthalpyMethod ? "квадратная" : "сжатие к стенкам: \(solver.stretch_x, specifier: "%.1f")x\(solver.stretch_y, specifier: "%.1f")").")
            Text("Критерии:").bold()
            Text("Ra \(solver.Ra, specifier: "%.0f")")
            Text("Re \(solver.Re, specifier: "%.0f")")
            Text("Pr \(solver.Pr, specifier: "%.2f")")
            if solver.allowMelt {
                Text("Ste \(solver.Ste, specifier: "%.2f")")
                Text("Fo \(solver.Fo, specifier: "%.2f")")
                Text("time scale \(solver.params.timeScale, specifier: "%.1e")")
            }
        }
    }
    
    private var substance: some View {
        HStack {
            Text("Вещество. ").bold().font(.body)
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
    
    private var meltInfo: some View {
        HStack {
            if solver.latentHeat < 1e6 {
                Text("Плавление. ").bold().font(.body)
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
    
    private func displayParams(_ initTime: Double,_ fullTime: Double, _ dTime: Double, _ avg: Double, _ min: Double, _ max: Double, _ volumeChange: Double) -> some View {
        HStack {
            let initVol = solver.initMeltWidthRatio
            Text("Объём:").bold()
            Text("V/V₀ \(avg, specifier: "%.2f")")
            Text("(от \(min, specifier: "%.2f")")
            Text("до \(max, specifier: "%.2f")).")
            Text("Приращение:").bold()
            Text("\(volumeChange*3600*100, specifier: "%.2f")[%/h].")
            Text("Время:").bold()
            Text("от (V₀ \(initVol, specifier: "%.2f")) \(formattedTime(initTime))")
            Text("до \(formattedTime(fullTime)),")
            Text("шаг \(formattedTime(dTime)).")
        }
    }
}
