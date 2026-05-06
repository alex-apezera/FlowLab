//
//  avgConv.swift
//  FlowLab
//
//  Created by Алексей Езерский on 01.08.2026.
//
// MARK: - Determine Inlet-Outlet average convective heat flux

extension NavierStokesSolver {
    
    /// Конвективный приток/отток тепла на левой стенке или горизонтальных границах
    func averageConvHeatFlux(_ T: Mutable, _ u: ReadOnly, _ v: ReadOnly, _ x:ReadOnly, _ y: ReadOnly, _ rxTop: Double, _ rxBot: Double) -> Double {
        let rho_Cp = rho * Cp * 0.5
        let zero = -T_cold
        var q_conv_X = 0.0
        var q_conv_Y = 0.0
        
        // Конвективный приток/отток тепла
        if params.useWind {
            for j in 1..<ny-1 { ///Left wall
                let baseY = rho_Cp * (y[j+1] + y[j-1])
                q_conv_Y += baseY * u[idx(0,j)] * (T[idx(0,j)] + zero)
            }
            if !params.leftSink {
                for i in 1..<nx-1 { /// Top & Bottom walls
                    let baseX = rho_Cp * (x[i-1] + x[i+1])
                    q_conv_X += baseX * rxBot * v[idx(i,0)] * (T[idx(i,0)] + zero)
                    q_conv_X -= baseX * rxTop * v[idx(i,ny-1)] * (T[idx(i,ny-1)] + zero)
                }
            }
        }
//        if params.useWind { print("q_conv_X: \(q_conv_X/Lx), q_conv_Y: \(q_conv_Y/Ly),  step: \(step)") }
        return q_conv_X/Lx + q_conv_Y/Ly
    }
}
