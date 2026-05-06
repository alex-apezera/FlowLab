//
//  averageByHeigt.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 25.02.2026.
//
//MARK: - Calculating the average value by height

extension NavierStokesSolver {
    
    /// Расчет средней величины по высоте
    func calculateAverageByHeight(value: [Double]) -> Double {
        
        var integral = 0.0
        value.withUnsafeBufferPointer { property in
        self.y.withUnsafeBufferPointer { y in
        
        // Интегрируем методом трапеций по всей длине y
        for j in 0..<ny-1 {
            let meanValue = 0.5 * (property[j] + property[j+1])
            integral += meanValue * (y[j+1] - y[j])
        }
        }}///ptr
        // Среднее значение = сумма значений / общая длина
        return integral / Ly
        
    }
    
    /// Расчет средней температуры горячей стенки
    var averageTempHotwall: Double {
        
        var integral = 0.0
        self.T.withUnsafeBufferPointer { T in
        self.y.withUnsafeBufferPointer { y in
        
        // Интегрируем методом трапеций по всей длине y
        for j in 0..<ny-1 {
            let row = j*nx
            let meanValue = 0.5 * (T[row] + T[row+nx])
            integral += meanValue * (y[j+1] - y[j])
        }
        }}///ptr
        // Среднее значение = интеграл / общая длина
        return integral / Ly
    }
}
