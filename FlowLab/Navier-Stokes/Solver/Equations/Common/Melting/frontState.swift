//
//  frontState.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 16.02.2026.
//
//MARK: - Calculation of characteristics at vertical cavity boundaries (EPM)

extension NavierStokesSolver {
    
    /// Вычисление характеристик и тепловых потоков на стенках и фронте плавления (EPM)
    func frontState(_ heatFluxW: inout Double, _ heatFluxE: inout Double, _ heatDiff: inout Double)  {
        
        // Solver parameters
        let dx = h, inv_dx = 1/2/dx
        let meltCoef = rho_solid * latentHeat
        var q_conv = 0.0

        // Aux parameters
        var totalQ_hot = 0.0,  totalQ_cold = 0.0
        var counterY = 0
 
        // Пинним массивы для прямого обращения к памяти
        T.withUnsafeMutableBufferPointer { T in
        liquidFraction.withUnsafeMutableBufferPointer { fl in
        u.withUnsafeBufferPointer { u in
        v.withUnsafeBufferPointer { v in
        x.withUnsafeBufferPointer { x in
        y.withUnsafeBufferPointer { y in
        
        // Обновление пористой среды (фазы) и температуры
        updatePhase(T, fl)
        
        // Проход по узлам на на вертикальных стенках
        for j in 1..<ny-1 {
            let row = j*nx, idxW = row, idxE = row+nx-1
            
            /// Теплопроводность [W/m•K] и Градиенты температуры на стенках
            let lambda_hot = self.lambda(T[idxW+1])
            let lambda_cold = self.lambda(T[idxE-1])
            let dTdx_hot = frontDerivative(T[idxW], T[idxW+1], T[idxW+2], inv_dx)
            let dTdx_cold = frontDerivative(T[idxE], T[idxE-1], T[idxE-2], inv_dx)

            // Определение удельных тепловых потоков [W/m²]
            let q_local_hot = abs(lambda_hot * dTdx_hot)
            let q_local_cold = abs(lambda_cold * dTdx_cold)
            
            totalQ_hot += q_local_hot
            totalQ_cold += q_local_cold
            counterY += 1
            
        }
        
        // Вычисление  rx avg  [1] и  V melt avg [%/h]
        updateMeltWidth()
        
        /// Вычисление адаптивного шага (CFL для плавления) для расчета фазы [s]
        /// Шаг плавления не должен позволять фронту пройти более 0.5 ячейки
        adaptiveDt = V_melt_avg > 1e-8 ? 0.5 * dx / V_melt_avg : 100.0
        /// adaptiveDtMelt используется в updatePhase()
        adaptiveDtMelt = min(adaptiveDt * timeScale, 600.0)/// ограничение сверху
            
        // Конвективный приток/отток тепла
        q_conv = averageConvHeatFlux(T, u, v, x, y, 1.0, 1.0)

        /// Усреднение по высоте
        let qAvg_hot = abs(totalQ_hot) / Double(counterY) + q_conv
        let qAvg_cold = abs(totalQ_cold) / Double(counterY)
 
        /// Получение  теплового потока на фронте плавления из формулы Стефана [W/m²]
        let q_front = max(0, V_melt_avg * meltCoef)
                
        //  Тепловые потоки на левой и правой границе [W/m²]
        heatFluxW = qAvg_hot
        heatFluxE = allowMelt ? q_front + qAvg_cold : qAvg_cold
                        
        // КПД плавления <qCold>/<qHot> [%]
        heatDiff = updateHeatDiff(heatFluxW, heatFluxE)
        
    }
    }}}}}}///ptr
}
