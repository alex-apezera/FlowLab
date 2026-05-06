//
//  gVector.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 18.07.2025.
//
//MARK: - Gravity Vector and Angle

import Foundation
extension NavierStokesSolver {
    
    /// Вычисление вектора гравитации по времени (angle: [rad])
    func gVector(for t: Double) -> (gx: Double, gy: Double) {
        let angle = gravityInitialAngle + .pi/180 * rotationVelocity * t
            return (gMagnitude * sin(angle), -gMagnitude * cos(angle))
    }
    
    /// Угол вектора гравитации [°], degrees
    var gravityArrowAngle: Double {
        let (gx, gy)  = gVector(for: time)
        let angle = atan2(gy, gx) * 180 / .pi + 90
        return angle.truncatingRemainder(dividingBy: 360)
    }
    
}
