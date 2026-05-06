//
//  InletOutLet.swift
//  FlowLab
//
//  Created by Алексей Езерский on 30.07.2026.
//
// MARK: - Determine Inlet-Outlet for convective flow

extension NavierStokesSolver {
    
    /// Определяет, находится ли конвективный поток в разрешенных границах на левой стенке
    @inline(__always)
    func inlet(_ jStart: Int, _ jEnd: Int, _ j: Int) -> Bool {
        return j >= jStart && j <= jEnd
    }
    /// Определяет, находится ли выходной поток по краям на левой стенке
    @inline(__always)
    func outlet(_ jStart: Int, _ jEnd: Int, _ j: Int) -> Bool {
        let jOut = (jEnd-jStart)/2 ///для выходного потока
        return params.leftSink && (j<=jOut || j>=ny-jOut)
    }

}
