//
//  initTemperature.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 12.11.2025.
//
//MARK: - Initial distribution of Temperature and Fraction

extension NavierStokesSolver {
    /// Начальное распределение Температуры и Фракции (жидкость/твердое тело)
    func initTAndFraction() {
        
        // Начальная толщина расплава (зависит от метода EPM или ALE)
        let initialMeltWidth = useEnthalpyMethod ? Lx * initMeltWidthRatio : Lx
        avgTemp = 0.5*(T_cold+T_max)/// начальное значение средней температуры
        let jStart = Int(params.y_start * Double(ny)) /// начало
        let jEnd = Int(params.y_end * Double(ny))     /// конец
        
        for j in 0..<ny {
            let row = j * nx
            T[row] = deltaT + T_melt
            
            if params.useWind {
                isStone[row] = inlet(jStart, jEnd, j) || outlet(jStart, jEnd, j) ? 0 : 1
            }
            
            for i in 0..<nx {
                let idx = row + i

                if useEnthalpyMethod { /// используется метод энтальпии (EPM)
                    let x_phys = Double(i) * h
                    if x_phys <= initialMeltWidth {
                        /// Зона расплава: температура выше Tmelt
                        liquidFraction[idx] = 1.0 /// liquid
                       if useInitialGradientT { ///линейное падение
                            T[idx] = T[row] - deltaT * (x_phys / initialMeltWidth) }
                        else { /// постоянная температура  выше T melt
                            T[idx] = T_melt + 0.5 * deltaT
                        }
                    } else { /// зона твердого тела: температура ниже Tmelt
                        T[idx] = T_cold
                        liquidFraction[idx] = 0.0 /// solid
                    }
                } else { /// используется метод раздвижной стенки (ALE)
                    if useInitialGradientT { ///линейное падение
                        T[idx] = T_cold + deltaT * (1 - x[i] / Lx)
                    }
                    else { /// постоянная температура  выше T melt
                        T[idx] = T_cold + 0.5 * deltaT
                    }
                }
            }
        }
        applyTemperatureBoundaryConditions(&T)
    }
}
