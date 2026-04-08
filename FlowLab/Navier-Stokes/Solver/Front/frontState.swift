//
//  frontState.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 16.02.2026.
//

import Foundation
extension NavierStokesSolver {
    
    //MARK: - Характеристики фронта плавления (EPM) и тепловые потоки на стенках
    
    func frontState(_ heatFluxW: inout Double, _ heatFluxE: inout Double, _ heatDiff: inout Double)  {
        
        // Solver parameters
        let dx = h, dy = h, dx_inv2 = 1 / (2 * dx), dy_inv2 = 1 / (2 * dy)
        let Tm = T_melt, lambda = lambda(Tm)
        let L_latent = latentHeat, rho_liquid = rho
        
        // Aux parameters
        var totalQ = 0.0, totalQ_hot = 0.0,  totalQ_cold = 0.0
        var counterY = 0, totalArea = 0.0
        var maxV_interface = 0.0 /// Максимальная скорость фронта [m/s]
        
        // Проход по внутренним узлам
        for j in 1..<(ny - 1) {
            
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

            // Характеристики фронта плавления (EPM)
            for i in 1..<(nx - 1) {
                if isInterface(j, i, liquidFraction) {
                    /// Градиент fl для нормали
                    let dfdx = (liquidFraction[idx(i+1, j)] - liquidFraction[idx(i-1, j)]) * dx_inv2
                    let dfdy = (liquidFraction[idx(i, j+1)] - liquidFraction[idx(i, j-1)]) * dy_inv2
                    let mag = sqrt(dfdx*dfdx + dfdy*dfdy) + 1e-10
                    
                    let nx_u = dfdx / mag ///[1]
                    let ny_u = dfdy / mag ///[1]
                    
                    /// Тепловой поток (2-й порядок по нормали к Tm)
                    /// Определяем направление "вглубь" жидкой фазы для градиента
                    let i_off = nx_u > 0 ? 1 : (nx_u < 0 ? -1 : 0)
                    let j_off = ny_u > 0 ? 1 : (ny_u < 0 ? -1 : 0)
                    
                    let dTdx = frontDerivative(Tm, T[idx(i,j)], T[idx(i-i_off,j)], dx_inv2)
                    let dTdy = frontDerivative(Tm, T[idx(i,j)], T[idx(i,j-j_off)], dy_inv2)
                    
                    let q_local = lambda * abs(dTdx * nx_u + dTdy * ny_u)
                    let area_local = mag * dx * dy
                    
                    totalQ += q_local * area_local
                    totalArea += area_local
                    
                    /// Локальная скорость перемещения фронта (из условия Стефана)
                    // v_n = q / (L * rho)
                    let v_normal = q_local / (L_latent * rho_liquid)
                    maxV_interface = max(maxV_interface, v_normal)
                }
            }
        }
        // Усреднение по высоте
        let qAvg_hot = totalQ_hot / Double(counterY)
        let qAvg_cold = totalQ_cold / Double(counterY)
        let qAvg = totalArea > 0 ? totalQ / totalArea : 0.0 /// [W/m²]
  
        /// Вычисление адаптивного шага (CFL для плавления) для расчета фазы
        /// Шаг плавления не должен позволять фронту пройти более 0.5 ячейки
        let adaptiveDt = maxV_interface > 1e-8 ? (0.5 * min(dx, dy)) / maxV_interface : 1.0 /// [s] используется в updatePhaseChange()
        adaptiveDtMelt = min(adaptiveDt * timeScale, 100.0)/// ограничение "сверху"

        /// Вычисление средних величин объёма расплава и его приращения
        if allowMelt { updateMeltWidth(method: useEnthalpyMethod) }
        
        /// Средние тепловые потоки
        switch heatingType {
        case .temperature: heatFluxW = qAvg_hot
        case .heatFlux: heatFluxW = qAvg_hot /*heatingValue*/ }
        heatFluxE = allowMelt ? qAvg : qAvg_cold
        
        /// КПД плавления <qCold>/<qHot> [%]
        let q_diff = abs(heatFluxE / heatFluxW)*100
        heatDiff = q_diff

    }
    
    private func isInterface(_ j: Int, _ i: Int, _ lf: [Double]) -> Bool {
        let val = lf[idx(i, j)]
        if val > 0.001 && val < 0.999 { return true }
        /// Проверка соседей на резкий переход (актуально для чистых веществ)
        if (val > 0.5 && (lf[idx(i+1, j)] < 0.5 || lf[idx(i, j+1)] < 0.5 || lf[idx(i-1, j)] < 0.5 || lf[idx(i, j-1)] < 0.5)) { return true }
        return false
    }

}

