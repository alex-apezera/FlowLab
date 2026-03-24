//
//  heatFluxOnColdWall.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 18.07.2025.
//

import SwiftUI
extension Visualizator {
    
    //MARK: - График зависимости тепловых потоков на стенках от времени
    @ViewBuilder
    func heatFluxPlot(_ heatFluxE: [Double], _ heatFluxW: [Double], _ time: Double) -> some View {
        
        let meltingTime = solver.allowMelt ? "Время плавления " : "Время моделирования [s] "
        let timeString = solver.allowMelt ? formattedTime(time) : String(format: "%.3f", time)

        GeometryReader { geometry in
            VStack {
                Text("Средние значения тепловых потоков на поверхностях")
                .buttonStyle(.borderless)
                .font(iPadDevice ? .headline: .caption)
                .padding(.top, 5)
                Text("\(meltingTime): \(timeString)").font(iPadDevice ? .caption : Font.system(size: 8))

                HStack {
                    let frameHeight: CGFloat = iPadDevice ? geometry.size.height*0.85: geometry.size.height*0.75
                    plotForHeat(heatFluxW, heatFluxE, time, xTitle: "время",  yTitle:  "q = λ・dT/dx [W/m²]", frameHeight)
                        .frame(width: geometry.size.width * (iPadDevice ? 0.95 : 0.8))
                }
                .font(iPadDevice ? .caption : .footnote)
                .padding()
            }
            .scaledToFill()
            .padding(.horizontal)
        }
    }
}
