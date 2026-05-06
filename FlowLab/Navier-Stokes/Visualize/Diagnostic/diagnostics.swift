//
//  DiagnosticPlot.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 17.07.2025.
//
//MARK: Monitoring the progress of solving equations

import SwiftUI
extension Visualizator {
    
    /// Диагностика хода решения
    @ViewBuilder
    var diagnostics: some View {
        if showDiagnostics { diagnosticsPlots.padding(.bottom, 10) }
    }
    
    /// Расходимость функции тока из уравнения Пуассона (ω)
    @ViewBuilder
    private func psiDivergence() -> some View {
        let divPsi = "tolerance"
        let maxValue: Double = 1e-6
        let minValue: Double = 3e-9
        Button {
            needsStream = true
            let value = solver.tolerancePsi
            if value > minValue {
                let next = value / 3.0
                solver.tolerancePsi = next < minValue ? maxValue : next
            } else {
                solver.tolerancePsi = maxValue
            }
        } label: {
            Text("(\(divPsi) \(solver.tolerancePsi, specifier: "%.1e"))")
                .underline(false)
        }
        if solver.isCalculatingStream { /// ProgressView
            Text("Calculating...").padding(.horizontal, 5)
                .background(RoundedRectangle(cornerRadius: 5).fill(.ultraThinMaterial))
        }
    }
    
    /// Графики диагностики
    var diagnosticsPlots: some View {
        VStack {
            let relaxC = "relax"
            let pressureC = "Pressure(p):"
            let dtC = solver.allowMelt ? solver.useEnthalpyMethod ? "adaptiveDt" : "dTime" : "dt"
            let iterC = "iterations"
            let tempAvgWall = "<T> hot wall [ºC]"
            let tempAvgTotal =  "<T> fluid [ºC]"
            let dtS =  "simulation step dt [s]"
            let dtM = "dTime"
            let ts = "tScale"
            let deltaQ = "<q_cold/q_hot> on walls [%]"
            let courantC = "CFL"
            let divC = "p-residual error"
            let maxV = "max velocity [m/s]"
            let psiC = "Stream function ω: iterations"
            
            HStack (spacing: 10) {
                Text("Diagnostics progress")
                Button { /// кнопка отображения разных групп графиков
                    toggleDiagnostic.toggle()
                } label: {
                    Image(systemName: "arrow.right.arrow.left.circle.fill")
                }
            }
            .buttonStyle(.borderless)
            .font(iPadDevice ? .headline: .body)
            .padding(.top, 5)
            
            HStack {
                Text("\(dtC): \(solver.allowMelt ? solver.useEnthalpyMethod ? solver.adaptiveDt : solver.dTime : solver.dt, specifier: solver.allowMelt ? "%.1f" : "%.4f")s")
                if solver.timeScale != 1 {
                    Text("\(ts): \(solver.timeScale, specifier: "%.0f").")
                }
                Button {
                    solver.params.useAdaptiveRelax.toggle()
                    if !solver.params.useAdaptiveRelax {
                        solver.params.relaxationFactor = solver.relaxationFactor
                        solver.params.maxIterations = solver.maxIterations
                    }
                } label: {
                    HStack {
                        Text(pressureC)
                        Text("\(relaxC) \(solver.params.relaxationFactor, specifier: "%.2f"),  \(iterC) \(solver.iterations, specifier: "%04d").")
                    }.underline(false)
                }
                .keyboardShortcut("p", modifiers: [])
                .foregroundColor(solver.params.useAdaptiveRelax ? .green : .blue)
                
                Text("\(psiC) \(solver.iterationsPsi)")
                psiDivergence()
            }
            .font(.system(.caption, design: .monospaced))
            .padding(.bottom, 4)
            
            HStack(spacing: 20) {
                let frameHeight: CGFloat = /*iPadDevice ?*/ 150 /*: 80*/
                
                // Графики даны в зависимости от шага решения step・
                if toggleDiagnostic {
                    
                    // Приращение по времени при решении уравнений - dt
                    plot(values: solver.deltaTime, target: 0.01, color: .blue, yTitle: dtS, frameHeight)
                    
                    // Физический шаг плавления - dTime
                    plot(values: solver.timeStep, target: 10.0, color: .teal, yTitle: dtM, frameHeight)

                    // Средняя температура горячей стенки <T_hot>
                    plot(values: solver.T_avg_hotWall, target: 0.5*(solver.T_max + solver.T_melt), color: .red, yTitle: tempAvgWall, frameHeight)
                    
                    // Средне-объёмная температура расплава
                    plot(values: solver.T_avg_volume, target: 0.5*(solver.T_max + solver.T_melt), color: .orange, yTitle: tempAvgTotal, frameHeight)

                } else {
                    
                    // Параметр устойчивости Куранта
                    let targetStability = 0.5 * (solver.params.hiStabLimit - solver.params.lowStabLimit) + solver.params.lowStabLimit
                    plot(values: solver.stabilityParams, target: targetStability, color: .blue, yTitle: courantC, frameHeight)
                    
                    // Невязка давления (массовый член или дивиргенция)
                    plot(values: solver.pressureResiduals, target: solver.params.criticalError, color: .green, yTitle: divC, frameHeight)
                    
                    // Максимальная скорость
                    let maxVel = solver.maxVelocity.max() ?? 0
                    plot(values: solver.maxVelocity, target: maxVel/2, color: .red, yTitle: maxV, frameHeight)
                    
                    // КПД плавления или теплоотвода ( q (wall/front) )
                    plot(values: solver.q_residual, target: 100, color: .orange, yTitle: deltaQ, frameHeight)

                }
            }
            .font(/*iPadDevice ? */.caption/* : .footnote*/)
            .padding(.horizontal, 10)
            .padding(.bottom)
        }
        .background(Color.gray.opacity(0.35))
        .cornerRadius(10)
        .contentShape(Rectangle()) /// зона кликабельности
    }
}
