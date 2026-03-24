//
//  MomentumPtr.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 15.01.2026.
//

//MARK: - Solve momentum equation EPM + Parallel
//MARK: Уравнение импульса ∂u/∂t + (u・∇)u = -(1/ρ)∇p + ν∇²u + gβ(Τ - Τ0)

import Foundation
extension NavierStokesSolver {
    
    func solveMomentumEnthalpyParallel(_ uNew: inout [[Double]], _ vNew: inout [[Double]]) throws {

        let (gx, gy) = gVector(for: time)
        let T_ref = 0.5 * (T_max + T_cold)
        let localNX = nx
        let localNY = ny
        let localDT = dt
        let inv2h = 0.5 / h // Константа 1 / (2*h)
        let nx_max = nx - 1
        let ny_max = ny - 1

        // 1. Параллельный расчет конвекции и плавучести
        u.withUnsafeBufferPointer { uRows in
            v.withUnsafeBufferPointer { vRows in
                T.withUnsafeBufferPointer { tRows in
                    uNew.withUnsafeMutableBufferPointer { uNewRows in
                        vNew.withUnsafeMutableBufferPointer { vNewRows in
                            
                            // Получаем адреса начала строк для прямого доступа к памяти
                            let uPtr = (0..<localNY).map { uRows[$0].withUnsafeBufferPointer { $0.baseAddress! } }
                            let vPtr = (0..<localNY).map { vRows[$0].withUnsafeBufferPointer { $0.baseAddress! } }
                            let tPtr = (0..<localNY).map { tRows[$0].withUnsafeBufferPointer { $0.baseAddress! } }
                            let unPtr = (0..<localNY).map { uNewRows[$0].withUnsafeMutableBufferPointer { $0.baseAddress! } }
                            let vnPtr = (0..<localNY).map { vNewRows[$0].withUnsafeMutableBufferPointer { $0.baseAddress! } }

                            // Распараллеливаем внешний цикл по строкам 'j'
                            DispatchQueue.concurrentPerform(iterations: localNY - 2) { j_idx in
                                let j = j_idx + 1
                                
                                for i in 1..<(localNX - 1) {
                                    let uVal = uPtr[j][i]
                                    let vVal = vPtr[j][i]
                                    let tVal = tPtr[j][i]

                                    // --- ЛОГИКА КОНВЕКЦИИ U (инлайнировано из upwind2Enthalpy) ---
                                    let u_conv_x: Double
                                    if uVal > 0 { // X-направление
                                        let i_m2 = i > 1 ? i - 2 : 0
                                        u_conv_x = uVal * (3.0 * uPtr[j][i] - 4.0 * uPtr[j][i-1] + uPtr[j][i_m2]) * inv2h
                                    } else {
                                        let i_p2 = i < nx_max - 1 ? i + 2 : nx_max
                                        u_conv_x = uVal * (-3.0 * uPtr[j][i] + 4.0 * uPtr[j][i+1] - uPtr[j][i_p2]) * inv2h
                                    }
                                    let u_conv_y: Double
                                    if vVal > 0 { // Y-направление
                                        let j_m2 = j > 1 ? j - 2 : 0
                                        u_conv_y = vVal * (3.0 * uPtr[j][i] - 4.0 * uPtr[j-1][i] + uPtr[j_m2][i]) * inv2h
                                    } else {
                                        let j_p2 = j < ny_max - 1 ? j + 2 : ny_max
                                        u_conv_y = vVal * (-3.0 * uPtr[j][i] + 4.0 * uPtr[j+1][i] - uPtr[j_p2][i]) * inv2h
                                    }

                                    // --- ЛОГИКА КОНВЕКЦИИ V (инлайнировано) ---
                                    let v_conv_x: Double
                                    if uVal > 0 {
                                        let i_m2 = i > 1 ? i - 2 : 0
                                        v_conv_x = uVal * (3.0 * vPtr[j][i] - 4.0 * vPtr[j][i-1] + vPtr[j][i_m2]) * inv2h
                                    } else {
                                        let i_p2 = i < nx_max - 1 ? i + 2 : nx_max
                                        v_conv_x = uVal * (-3.0 * vPtr[j][i] + 4.0 * vPtr[j][i+1] - vPtr[j][i_p2]) * inv2h
                                    }
                                    let v_conv_y: Double
                                    if vVal > 0 {
                                        let j_m2 = j > 1 ? j - 2 : 0
                                        v_conv_y = vVal * (3.0 * vPtr[j][i] - 4.0 * vPtr[j-1][i] + vPtr[j_m2][i]) * inv2h
                                    } else {
                                        let j_p2 = j < ny_max - 1 ? j + 2 : ny_max
                                        v_conv_y = vVal * (-3.0 * vPtr[j][i] + 4.0 * vPtr[j+1][i] - vPtr[j_p2][i]) * inv2h
                                    }
                                    
                                    // Плавучесть (Boussinesq)
                                    let buoy_x = gx * beta(tVal) * (tVal - T_ref)
                                    let buoy_y = -gy * beta(tVal) * (tVal - T_ref)
                                    
                                    // Промежуточная скорость (запись в uNew/vNew)
                                    unPtr[j][i] = uVal + localDT * (-(u_conv_x + u_conv_y) + buoy_x)
                                    vnPtr[j][i] = vVal + localDT * (-(v_conv_x + v_conv_y) + buoy_y)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // 2. Диффузия
        diffuseParallel(quantity: &uNew, isMomentum: true)
        diffuseParallel(quantity: &vNew, isMomentum: true)
        // 3. Применяем граничные условия
        applyVelocityBoundaryConditions(&uNew, &vNew)
    }

}
