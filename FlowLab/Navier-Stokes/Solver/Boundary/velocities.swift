//
//  Boundaries.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 18.07.2025.
//

//MARK: - Граничные условия для u, v

extension NavierStokesSolver {
    
    func applyVelocityBoundaryConditions(_ u: inout [Double], _ v: inout [Double]) {
        
        // Составляющие вектора скорости по х-координате
        for i in 0..<nx {
            u[idx(i,0)] = 0; u[idx(i,ny-1)] = 0;
            v[idx(i,0)] = 0; v[idx(i,ny-1)] = 0
        }
        
        // Составляющие вектора скорости по у-координате
        for j in 0..<ny {
            u[idx(0,j)] = 0; u[idx(nx-1,j)] = 0;
            v[idx(0,j)] = 0; v[idx(nx-1,j)] = 0
        }
        
        // Получение условий твердости (EPM)
        if useEnthalpyMethod {
            getSolidMask()
            
            // Условия прилипания (no slip conditions)
            for j in 0..<ny {
                let offset = j * nx
                for i in 0..<nx {
                    let idx = offset + i
                    if solidMask[idx] == 1 {
                        u[idx] = 0.0
                        v[idx] = 0.0
                    }
                }
            }
        }
    }

}
