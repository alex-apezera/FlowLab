//
//  makeVFreeze.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 12.02.2026.
//

extension NavierStokesSolver {
    // Функция экстренной остановки скоростей
    func makeVelocitiesIsZero(_ u: inout [Double], _ v: inout [Double]) {
        if isFrozen {
            // Мгновенно обнуляем импульс во всей области
            freezeVelocities(&u, &v)
            if step % 10 == 0 { Task {await updateStatus("❄️ СКОРОСТИ ЗАМОРОЖЕНЫ") }
            } else { print("[Step: \(step)] ❄️ СКОРОСТИ ЗАМОРОЖЕНЫ") }
        }
    }
    
    private func freezeVelocities(_ u: inout [Double], _ v: inout [Double]) {
        for r in 0..<ny {
            let rCell = r*nx
            for c in 0..<nx {
                let idx =  rCell+c
                u[idx] = 0; v[idx] = 0
                p[idx] = 0
            }
        }
    }

}
