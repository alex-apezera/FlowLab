//
//  applyPressureBoundaryConditions.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 14.01.2026.
//
//MARK: - Boundary conditions For Pressure

extension NavierStokesSolver {
        
    /// Условия Неймана (dp/dn = 0) на  твердых стенках
    func applyPressureBoundaryConditions(_ pBuffer: inout [Double]) {
        for j in 0..<ny {
            pBuffer[idx(0,j)] = pBuffer[idx(1,j)]
            pBuffer[idx(nx-1,j)] = pBuffer[idx(nx-2,j)]
        }
        for i in 0..<nx {
            pBuffer[idx(i,0)] = pBuffer[idx(i,1)]
            pBuffer[idx(i,ny-1)] = pBuffer[idx(i,ny-2)]
        }
    }
/*
    /// Условия Неймана (dp/dn = 0) для твердых стенках для указателей
    func applyPressureBoundaryConditionsInline(rowPointers: UnsafeMutableBufferPointer<Double>, nx: Int, ny: Int) {
        for j in 0..<ny {
            rowPointers[idx(0,j)] = rowPointers[idx(1,j)] /// Лево
            rowPointers[idx(nx-1,j)] = rowPointers[idx(nx-2,j)] /// Право
        }
        for i in 0..<nx {
            rowPointers[idx(i,0)] = rowPointers[idx(i,1)] /// Низ
            rowPointers[idx(i,ny-1)] = rowPointers[idx(i,ny-2)] /// Верх
        }
    }
*/
}
