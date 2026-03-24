//
//  initArrays.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 21.02.2026.
//

extension NavierStokesSolver {
    
    /// Исходное состояние массивов
    func initArrays() {
        u = Array(repeating: Array(repeating: 0.0, count: nx), count: ny)
        v = Array(repeating: Array(repeating: 0.0, count: nx), count: ny)
//        p = Array(repeating: Array(repeating: 0.0, count: nx), count: ny)
        p = [Double](repeating: 1.0, count: nx * ny)
        /// температура холодной стенки или твёрдой фазы
        T = Array(repeating: Array(repeating: T_cold, count: nx), count: ny)
        psi = Array(repeating: Array(repeating: 0.0, count: nx), count: ny)
        
        /// всё заполнено жидкой фазой
        liquidFraction = [Double](repeating: 1.0, count: nx * ny)
        isStone = [UInt8](repeating: 0, count: nx * ny)
        solidMask = [UInt8](repeating: 0, count: nx * ny)

        /// Исходное состояние вспомогательных массивов
        rx = [Double](repeating: 1.0, count: ny)
        V_melt = [Double](repeating: 0.0, count: ny)
        q_coldWall = []; q_hotWall = []; deltaTime = []; timeStep = []
        pressureResiduals = []; stabilityParams = []; maxVelocity = []
        q_residual = []; T_avg_hotWall = []; T_avg_volume = []
    }
    
}
