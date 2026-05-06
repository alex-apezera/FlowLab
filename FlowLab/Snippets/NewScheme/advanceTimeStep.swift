//
//  advanceTimeStep.swift
//  FlowLab
//
//  Created by Алексей Езерский on 23.05.2026.
//

//MARK: - Шаг решения с текущим dt, New scheme
/*
import Foundation
import Combine
extension NavierStokesSolver {
    
    func advanceTimeStep() async throws {
        let nx = self.nx, ny = self.ny
        let previousLiquidFraction = self.liquidFraction
        let Cp_liq = Cp, Cp_sol = Cp_solid
        let L = latentHeat
        
        // ===============================================================
        // 1. ШАГ ГИДРОДИНАМИКИ: ПРЕДВАРИТЕЛЬНЫЕ СКОРОСТИ (TDMA прогонки)
        // ===============================================================
        var u_conv = applyExplicitConvection(quantity: u, isMomentum: true)
        var v_conv = applyExplicitConvection(quantity: v, isMomentum: true, isComponentV: true)
        
        // Получаем промежуточные скорости u* и v* (вязкость + плавучесть Буссинеска)
        epmDiffuseX(quantity: &u_conv, isMomentum: true, prevFL: previousLiquidFraction)
        epmDiffuseY(quantity: &v_conv, isMomentum: true, prevFL: previousLiquidFraction)
        
        // ===============================================================
        // 2. ВКЛЮЧЕНИЕ ВАШЕГО МЕТОДА: КОРРЕКЦИЯ ДАВЛЕНИЯ И НЕРАЗРЫВНОСТИ
        // ===============================================================
        // Передаем промежуточные u и v в ваш Гаусс-Зейдель.
        // Он решает уравнение Пуассона для давления (или поправок давления) и КОРРЕКТИРУЕТ массивы self.u и self.v, делая поток несжимаемым.
        
        epmPressure(u_conv, v_conv)
        
        // ===============================================================
        // 3. ПРИНУДИТЕЛЬНОЕ ЗАНУЛЕНИЕ СКОРОСТЕЙ В твердой фазе
        // ===============================================================
        // Выполняется строго ПОСЛЕ Гаусса-Зейделя, чтобы гарантировать,
        // что внутри твердого парафина паразитныe скорости от коррекции давления занулились.
        let dTm = dTm
        for idx in 0..<(nx * ny) {
            if previousLiquidFraction[idx] < dTm {
                u[idx] = 0.0
                v[idx] = 0.0
            }
        }
        
        // ===============================================================
        // 4. ШАГ ЭНЕРГИИ (ИТЕРАЦИИ ВОЛЛЕРА ДЛЯ ТЕМПЕРАТУРЫ)
        // ===============================================================
        // Теперь Т считается на основе уже скорректированных скоростей
        T = applyExplicitConvection(quantity: T)
        
        var k_iter = 0
        var residual = 1.0 /// погрешность расчета температуры
//        let omega = 0.2 // Коэффициент подсеточной релаксации фазы
        
        while residual > 1e-5 && k_iter < 8 {
            let old_T_iter = self.T
            
            // 2. Прогоняем ТЕКУЩЕЕ поле Т через неявную диффузию 
            epmDiffuseX(quantity: &T, prevFL: previousLiquidFraction)
            epmDiffuseY(quantity: &T, prevFL: previousLiquidFraction)
            
//            applyTemperatureBoundaryConditions(&T)
 
            var max_diff = 0.0
            for idx in 0..<(nx * ny) {
                
                // Граничные условия жестко сидят в матрице, внутренний цикл считает только объем
                let i = idx % nx
                let j = idx / nx
                if i==0 || i == nx-1 || j == 0 || j == ny-1 { continue }
                
                let f_iter = liquidFraction[idx]

                // Расчеты ведутся только в переходной зоне, где fl < 1
                guard f_iter < 1-dTm else { continue }
  
                let T = T[idx]
                let fl_previous_step = max(0, previousLiquidFraction[idx])

                let Cp_eff = f_iter * Cp_liq + (1.0 - f_iter) * Cp_sol
                // Коррекция фазового перехода
                let delta_fl = /*omega **/ (Cp_eff / L) * (T - T_melt)
                var fl_new = f_iter + delta_fl
                // Жесткий контроль: только плавление в рамках шага
                fl_new = max(fl_previous_step, min(1.0, fl_new))
                
                let T_final = T - (L / Cp_eff) * (fl_new - f_iter)
                
                // Проверка на NaN
                if T_final.isNaN || fl_new.isNaN {
                    continue
                }
                self.T[idx] = T_final
                liquidFraction[idx] = fl_new
                
                let diff = abs(T_final - old_T_iter[idx])
                if diff > max_diff { max_diff = diff }
            }
            residual = max_diff
            k_iter += 1
        }
        print("k_iter: \(k_iter)")
//        calculateEnergyBalance()
  
    }
}
*/
