//
//  EnergyEPM.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 12.01.2026.
//
//MARK: - Solve energy equation (LUD)
// Уравнение энергии: ∂T/∂t + (u·∇)T = α∇²T
import Foundation
extension NavierStokesSolver {
    
    // Метод EPM, работает на равномерной, квадратной сетке
    /// Применено Пиннинг и Страйдинг
    func solveEnergyEnthalpy() throws {
        var TNew = T
        // Создаем копию для чтения
        let T_old = T
        // Кэш констант
        let localNX = nx
        let localNY = ny
        let workerCount = ProcessInfo.processInfo.activeProcessorCount
        let chunkSize = (localNY - 2) / workerCount

        // Получаем прямой доступ к памяти массива TNew
        TNew.withUnsafeMutableBufferPointer { buffer in
            DispatchQueue.concurrentPerform(iterations: workerCount) { index in
                let startJ = 1 + index * chunkSize
                let endJ = (index == workerCount - 1) ? (localNY - 1) : (startJ + chunkSize)
                
                for j in startJ..<endJ {
                    for i in 1..<localNX - 1 {
                        // Используем T_old для чтения, чтобы избежать конфликтов
                        let T_conv =
                        upwind2Enthalpy(phi: T_old, velocity: u[j][i], j: j, i: i, axisX: true) +
                        upwind2Enthalpy(phi: T_old, velocity: v[j][i], j: j, i: i, axisX: false)
                        // Запись в TNew через прямое обращение
                        buffer[j][i] = T_old[j][i] - dt * T_conv
                    }
                }
            }
        }
        // Diffuse ∂T/∂t += α∇²T
        diffuseParallel(quantity: &TNew) /// ⬅︎  α(T) учтено внутри
        applyTemperatureBoundaryConditions(&TNew) /// явные граничные условия
        T = TNew
    }
}
