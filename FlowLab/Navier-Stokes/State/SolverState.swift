//
//  SolverState.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 14.11.2025.
//

// Вспомогательные структуры для копирования и восстановления состояния решения

struct SolverState {
    let t: Double
    let u, v, p, T, liquidFraction : [Double]
    let isStone: [UInt8]
    let rx: [Double]
    let dt: Double
}
//
//struct DisplayData {
//    var temperature: [[Double]] = []
//    var velocityX: [[Double]] = []
//    var velocityY: [[Double]] = []
//    var pressure: [[Double]] = []
//    var liquidFraction: [[Double]] = []
//    var time: Double = 0
//    
//    mutating func updateFromSolver(u: [[Double]], v: [[Double]], p: [[Double]], T: [[Double]], l_f: [[Double]], time: Double) {
//        // Копирование данных для визуализации
//        self.temperature = T
//        self.velocityX = u
//        self.velocityY = v
//        self.pressure = p
//        self.liquidFraction = l_f
//        self.time = time
//    }
//}
