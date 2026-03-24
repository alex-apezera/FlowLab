//
//  makeVFreeze.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 12.02.2026.
//

extension NavierStokesSolver {
    // Функция экстренной остановки скоростей
    func makeVelocitiesIsZero(_ u: inout [[Double]], _ v: inout [[Double]]) {
        if isFrozen {
            // Мгновенно обнуляем импульс во всей области
            freezeVelocities(&u, &v)
            Task { await updateStatus("❄️ СКОРОСТИ ЗАМОРОЖЕНЫ") }
        }
    }
    
    private func freezeVelocities(_ u: inout [[Double]], _ v: inout [[Double]]) {
        for r in 0..<ny {
            for c in 0..<nx {
                u[r][c] = 0; v[r][c] = 0
                p[idx(c,r)] = 0
            }
        }
    }

}
