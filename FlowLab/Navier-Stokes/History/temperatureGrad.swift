//
//  temperatureGrad.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 20.02.2026.
//
extension HistoryFrame {
    // Вычисляемые свойства для изотерм и линий тока
    var temperatureGradient: [Double] {
        // Вычисление среднего градиента температуры внутри области
        var gradient = [Double](repeating: 0.0, count: temperature.count)
        let solver = NavierStokesSolver()
        let nx = solver.nx
        let ny = solver.ny
        for j in 1..<ny-1 {
            let jCell = j*nx
            let dy = solver.y[j+1] - solver.y[j-1]
            for i in 1..<nx-1 {
                let idx = jCell + i
                let dx = (solver.x[i+1] - solver.x[i-1]) * solver.rx[j]
                gradient[idx] = 0.5 * (
                    (temperature[idx+1] - temperature[idx-1]) / dx +
                    (temperature[idx+nx] - temperature[idx-nx]) / dy )
            }
        }
        return gradient
    }
}
