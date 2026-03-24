//
//  DiagnosticPlot.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 17.07.2025.
//

import SwiftUI
extension Visualizator {
    
    //MARK: - Диагностика хода решения
    @ViewBuilder
    var diagnostics: some View {
        if showDiagnostics { diagnosticsPlots.padding(.bottom, 10) }
    }
    
    //MARK: - Расходимость функции тока из уравнения Пуассона (ω)
    @ViewBuilder
    private func psiDivergence() -> some View {
        let divPsi = iPadDevice ? "погрешность" : "res"
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
        }
        if solver.isCalculatingStream { /// ProgressView
            Text("Расчет линий тока...").padding(.horizontal, 5)
                .background(RoundedRectangle(cornerRadius: 5).fill(.ultraThinMaterial))
        }
    }
    
    //MARK: - Графики диагностики
    var diagnosticsPlots: some View {
        VStack {
            let relaxC = iPadDevice ? "Давление: relax" : "relax "
            let dtC = "dt"
            let iterC = iPadDevice ? "iterations" : "iters"
            let tempAvgWall = iPadDevice ? "<T> на горячей стенке [ºC]" : "<T_hot>"
            let tempAvgTotal = iPadDevice ? "<T> жидкости [ºC]" : "T_avg"
            let dtS = iPadDevice ? "Шаг моделирования dt [s]" : "dt"
            let dtS2 = solver.allowMelt ? "Шаг плавления dTime [s]" : dtS
            let dtM = iPadDevice ? dtS2 : "dTime"
            let deltaQ = iPadDevice ? "<q_cold/q_hot> на стенках [%]" : "<q_c/q_h>"
            let courantC = iPadDevice ? "коэф. устойчивости" : "stab"
            let divC = iPadDevice ? "невязка давления" : "pRes"
            let maxV = iPadDevice ? "макс. скорость [m/s]" : "maxV"
            let psiC = iPadDevice ? "Функция тока ω: итераций" : "ω-iters"
            let divPsi = iPadDevice ? "погрешность" : "res"
            
            HStack (spacing: 10) {
                Text("Диагностика хода решения")
                Button { /// кнопка отображения разных групп графиков
                    toggleDiagnostic.toggle()
                } label: {
                    Image(systemName: "arrow.right.arrow.left.circle.fill")
                }
            }
            .buttonStyle(.borderless)
            .font(iPadDevice ? .headline: .caption)
            .padding(.top, 5)
            
            HStack {
                Text("\(dtC): \(solver.dt, specifier: "%.5f").  \(relaxC)  \(solver.params.relaxationFactor, specifier: "%.2f"),  \(iterC) \(solver.iterations). \(psiC): \(solver.iterationsPsi)")
                psiDivergence()
            }
            .font(iPadDevice ? .caption : Font.system(size: 8))
            .padding(.bottom, 2)
            
            HStack(spacing: iPadDevice ? 20 : 5) {
                let frameHeight: CGFloat = iPadDevice ? 150 : 80
                
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
            .font(iPadDevice ? .caption : .footnote)
            .padding(.horizontal, 10)
            .padding(.bottom)
        }
        .background(Color.gray.opacity(0.35))
        .cornerRadius(10)
        .contentShape(Rectangle()) /// зона кликабельности
    }
}
