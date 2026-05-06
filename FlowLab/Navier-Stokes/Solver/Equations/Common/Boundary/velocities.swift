//
//  Boundaries.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 18.07.2025.
//

//MARK: - Граничные условия для u, v
import Foundation
extension NavierStokesSolver {
    /// Явные Граничные условия для u, v
    func applyVelocityBoundaryConditions(_ u: inout [Double], _ v: inout [Double]) {
        let velocityAngle = params.windAngle * .pi / 90.0 /// [radian]
        /// ptr
        u.withUnsafeMutableBufferPointer { u in
        v.withUnsafeMutableBufferPointer { v in
        solidMask.withUnsafeBufferPointer { solidMask in
        isStone.withUnsafeMutableBufferPointer { isStone in

            // Составляющие вектора скорости на горизонтальных границах
            for i in 0..<nx {
                if params.useWind && !params.leftSink { /// Neimann, free wall
                    u[idx(i,0)] = u[idx(i,1)]; u[idx(i,ny-1)] = u[idx(i,ny-2)]
                    v[idx(i,0)] = v[idx(i,1)]; v[idx(i,ny-1)] = v[idx(i,ny-2)]
                } else { /// Dirichlet, solid wall
                    u[idx(i,0)] = 0; u[idx(i,ny-1)] = 0
                    v[idx(i,0)] = 0; v[idx(i,ny-1)] = 0
                }
            }
            
            // Составляющие вектора скорости на вертикальных границах
            for j in 0..<ny {
                let row = j*nx, idxE = row + nx - 1
                
                /// Условия прилипания (W wall + E wall)
                u[row] = 0; u[idxE] = 0
                v[row] = 0; v[idxE] = 0
                
                /// W - wall: Условия вдува и стока поверх условий прилипания
                if params.useWind {
                    /// Параметры параболы (привязаны к индексу j)
                    let jStart = Int(params.y_start * Double(ny))
                    let jEnd = Int(params.y_end * Double(ny))
                    let jCenter = (jStart + jEnd) / 2 /// середина параболы
                    
                    // Проверяем, находится ли текущий j внутри диапазона
                    if inlet(jStart, jEnd, j) {
                        // Нормализованная координата от -1 до 1 внутри отрезка
                        let halfWidth = Double(jEnd - jStart) / 2.0
                        let eta = (Double(j) - Double(jCenter)) / halfWidth
                        
                        // Параболический профиль: 0 на краях, максимум в центре
                        let u_profile = params.windSpeed * (1.0 - eta * eta)
                        
                        // Компоненты скорости с учётом угла вдува
                        let u_inlet = u_profile * cos(velocityAngle)
                        let v_inlet = u_profile * sin(velocityAngle)
                        
                        // Входящий поток фиксируем в массивах
                        u[row] = u_inlet
                        v[row] = v_inlet
                        
                        // Выходящий поток - по краям левой границы
                    } else if outlet(jStart, jEnd, j) {
                        u[row] = u[row+1]
                        v[row] = v[row+1]
                    }
                }
            }
            
            if useEnthalpyMethod {
                getSolidMask() /// Получение условий твердости (EPM)
                
                // Условия прилипания (no slip conditions)
                for idx in 0..<nx*ny {
                    if solidMask[idx] == 1 { /// твёрдое тело
                        u[idx] = 0.0
                        v[idx] = 0.0
                    }
                }
            }
        }}}}///ptr
    }
}
