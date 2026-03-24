//
//  idx.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 18.03.2026.
//
extension NavierStokesSolver {
    
    //MARK: - Вычисляемые индексы массивов полей (2D -> 1D)
    
    // [[Double]] -> [Double] : data[j][i] -> data[idx(i,j)]
    @inline(__always) func idx(_ x: Int, _ y: Int) -> Int { y * nx + x }
    
    /// Отступ по индексу j (y) -- альтарнатива использованию func idx
    /// // В больших циклах применяется оптимизация:
    /// Нижеследующие индексы отступов целесообразно вычислять в цикле по j:
    /// Пример:
    @inline(__always) func yCell(_ y: Int) -> Int { y * nx }
    
    /// Если используются соседние узлы по вертикали:
    @inline(__always) func yOffsets(_ y: Int) -> (yC: Int, yT: Int, yB: Int) {
        return ( yC: y * nx, yT: (y+1)*nx, yB: (y-1)*nx)
    }
    
    
//    for j in 0..<ny {
//        let jCell = yCell(j)
//        let jTop = yCell(j+1)
//        let jBot = yCell(j-1)
    // или
//        let (jCell, jTop, jBot) = yOffsets(j)
    // и далее
//        for i in 0..<nx {
//            let idx = jCell + i, idxT = jTop + i, idxB = jBot + i
    
//            // ТОГДА
//            data[j][i] -> data[idx]
//            data[j+1][i] -> data[idxT]
//            data[j-1][i] -> data[idxB]
//            data[j][i+1] -> data[idx+1]
//            data[j][i-1] -> data[idx-1]
//        }
//    }
}
