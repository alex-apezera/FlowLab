//
//  TVDScheme.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 12.03.2026.
//

//import Foundation
struct TVDScheme {
    let h: Double
    
    // Ограничитель Min-Mod: возвращает 0 (Upwind) или значение для 2-го порядка
    @inline(__always)
    private func minMod(_ a: Double, _ b: Double) -> Double {
        if a * b <= 0 { return 0 }
        return abs(a) < abs(b) ? a : b
    }

    // Расчет конвективного члена (u * df/dx) для конкретного узла
    @inline(__always)
    func getAdvection(u: Double, fM2: Double, fM1: Double, f0: Double, fP1: Double, fP2: Double) -> Double {
        // Потоки на полуцелых гранях ячейки i+1/2 и i-1/2
        let fluxRight = calculateFlux(u: u, fLeft: fM1, fMid: f0, fRight: fP1, fFarRight: fP2)
        let fluxLeft  = calculateFlux(u: u, fLeft: fM2, fMid: fM1, fRight: f0, fFarRight: fP1)
        
        return (fluxRight - fluxLeft) / h
    }

    @inline(__always)
    private func calculateFlux(u: Double, fLeft: Double, fMid: Double, fRight: Double, fFarRight: Double) -> Double {
        if u > 0 {
            // Поток вправо: используем значения "слева" от грани
            let r = (fMid - fLeft) / (max(abs(fRight - fMid), 1e-10))
            let phi = max(0.0, min(1.0, r)) // Реализация Min-Mod
            return u * (fMid + 0.5 * phi * (fRight - fMid))
        } else {
            // Поток влево: используем значения "справа" от грани
            let r = (fFarRight - fRight) / (max(abs(fRight - fMid), 1e-10))
            let phi = max(0.0, min(1.0, r))
            return u * (fRight - 0.5 * phi * (fRight - fMid))
        }
    }
}
