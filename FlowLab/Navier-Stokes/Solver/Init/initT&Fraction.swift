//
//  initTemperature.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 12.11.2025.
//

extension NavierStokesSolver {
    // Линейный градиент для температуры по х-координате
    func initTAndFraction() {
        
        // Начальная толщина расплава (зависит от метода EPM или ALE)
        let initialMeltWidth = useEnthalpyMethod ? Lx * initMeltWidthRatio : Lx
 
        for j in 0..<ny {
            let row = j * nx

            var deltaT = 0.0
            switch heatingType {
            case .temperature: deltaT = heatingValue
            case .heatFlux: deltaT = Lx * initMeltWidthRatio * heatingValue / lambda
            }
            T[row] = deltaT + T_melt
            
            for i in 0..<nx {
                let idx = row + i

                if useEnthalpyMethod { /// используется метод энтальпии (EPM)
                    let x_phys = Double(i) * h
                    if x_phys <= initialMeltWidth {
                        /// Зона расплава: температура выше Tmelt
                        liquidFraction[idx] = 1.0 /// liquid
                       if useInitialGradientT { ///линейное падение от Thot до Tmelt
                            T[idx] = T[row] - deltaT * (x_phys / initialMeltWidth) }
                        else { /// постоянная температура  выше T melt
                            T[idx] = T_melt + dTm
                        }
                    } else { /// зона твердого тела: температура ниже Tmelt
                        T[idx] = T_cold
                        liquidFraction[idx] = 0.0 /// solid
                        isStone[idx] = 1
                    }
                } else { /// используется метод раздвижной стенки (ALE)
                    if useInitialGradientT { ///линейное падение от Thot до Tcold
                        T[idx] = T_cold + deltaT * (1 - x[i] / Lx)
                    }
                    else { /// постоянная температура  выше T melt
                        T[idx] = T_cold + 0.5*(T_max - T_cold)
                    }
                }
                isStone[idx] = 0 /// начальный статус жидкости (0)
                if i==0 || i==nx-1 || j==0 || j==ny-1 { ///на границах - твердое тело (1)
                    isStone[idx] = 1
                }
                
            }
        }
        avgTemp = T_melt + dTm /// начальное значение
    }
    
}
