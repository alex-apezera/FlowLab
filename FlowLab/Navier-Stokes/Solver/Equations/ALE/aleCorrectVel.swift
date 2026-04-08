//
//  aleCorrectVel.swift
//  FlowLab
//
//  Created by Алексей Езерский on 26.04.2026.
//

extension NavierStokesSolver {
    @inline(__always)
    func aleCorrectVel(_ p: [Double], _ dt_rho: Double) {
        for j in 1..<(ny-1) {
            let row = j * nx
            for i in 1..<(nx-1) {
                let idx = i + row
                u[idx] -= dt_rho * derivativeX(p, j, i, idx)
                v[idx] -= dt_rho * derivativeY(p, j, i, idx)
            }
        }
    }
}
