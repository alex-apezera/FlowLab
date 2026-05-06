//
//  applyExplicitConvection.swift
//  FlowLab
//
//  Created by Алексей Езерский on 23.05.2026.
//
//MARK: - Обособленный шаг явной конвекции, New scheme
/*
import Foundation
import Combine
extension NavierStokesSolver {
    
    ///Функция вычисляет перенос (Upwind 2-го порядка в жидкости, 1-го порядка у фронта) и возвращает промежуточное поле. Она применяется для Т, u и v одинаково (через параметр quantity)
    func applyExplicitConvection(quantity: [Double], isMomentum: Bool = false, isComponentV: Bool = false) -> [Double] {
        var intermediate = quantity // Копируем массив
        let h_inv = 1 / h
        let nx = self.nx, ny = self.ny
        let (gx, gy) = gVector(for: time)
        let T_ref = 0.5 * (T_max + T_cold)
        
        for j in 1..<ny-1 {
            let row = j * nx
            for i in 1..<(nx - 1) {
                let idx = row + i
                let f_current = liquidFraction[idx]
                
                // Если узел твердый, конвекции нет (скорости занулены)
                if f_current < 0.01 { continue }
                
                let idx_m2x = idx - 2
                let idx_m1x = idx - 1
                let idx_p1x = idx + 1
                let idx_p2x = idx + 2
                
                let idx_m2y = idx - 2 * nx
                let idx_m1y = idx - nx
                let idx_p1y = idx + nx
                let idx_p2y = idx + 2 * nx
                
                // --- КОНВЕКЦИЯ ПО X ---
                var convX = 0.0
                let isPureLiquidX = i > 1 && i < nx - 2 &&
                                    liquidFraction[idx_m2x] > 0.99 && liquidFraction[idx_m1x] > 0.99 &&
                                    liquidFraction[idx_p1x] > 0.99 && liquidFraction[idx_p2x] > 0.99
                
                if isPureLiquidX {
                    let u_w = 0.5 * (u[idx_m1x] + u[idx])
                    let u_e = 0.5 * (u[idx] + u[idx_p1x])
                    let Q_w = u_w > 0 ? (1.5 * quantity[idx_m1x] - 0.5 * quantity[idx_m2x]) : (1.5 * quantity[idx] - 0.5 * quantity[idx_p1x])
                    let Q_e = u_e > 0 ? (1.5 * quantity[idx] - 0.5 * quantity[idx_m1x]) : (1.5 * quantity[idx_p1x] - 0.5 * quantity[idx_p2x])
                    convX = (u_e * Q_e - u_w * Q_w) * h_inv
                } else {
                    let u_w = u[idx_m1x]
                    let u_e = u[idx]
                    let Q_w = u_w > 0 ? quantity[idx_m1x] : quantity[idx]
                    let Q_e = u_e > 0 ? quantity[idx] : quantity[idx_p1x]
                    convX = (u_e * Q_e - u_w * Q_w) * h_inv
                }
                
                // --- КОНВЕКЦИЯ ПО Y ---
                var convY = 0.0
                let isPureLiquidY = j > 1 && j < ny - 2 && liquidFraction[idx_m2y] > 0.99 && liquidFraction[idx_m1y] > 0.99 && liquidFraction[idx_p1y] > 0.99 && liquidFraction[idx_p2y] > 0.99
                // Если мы находимся в предграничных узлах, вертикальный перенос равен нулю из-за стенки
                if j == 1 || j == ny - 2 {
                    convY = 0.0
                } else if isPureLiquidY {
                    let v_s = 0.5 * (v[idx_m1y] + v[idx])
                    let v_n = 0.5 * (v[idx] + v[idx_p1y])
                    let Q_s = v_s > 0 ? (1.5 * quantity[idx_m1y] - 0.5 * quantity[idx_m2y]) : (1.5 * quantity[idx] - 0.5 * quantity[idx_p1y])
                    let Q_n = v_n > 0 ? (1.5 * quantity[idx] - 0.5 * quantity[idx_m1y]) : (1.5 * quantity[idx_p1y] - 0.5 * quantity[idx_p2y])
                    convY = (v_n * Q_n - v_s * Q_s) * h_inv
                } else {
                    let v_s = v[idx_m1y]
                    let v_n = v[idx]
                    let Q_s = v_s > 0 ? quantity[idx_m1y] : quantity[idx]
                    let Q_n = v_n > 0 ? quantity[idx] : quantity[idx_p1y]
                    convY = (v_n * Q_n - v_s * Q_s) * h_inv
                }
                
                // Вычитаем явный конвективный перенос
                var q_new = quantity[idx] - dt * (convX + convY)
                
                // Выталкивающая сила Буссинеска c учетом количества фазы
                if isMomentum {
                    if isComponentV {
                        let boussinesqY = beta * (T[idx] - T_ref) * gy
                        q_new -= dt * boussinesqY * f_current
                    } else {
                        let boussinesqX = beta * (T[idx] - T_ref) * gx
                        q_new += dt * boussinesqX * f_current
                    }
                }
                intermediate[idx] = q_new  /// фиксация промежуточного свойства
            }
        }
        return intermediate
    }

}
*/
