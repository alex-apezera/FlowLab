//
//  applyStability.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 06.11.2025.
//
//MARK: - Управление свойствами отслеживания хода решения

extension NavierStokesSolver {
    
    func applyStability(_ maxVelocityValue: Double, _ currentCourant: inout Double) {
        
        // 1. Вычисляем текущее число Куранта
        let minCellSize = min(dx[0] * (rx.min() ?? 1), dy[0])
        currentCourant = dt * maxVelocityValue / minCellSize
        
        if useHybridScheme {
            
            // Схема 2 порядка - учитывается конвекция и диффузия
            /// 2. Вычисляем "Теоретически идеальный dt" (Target DT)
            /// Мы хотим, чтобы Курант был где-то посередине между вашими лимитами
            let targetCourant = (params.hiStabLimit + params.lowStabLimit) / 2.0
            var targetDt = targetCourant * minCellSize / (maxVelocityValue + 1e-8)
            
            /// Добавляем ограничение по диффузии (вязкости/температуропроводности)
            /// dt_diff = d_f * dx^2 / nu
            let diffusionLimit = d_Factor * minCellSize * minCellSize / max(nu, alpha)
            targetDt = min(targetDt, diffusionLimit)
            
            /// 3. Мягкая адаптация (Гибридный шаг)
            if currentCourant > params.hiStabLimit {
                /// Если вылетели за предел - тормозим агрессивно (3%)
                dt *= 0.97
            } else if currentCourant < params.lowStabLimit {
                /// Если есть запас - ускоряемся, но не выше targetDt
                /// Вместо фиксированных 2% можно использовать "умный" шаг:
                let growthFactor = 1.02
                if dt * growthFactor < targetDt {
                    dt *= growthFactor
                } else {
                    dt = targetDt /// Мы достигли оптимума
                }
            }
            
            if iterations >= params.maxIterations {
                dt *= 0.9 /// Экстренно снижаем шаг, если давление "буксует"
            }
            
            /// Ограничение по глобальным настройкам пользователя
            dt = min(dt, params.timeGap)
        } else {
            
            // Схема 1 порядка - учитывается только конвекция
            /// Корректировка шага по времени для устойчивости решения
            /// чем больше параметр, тем меньше должно быть прирашение по времени
            if currentCourant > params.hiStabLimit {
                dt *= 1 - 0.03
            } else if currentCourant < params.lowStabLimit {
                dt *= 1 + 0.02
            }
        }
    }

}
