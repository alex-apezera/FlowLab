//
//  initArrays.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 21.02.2026.
//
//MARK: - Initial Massivs State

extension NavierStokesSolver {
    
    /// Исходное состояние массивов
    func initArrays() {
        // основные массивы двумерных полей
        u = [Double](repeating: 0.0, count: nx * ny)
        v = [Double](repeating: 0.0, count: nx * ny)
        p = [Double](repeating: 0.0, count: nx * ny)
        T = [Double](repeating: T_cold, count: nx * ny)
        psi = [Double](repeating: 0.0, count: nx * ny)

        // всё заполнено жидкой фазой (применяется при EPM)
        liquidFraction = [Double](repeating: 1.0, count: nx * ny)
        isStone = [UInt8](repeating: 0, count: nx * ny)
        solidMask = [UInt8](repeating: 0, count: nx * ny)

        // массивы объема расплава и скорости его приращения
        rx = [Double](repeating: 1.0, count: ny)
        V_melt = [Double](repeating: 0.0, count: ny)
        
        // массивы статистики
        q_coldWall = []; q_hotWall = []; deltaTime = []; timeStep = []
        pressureResiduals = []; stabilityParams = []; maxVelocity = []
        q_residual = []; T_avg_hotWall = []; T_avg_volume = []
        timePoints = []
        
    }
    
}
