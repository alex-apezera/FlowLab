//
//  idx.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 18.03.2026.
//
//MARK: - Computed indices of field arrays (2D -> 1D)

extension NavierStokesSolver {
    
    // [[Double]] -> [Double] : data[j][i] -> data[idx(i,j)]
    /// Универсальная функция вычисления индекса элемента
    @inline(__always) func idx(_ x: Int, _ y: Int) -> Int { y * nx + x }
    
    /// Отступ по индексу j (y) -- альтарнатива использованию func idx
    /// В больших циклах применяется оптимизация:
    @inline(__always)
    func yRow(_ y: Int) -> Int { y * nx } /// Выполняется в цикле по j
    
    /// Если используются соседние узлы по вертикали:
    @inline(__always) func yOffsets(_ y: Int) -> (yC: Int, yT: Int, yB: Int) {
        return ( yC: y * nx, yT: (y+1)*nx, yB: (y-1)*nx) /// Выполняется в цикле по j
    }
    
// (Examples) ПРИМЕРЫ ИСПОЛЬЗОВАНИЯ
    
//    for j in 0..<ny {
//        let jRow = yRow(j)
//        let jTop = yRow(j+1)
//        let jBot = yRow(j-1)
    
    // ИЛИ
    
//        let (jRow, jTop, jBot) = yOffsets(j)
    
    // И ДАЛЕЕ
    
//        for i in 0..<nx {
//            let idx = jRow + i
//            let idxT = jTop + i, idxB = jBot + i
//            let idxR = idx + 1, idxL = idx - 1
    
    // ТОГДА
    
//            data[j][i] -> data[idx]
//            data[j+1][i] -> data[idxT]
//            data[j-1][i] -> data[idxB]
//            data[j][i+1] -> data[idx+1]
//            data[j][i-1] -> data[idx-1]
//        }
//    }
}
