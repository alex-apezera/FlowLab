//
//  frontStateSnip.swift
//  FlowLab
//
//  Created by Алексей Езерский on 15.06.2026.
//

//MARK: - Характеристики на на стенках и фронте плавления (EPM)
/*
import Foundation
extension NavierStokesSolver {
    
    /// Вычисление характеристик и тепловых потоков на стенках и фронте плавления (EPM)
    func frontState(_ heatFluxW: inout Double, _ heatFluxE: inout Double, _ heatDiff: inout Double)  {
        
        // Solver parameters
        let dx = h, dy = h, dx_inv2 = 1 / (2*dx), dy_inv2 = 1 / (2*dy)
        let Tm = T_melt, lambda = lambda(Tm)
        let meltCoef = 1 / rho / latentHeat
//        let effectiveDt = adaptiveDtMelt * timeScale
//        let energyFactor = effectiveDt / (latentHeat * rho * h)
        
        // Aux parameters
        var totalQ = 0.0, totalQ_hot = 0.0,  totalQ_cold = 0.0
        var counterY = 0, totalArea = 0.0
        var q_local = 0.0, v_normal = 0.0
        var maxV_interface = 0.0 /// Максимальная скорость фронта [m/s]
 
        T.withUnsafeBufferPointer { T in
        liquidFraction.withUnsafeBufferPointer { lf in
         
            
            
        // Проход по внутренним узлам
        for j in 1..<ny-1 {
            let row = j*nx
            
            // Определение удельных тепловых потоков на стенках
            let lambda_hot = self.lambda(T[idx(1,j)])/// [W/m•K]
            let lambda_cold = self.lambda(T[idx(nx-1,j)])
            let dTdx_hot = frontDerivative(T[idx(0,j)], T[idx(1,j)], T[idx(2,j)], dx_inv2)
            let dTdx_cold = frontDerivative(T[idx(nx-1,j)], T[idx(nx-2,j)], T[idx(nx-3,j)], dx_inv2)
                        
            let q_local_hot = abs(lambda_hot * dTdx_hot)/// [W/m²]
            let q_local_cold = abs(lambda_cold * dTdx_cold)/// [W/m²]
            
            totalQ_hot += q_local_hot
            totalQ_cold += q_local_cold
            counterY += 1

            // Характеристики фронта плавления (+ включения внутри полости)
            for i in 1..<nx-1 {
                let idx = row + i
                if isInterface(idx, lf) {
                    /// Градиент fl для нормали
                    let dfdx = (lf[idx+1] - lf[idx-1]) * dx_inv2
                    let dfdy = (lf[idx+nx] - lf[idx-nx]) * dy_inv2
                    let mag = sqrt(dfdx*dfdx + dfdy*dfdy) + tiny
                    
                    let nx_u = dfdx / mag ///[1]
                    let ny_u = dfdy / mag ///[1]
                    
                    /// Тепловой поток (2-й порядок по нормали к Tm)
                    /// Определяем направление "вглубь" жидкой фазы для градиента
                    let i_off = nx_u > 0 ? 1 : (nx_u < 0 ? -1 : 0)
                    let j_off = ny_u > 0 ? 1 : (ny_u < 0 ? -1 : 0)
                    
                    let dTdx = frontDerivative(Tm, T[idx], T[self.idx(i-i_off,j)], dx_inv2)
                    let dTdy = frontDerivative(Tm, T[idx], T[self.idx(i,j-j_off)], dy_inv2)
                    
                    q_local = lambda * abs(dTdx * nx_u + dTdy * ny_u)
                    let area_local = mag * dx * dy
                    
                    totalQ += q_local * area_local
                    totalArea += area_local
                    
                    /// Локальная скорость перемещения фронта (из условия Стефана)
                    // v_n = q / (L * rho)
                    v_normal = q_local * meltCoef
                    maxV_interface = max(maxV_interface, v_normal)
                }
            }
        }
        }}

        
        updateMeltWidth()///Вычисление  rx avg  [1] и  V melt avg [%/h]

        /// Вычисление адаптивного шага (CFL для плавления) для расчета фазы
        /// Шаг плавления не должен позволять фронту пройти более 0.5 ячейки
        let adaptiveDt = V_melt_avg > 1e-8 ? (0.5 * min(dx, dy)) / V_melt_avg : 1.0 /// [s] используется в updatePhase()
        adaptiveDtMelt = min(adaptiveDt /** timeScale*/, timeScale)/// ограничение

        // Данные для статистики

        /// Усреднение по высоте
        let qAvg_hot = totalQ_hot / Double(counterY)
        let qAvg_cold = totalQ_cold / Double(counterY)
//        let qAvg = totalArea > 0 ? totalQ / totalArea : 0.0
        heatFluxW = qAvg_hot /// левая стенка [W/m²]
//        heatFluxE = allowMelt ? qAvg : qAvg_cold /// граница плавления/правая стенка [W/m²]
                
        /// Получение  теплового потока на фронте плавления из формулы Стефана [W/m²]
        let q_front = V_melt_avg / meltCoef
        heatFluxE = max(heatFluxE, q_front)
        
        /// КПД плавления <qCold>/<qHot> [%]
        heatDiff = updateHeatDiff(heatFluxW, heatFluxE)
        print("--- БАЛАНС (time: \(formattedTime(time)), dt= \(dt), Шаг вычислений: \(step)) ---")
        print("q_front: \(q_front), adaptiveDt: \(adaptiveDt), q_avg_hot: \(qAvg_hot), q_avg_cold: \(qAvg_cold)")
    }
    
    /// Определение границы (фронта) плавления по координатам j, i
    @inline(__always)
    private func isInterface(_ idx: Int, _ lf: Pointer) -> Bool {
        let val = lf[idx]
        if val > 0.001 && val < 0.999 { return true }
        /// Проверка соседей на резкий переход (актуально для чистых веществ)
        if (val > 0.5 && (lf[idx+1] < 0.5 || lf[idx+nx] < 0.5 || lf[idx-1] < 0.5 || lf[idx-nx] < 0.5)) { return true }
        return false
    }

}
*/
