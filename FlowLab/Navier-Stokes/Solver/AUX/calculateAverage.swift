//
//  calculateAverage.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 25.02.2026.
//
extension NavierStokesSolver {
    
    /// Расчет средней величины по высоте
    func calculateAverageByHeight(value: [Double]) -> Double {
        var integral = 0.0
        // Интегрируем методом трапеций по всей длине y
        for j in 0..<ny-1 {
            let meanValue = 0.5 * (value[j] + value[j+1])
            integral += meanValue * (y[j+1] - y[j])
        }
        // Среднее значение = интеграл / общая длина
        return integral / Ly
    }
    
    /// Расчет средней температуры горячей стенки
    var averageTempHotwall: Double {
        
        var integral = 0.0
        // Интегрируем методом трапеций по всей длине y
        for j in 0..<ny-1 {
            let meanValue = 0.5 * (T[idx(0,j)] + T[idx(0,j+1)])
            integral += meanValue * (y[j+1] - y[j])
        }
        // Среднее значение = интеграл / общая длина
        return integral / Ly
    }
}
