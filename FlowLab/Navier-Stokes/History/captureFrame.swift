//
//  captureFrame.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 14.11.2025.
//

extension NavierStokesSolver {
    
    // MARK: - Функции для визуализации
    func captureFrame() -> HistoryFrame {
//        let timerManager = TimeCounterManager()
        return HistoryFrame(
            t: t,
            dt: dt, dTime: dTime,
            step: step,
            rx: rx,
            rx_avg: rx_avg, rx_avg_old: rx_avg_old,
            V_melt_avg: V_melt_avg,
            gravityAngle: gravityArrowAngle,
            temperature: T,
            velocityX: u,
            velocityY: v,
            pressure: p,
            liquidFraction: liquidFraction,
            isStone: isStone,
            heatFluxE: q_coldWall,
            heatFluxW: q_hotWall,
            temperatureHotWall: T_avg_hotWall,
            temperatureVolume: T_avg_volume,
            totalTimeElapsed: timerManager.totalTimeElapsed,
            startTime: timerManager.startTime
        )
    }
}
