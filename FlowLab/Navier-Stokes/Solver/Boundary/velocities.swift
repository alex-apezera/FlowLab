//
//  Boundaries.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 18.07.2025.
//

//MARK: - Граничные условия для u, v

extension NavierStokesSolver {
    
    func applyVelocityBoundaryConditions(_ u: inout [[Double]], _ v: inout [[Double]]) {
        
//        // Составляющие вектора скорости по х-координате
//        for i in 0..<nx {
//            u[0][i] = 0; u[ny-1][i] = 0; v[0][i] = 0; v[ny-1][i] = 0
//        }
//        
//        // Составляющие вектора скорости по у-координате
//        for j in 0..<ny {
//            u[j][0] = 0; u[j][nx-1] = 0; v[j][0] = 0; v[j][nx-1] = 0
//        }
        // Получение условий твердости
        getSolidMask()
        
        // Условия прилипания (no slip conditions)
        for j in 0..<ny {
            let offset = j * nx
            for i in 0..<nx {
                let idx = offset + i
                if solidMask[idx] == 1 {
                    u[j][i] = 0.0
                    v[j][i] = 0.0
                }
            }
        }

    }

}
