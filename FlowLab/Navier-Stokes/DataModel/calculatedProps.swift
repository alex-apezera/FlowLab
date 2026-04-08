//
//  calculatedVars.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 06.11.2025.
//
import Foundation
extension NavierStokesSolver {
    
    // MARK: - Вычисляемые переменные и свойства
    

    // Параметры сетки -> params
    var Lx: Double {params.Lx} ///начальная ширина области [m]
    var Ly: Double {params.Ly} /// высота области [m]
    var nx: Int {params.nx} ///  узлов сетки по ширине
    var ny: Int {params.ny} ///  узлов сетки по высоте
    var Rx: Double {params.Rx}  /// ограничение по ширине расплава ( > 1 )
    var L: Double { meltWidth }/// нормированный объём расплава V, [m]
    
    // Коэффициенты растяжения сетки к центру области (от 0 до 10)
    var stretch_x: Double {params.stretch_x} ///  = 0 для равномерной сетки
    var stretch_y: Double {params.stretch_y}
    
    // Вещество -> params
    var substance: Substance {params.substance}
    
    // Гравитация -> params
    var gravityInitialAngle: Double { .pi/180 * params.gravityInitialAngle }
    var rotationVelocity: Double { allowMelt ?
        params.gravityRotationVelocity / 86400 : ///[º/day]
        params.gravityRotationVelocity } ///[º/s]
    
    // Температурные параметры -> params
    var heatingValue: Double {params.heatingValue} /// [K] or [W/m²]
    var heatingType: HeatingType {params.heatingType}/// T or q
    /// Величина нагрева в зависимости от способа нагрева
    @inline(__always) var deltaT: Double { switch heatingType {
        case .temperature: return heatingValue
        case .heatFlux: return Lx*initMeltWidthRatio*heatingValue/lambda }
    }
    /// Температура плавления вещества [ºC]
    @inline(__always) var T_melt: Double {substance.properties.T_melt}
    /// Температура твёрдого тела или правой границы области [ºC]
    @inline(__always) var T_cold: Double { useEnthalpyMethod ?
        (allowMelt ? T_melt - dTm : T_melt) : T_melt }
//    @inline(__always) var T_hot: Double {deltaT + T_melt}
    /// Максимальная вычисленная температура [ºC]
    var T_max: Double { T_cold + deltaT }
 
    // Управление решением (переключатели) -> params
    var useEnthalpyMethod: Bool {params.useEnthalpyMethod}
    var useConcurrence: Bool {params.useConcurrence}
    var useParallelPressure: Bool {params.useParallelPressure}

    // Параметры плавления -> params
    
    /// Разрешение на включение режима расчета плавления
    var allowMelt: Bool {params.allowMelt}

    /// Порог температуры (T melt - T cold [K])
    var dTm: Double {params.dTm} ///
    /// Относительная толщина (объём) на начало плавления для метода EPM [m]
    var initMeltWidthRatio: Double {useEnthalpyMethod ? params.initMeltWidthRatio : 1.0 }
    /// Время плавления по физике, расчитываемое по заданной толщине расплава [s]
    @inline(__always)
    func meltingTime(from meltWidth: Double) -> Double {
        rho * latentHeat * meltWidth * meltWidth / (lambda * deltaT) }
    /// Полное физическое время плавления, расчитываемое по объёму расплава [s]
    var fullMeltingTime: Double { meltingTime(from: meltWidth) }
    /// Начальное физическое время, вычисляется по начальному объёму расплава [s]
    var initialTime: Double {meltingTime(from: initMeltWidthRatio * Lx)}
    /// Время плавления по физике, от начала расчетов [s]
    var time: Double {
        allowMelt ? fullMeltingTime - initialTime : t}
    /// Шаг плавления по физике на основе разницы объёмов расплава
    @inline(__always)
    var dTime: Double {
        let timeStep = fullMeltingTime - meltingTime(from: Lx * rx_avg_old * initMeltWidthRatio)
        return timeStep > 0 ? timeStep : dt
    }
    /// Текущая толщина расплава (он же "линейный" объём) [m]
    var meltWidth: Double {Lx * rx_avg * initMeltWidthRatio}

    /// Масштабирование шага по времени при фазовом переходе -> params
    var timeScale: Double { allowMelt ? params.timeScale : 1.0 }
    
    // Параметры времени и истории -> params
    var timeGap: Double {params.timeGap} /// интервал занесения в историю [s]
    var maxTime: Double {params.maxTime} /// конечное временя решения [s]
    
    // Вычисление максимальной величины вектора скорости [m/s]
    @inline(__always)
    var maxVelocityValue: Double {
        var maxValue: Double = 0.0
        for j in 0..<ny {
            let row = j * nx
            for i in 0..<nx {
                let idx = row + i
                let uValue = u[idx]
                let vValue = v[idx]
                maxValue = max(maxValue, sqrt(uValue*uValue + vValue*vValue))
            }
        }
        return maxValue
        
//        let (minU, maxU) = fieldLimits(u)
//        let (minV, maxV) = fieldLimits(v)
//        return max(abs(minU), abs(maxU), abs(minV), abs(maxV))
    }
        
}
