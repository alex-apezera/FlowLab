//
//  solveStep.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 18.07.2025.
//
//import SwiftUI
import Foundation
extension NavierStokesSolver {
    
    fileprivate func solveΕquations() async throws {
        
        makeVelocitiesIsZero(&u, &v) /// при наличии выключателя
        
        // Решаем уравнения
        if useEnthalpyMethod { /// EPM
            var uNew = u; var vNew = v
            if !isFrozen {
                try solveMomentumEnthalpyParallel(&uNew, &vNew)
                try solvePressureEnthalpyParallel(uNew, vNew)
            }
            try solveEnergyEnthalpy() /// + параллельные вычисления, Stride
            try updatePhaseChange()
//            try correctionTempAndLF()
        } else {/// ALE
            if !isFrozen {
                try await solveMomentumEquations() /// Уравнение движения
                try await solvePressureEquation() /// Уравнение для давления с поправками скоростей
            }
            try await solveEnergyEquation() /// Уравнение энергии
        }
    }
    
    enum SolverError: Error {
        case divergenceDetected    /// Обнаружена расходимость (NaN или Inf)
        case pressureNotConverged  /// Метод давления не сошелся
        case temperatureOutOfBounds /// Температура вышла за физические пределы
    }
    
    /// УСПЕШНЫЙ ШАГ: попытка ускорения
    fileprivate func tryAcceleration() {
        stableStepCount += 1
        if stableStepCount >= accelerationThreshold {
            /// Плавно наращиваем dt на 5%, если все стабильно
            dt = min(dt * 1.05, 0.1) /// 0.1 — ваш предел макс. шага
            stableStepCount = 0
        }
    }
    
    /// ОТКАТ: Если ошибка или расходимость
    fileprivate func attemptRestoreState(_ attempts: inout Int) async {
        attempts += 1
        if let safeState = stateBuffer.first {
            restoreState(from: safeState) /// восстановление состояния
            stateBuffer.removeAll() /// очистка буфера
        }
        dt /= 5.0 /// аварийное уменьшение шага по времени
        stableStepCount = 0 /// Сброс режима ускорения при ошибке
        await updateStatus("⚠️ Откат на \(bufferLimit) шагов. Попытка \(attempts). dt = \(String(format: "%.2e",dt))")
    }
    
    fileprivate func detectDivergence(_ isStepStable: inout Bool, _ currentMaxV: inout Double) throws {
        // При заморозке скоростей - обнуляем V max и продолжаем расчет
        if isFrozen {currentMaxV = 0.0; isStepStable = true; return}
        
        // Проверка на расходимость  (аномальный рост V, Ra, t)
        currentMaxV = maxVelocityValue
        if currentMaxV.isNaN  || currentMaxV > 1e5 || Ra.isNaN || t > 1e8 {
            throw SolverError.divergenceDetected
        }
        
        isStepStable = true /// Если дошли сюда — шаг успешен
    }
    
    /// РЕШЕНИЕ: попытка решения уравнений
    func solveStep() async -> Bool {
        
        // Управление вычислительным шагом
        var isStepStable = false
        var attempts = 0
        let maxAttempts = 6 /// Количество попыток уменьшения dt внутри одного шага
        
        // Статистические параметры
        var heatFluxW = 0.0, heatFluxE = 0.0, heatDiff = 0.0
        var currentMaxV = 0.0, currentCourant = 0.0
 
        // Запоминание текущего состояния расчетов
        if stateBuffer.isEmpty { stateBuffer.append(backupState()) }
        if stateBuffer.count > bufferLimit { stateBuffer.removeFirst() }

        // Шаг решения с текущим dt
        while !isStepStable && attempts < maxAttempts {
            do {
                try await solveΕquations()
                try detectDivergence(&isStepStable, &currentMaxV)
                
            } catch {
                await attemptRestoreState(&attempts)
            }
        }
        
        if !isStepStable { await updateStatus("❌ Фатальная ошибка: не удалось стабилизировать решение.")
            return false // Прекращаем расчет
        }
        
        tryAcceleration()
        
        // ФИНАЛИЗАЦИЯ: расчет характеристик фронта плавления
        useEnthalpyMethod ?
        frontState(&heatFluxW, &heatFluxE, &heatDiff) :
        coldWallState(&heatFluxW, &heatFluxE, &heatDiff)
        
        // Стабилизация и расчет адаптивного шага симуляции dt
        applyStability(currentMaxV, &currentCourant)
        
        // Сбор статистики
        addToStatistics(heatFluxW, heatFluxE, heatDiff, currentMaxV, currentCourant)
        
        await MainActor.run { /// переход к следующему шагу расчетов
            t += dt; params.timeStep = dt;
            state.t = t; step += 1; state.step = step
        }
        return true
    }
}
