//
//  heatFluxOnColdWall.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 18.07.2025.
//
//MARK: - Graph of heat fluxes on the boundaries as a function of time

import SwiftUI
extension Visualizator {
    
    /// График зависимости тепловых потоков на границах от времени
    @ViewBuilder
    func heatFluxPlot(_ heatFluxE: [Double], _ heatFluxW: [Double], _ time: Double, _ timeFirst: Double) -> some View {
        
        let meltingTime = solver.allowMelt ? "Melting time " : "Simulation time [s] "
        let timeString = solver.allowMelt ? formattedTime(time) : String(format: "%.3f", time)

        GeometryReader { geometry in
            VStack {
                Text("Average heat fluxes on boundaries")
                .buttonStyle(.borderless)
                .font(iPadDevice ? .headline: .caption)
                .padding(.top, 5)
                Text("\(meltingTime): \(timeString)").font(iPadDevice ? .caption : Font.system(size: 8))

                HStack {
                    let frameHeight: CGFloat = iPadDevice ? geometry.size.height*0.85: geometry.size.height*0.75
                    plotForHeat(heatFluxW, heatFluxE, time, timeFirst, xTitle: "time",  yTitle:  "q = λ・dT/dx [W/m²]", frameHeight)
                }
                .font(iPadDevice ? .caption : .footnote)
                .padding(.bottom, 10)
            }
            .scaledToFill()
            .padding(.horizontal)
        }
    }
}
