//
//  AxisView.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 16.07.2025.
//

import SwiftUI

struct AxisXLabelsView: View {
    let x: [Double]
    let minTemp: Double
    let maxTemp: Double
    let size: CGSize
    let divider = iPadDevice ? 6 : 4
    let Lx = NavierStokesSolver().Lx
    
    var body: some View {
        VStack {
                // Подписи оси X (+ засечки)
                HStack {
                    GeometryReader { geometry in
                        let width = geometry.size.width
                        let height = geometry.size.height
                        let stepWidth = width / CGFloat(x.count)
                        ForEach(0..<divider, id: \.self) { i in
                            let step = x.count * i / (divider - 1)
                            let xPos = CGFloat(step) * stepWidth
                            
                            Path { path in
                                path.move(to: CGPoint(x: xPos, y: height))
                                path.addLine(to: CGPoint(x: xPos, y: height + 4))
                            }
                            .stroke(lineWidth: 1)
                            let coordX = Double(step)/Double(x.count)*Lx
//                            Text("\(step)")
                            Text("\(Int(coordX*1000))")
                                .position(x: xPos, y: height + 10)
                        }
//                        Text("№ ячейки")
                        Text("X [mm]")
                            .position(x: width / 2, y: height + 10)
                    }
                    
                }
                .font(.system(size: 10))
                .padding(.top, 1)
        }
        .frame(width: size.width, height: size.height)
    }
}
