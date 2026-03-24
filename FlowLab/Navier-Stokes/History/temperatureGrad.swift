//
//  temperatureGrad.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 20.02.2026.
//
extension HistoryFrame {
    // Вычисляемые свойства для изотерм и линий тока
    var temperatureGradient: [[Double]] {
        // Вычисление среднего градиента температуры внутри области
        var gradient = Array(repeating: Array(repeating: 0.0, count: temperature[0].count), count: temperature.count)
        let solver = NavierStokesSolver()
        for j in 1..<temperature.count-1 {
            let dy = solver.y[j+1] - solver.y[j-1]
            for i in 1..<temperature[0].count-1 {
                let dx = (solver.x[i+1] - solver.x[i-1]) * solver.rx[j]
                gradient[j][i] = 0.5 * (
                    (temperature[j][i+1] - temperature[j][i-1]) / dx +
                    (temperature[j+1][i] - temperature[j-1][i]) / dy )
            }
        }
        return gradient
    }
}
