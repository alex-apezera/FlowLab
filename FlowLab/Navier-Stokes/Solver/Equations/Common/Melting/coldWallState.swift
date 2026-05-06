//
//  coldWallState.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 21.07.2025.
//
//MARK: - Calculation of characteristics at vertical cavity boundaries (ALE)

extension NavierStokesSolver {
    
    /// Вычисление характеристик на вертикальных границах полости (ALE)
    func coldWallState(_ heatFluxW: inout Double, _ heatFluxE: inout Double, _ heatDiff: inout Double) {
        
        var qE = [Double](repeating: 0, count: ny)
        var qW = [Double](repeating: 0, count: ny)
        
        let meltCoef = timeScale / rho_solid / latentHeat
        let dtdx = dt / dx[0]
        let dx0 = dx[0], dx1 = dx[1]///шаги сетки около границ с учетом симметрии
        var q_conv = 0.0
        ///ptr
        T.withUnsafeMutableBufferPointer { T in
        u.withUnsafeBufferPointer { u in
        v.withUnsafeBufferPointer { v in
        x.withUnsafeBufferPointer { x in
        y.withUnsafeBufferPointer { y in
        qE.withUnsafeMutableBufferPointer { qE in
        qW.withUnsafeMutableBufferPointer { qW in
        rx.withUnsafeMutableBufferPointer { rx in
        V_melt.withUnsafeMutableBufferPointer { V_melt in
        
        for j in 1..<ny-1 {
            let row = j*nx, idxW = row, idxE = row+nx-1
            let rxJ = rx[j], dx_rxJ = 0.5/dx0/rxJ
            
            /// Теплопроводность [W/m•K] и Градиенты температуры на стенках
            let lambda_hot = self.lambda(T[idxW+1])
            let lambda_cold = self.lambda(T[idxE-1])
            var dTdx_cold: Double = 0, dTdx_hot: Double = 0
            if stretch_x == 0 { ///равномерная сетка
                dTdx_hot = frontDerivative(T[idxW], T[idxW+1], T[idxW+2], dx_rxJ)
                dTdx_cold = frontDerivative(T[idxE], T[idxE-1], T[idxE-2], dx_rxJ)
            } else { /// неравномерная сетка
                dTdx_cold = wallDerivative(T[idxE], T[idxE-1], T[idxE-2], dx0*rxJ, dx1*rxJ) ///на холодной стенке/границе
                dTdx_hot = wallDerivative(T[idxW], T[idxW+1], T[idxW+2], dx0*rxJ, dx1*rxJ) /// на горячей стенке
            }

            /// Удельные дифффузионные тепловые потоки [W/m²]
            qE[j] = abs(lambda_cold * dTdx_cold)
            qW[j] = abs(lambda_hot * dTdx_hot)

            // При активном процессе плавления
            if allowMelt {
                /// Натуральная скорость движения фронта  плавления V melt [m/s]
                V_melt[j] = qE[j] * meltCoef
                /// прирост объема (ширины) с учетом коэф ускорения timeScale [1]
                let widthIncrement = V_melt[j] * dtdx
                rx[j] += widthIncrement
                // Конечная ширина области плавления: Rx
                if rx[j] >= Rx { /// запрет на  дальнейшее плавление
                    rx[j] = Rx /// ограничение по ширине
                    V_melt[j] = 0 /// теперь здесь - нулевая скорость границы
                    if params.useNeiman { /// условие Неймана
                        T[idxE] = T[idxE-1] /// теперь здесь -  адиабата
                        qE[j] = 0.0  /// и нулевой тепловой поток
                    } else { /// условие Дирихле
                        T[idxE] = T_cold
                    }
                }
            }
        }
        rx[0] = rx[1] /// Крайние точки -- условие Неймана
        rx[ny-1] = rx[ny-2]
        
        //Вычисление  rx avg  [1] и  V melt avg [%/h]
        updateMeltWidth()
            
        // Конвективный приток/отток тепла
        q_conv = averageConvHeatFlux(T, u, v, x, y, rx[0], rx[ny-1])
            
        }}}}}}}}}///ptr

        // Средние тепловые потоки (удельная тепловая мощность) [W/m²]
        heatFluxW = calculateAverageByHeight(value: qW) + q_conv
        heatFluxE = calculateAverageByHeight(value: qE)
        
        // КПД плавления <qCold>/<qHot> [%]
        heatDiff = updateHeatDiff(heatFluxW, heatFluxE)
    }
}
