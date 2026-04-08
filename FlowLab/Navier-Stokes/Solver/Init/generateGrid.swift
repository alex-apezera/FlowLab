//
//  generateGrid.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 18.07.2025.
//

import Foundation
extension NavierStokesSolver {
    
    // Генерация координат и величины шагов сетки, с использованием asinh()
    func generateGrid() {
        
        //Проверка корректности коэффициентов растяжения
        if stretch_x < 0 { params.stretch_x = 0 }
        else if stretch_x > 3 { params.stretch_x = 3 }
        if stretch_y < 0 { params.stretch_y = 0 }
        else if stretch_y > 3 { params.stretch_y = 3 }
        
        // Генерация координат по x
        x = [Double](repeating: 0, count: nx)
        if nx > 1 {
            for i in 0..<nx {
                let xi = Double(i) / Double(nx-1)
                if stretch_x == 0 {
                    x[i] = Lx * xi // Равномерная сетка
                } else {
                    x[i] = Lx * (0.5 + asinh(2 * stretch_x * (xi - 0.5)) / (2 * asinh(stretch_x)))
                }
            }
        } else { x[0] = 0 }
                
        // Генерация координат по y
        y = [Double](repeating: 0, count: ny)
        if ny > 1 {
            for j in 0..<ny {
                let eta = Double(j) / Double(ny-1)
                if stretch_y == 0 {
                    y[j] = Ly * eta // Равномерная сетка
                } else {
                    y[j] = Ly * (0.5 + asinh(2 * stretch_y * (eta - 0.5)) / (2 * asinh(stretch_y)))
                }
            }
        } else { y[0] = 0 }
        
        // Вычисление шагов dx, dy (массив меньше на один элемент)
        dx = [Double](repeating: 0, count: nx-1)
        dx = (0..<nx-1).map { x[$0+1] - x[$0] }
        dy = [Double](repeating: 0, count: ny-1)
        dy = (0..<ny-1).map { y[$0+1] - y[$0] }
    }
}
