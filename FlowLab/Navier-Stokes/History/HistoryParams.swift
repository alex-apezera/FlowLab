//
//  HistoryParams.swift
//  FlowLab
//
//  Created by Алексей Езерский on 08.05.2026.
//

import Foundation
extension HistoryManagerView {
    
    /// Формирование одного кадра Истории
    var steps: [HistoryStep] {
        return history.frames.map { frame in
            HistoryStep(
                t: frame.t,
                state: SimulationState(
                    t: frame.t,
                    dt: frame.dt, dTime: frame.dTime,
                    step: frame.step,
                    rx: frame.rx,
                    rx_avg: frame.rx_avg, rx_avg_old: frame.rx_avg_old,
                    V_melt_avg: frame.V_melt_avg,
                    gravityAngle: frame.gravityAngle,
                    temperature: frame.temperature,
                    velocityX: frame.velocityX,
                    velocityY: frame.velocityY,
                    pressure: frame.pressure,
                    liquidFraction: frame.liquidFraction,
                    isStone: frame.isStone,
                    heatFluxE: frame.heatFluxE,
                    heatFluxW: frame.heatFluxW,
                    timePoints: frame.timePoints,
                    temperatureHotWall: frame.temperatureHotWall,
                    temperatureVolume: frame.temperatureVolume
                ),
                parameters: SimulationParameters(
                    nx: solver.params.nx,
                    ny: solver.params.ny,
                    Lx: solver.params.Lx,
                    Ly: solver.params.Ly,
                    stretch_x: solver.params.stretch_x,
                    stretch_y: solver.params.stretch_y,
                    Rx: solver.params.Rx,
                    gravityRotationVelocity: solver.rotationVelocity,
                    gravityInitialAngle: solver.gravityInitialAngle,
                    isGravitySynchronized: solver.params.isGravitySynchronized,
                    heatingType: solver.params.heatingType,
                    heatingValue: solver.params.heatingValue,
                    substance: solver.params.substance,
                    customFluidProperties: solver.params.customFluidProperties,
                    maxTime: solver.params.maxTime,
                    timeStep: solver.dt,
                    timeGap: solver.params.timeGap,
                    timeScale: solver.params.timeScale,
                    maxIterations: solver.params.maxIterations,
                    relaxationFactor: solver.params.relaxationFactor,
                    criticalError: solver.params.criticalError,
                    countsLimit: solver.params.countsLimit,
                    maxHistorySteps: solver.params.maxHistorySteps,
                    hiStabLimit: solver.params.hiStabLimit,
                    lowStabLimit: solver.params.lowStabLimit,
                    allowMelt: solver.params.allowMelt,
                    startMeltingStep: solver.params.startMeltingStep,
                    initMeltWidthRatio: solver.params.initMeltWidthRatio,
                    useAdaptiveRelax: solver.params.useAdaptiveRelax,
                    useEnthalpyMethod: solver.params.useEnthalpyMethod,
                    useConcurrence: solver.params.useConcurrence,
                    useParallelDiffusion:  solver.params.useParallelDiffusion,
                    useParallelPressure:  solver.params.useParallelPressure,
                    useStephanScheme: solver.params.useStephanScheme,
                    useNeiman: solver.params.useNeiman,
                    comment:  solver.params.comment,
                    dTm: solver.params.dTm,
                    useWind: solver.params.useWind,
                    windSpeed: solver.params.windSpeed,
                    windAngle: solver.params.windAngle,
                    y_start: solver.params.y_start,
                    y_end: solver.params.y_end,
                    windDeltaTemp: solver.params.windDeltaTemp,
                    leftSink: solver.params.leftSink
                ),
                comment: comment,
                totalTimeElapsed: timerManager.totalTimeElapsed,
                startTime: timerManager.startTime
            )
        }
    }
    
    /// Загрузка параметров из истории текущего сеанса
    func loadHistorySteps(_ steps: [HistoryStep], _ fileName: String) {
        // Загружаем историю в history store
        history.frames = steps.map { step in
            
            solver.params = step.parameters
            
            return HistoryFrame(
                t: step.t,
                dt: step.state.dt, dTime: step.state.dTime,
                step: step.state.step,
                rx: step.state.rx,
                rx_avg: step.state.rx_avg,
                rx_avg_old: step.state.rx_avg_old,
                V_melt_avg: step.state.V_melt_avg,
                gravityAngle: step.state.gravityAngle,
                temperature: step.state.temperature,
                velocityX: step.state.velocityX,
                velocityY: step.state.velocityY,
                pressure: step.state.pressure,
                liquidFraction: step.state.liquidFraction,
                isStone: step.state.isStone,
                heatFluxE: step.state.heatFluxE,
                heatFluxW: step.state.heatFluxW,
                timePoints: step.state.timePoints,
                temperatureHotWall: step.state.temperatureHotWall,
                temperatureVolume: step.state.temperatureVolume,
                totalTimeElapsed: step.totalTimeElapsed,
                startTime: step.startTime
            )
        }
        activeFile = fileName
        loadedComment = steps.first?.comment ?? ""
        
        // Кроме истории, загружаем параметры и поля из последнего шага
        loadLastStepHistory(steps.last)
    }

    /// Загрузка параметров из последнего шага истории, если нужно продолжить расчеты
    func loadLastStepHistory(_ step: HistoryStep?) {
        
        solver.params = step?.parameters ?? solver.params
        solver.state = step?.state ?? solver.state
        solver.t = step?.t ?? solver.t
        solver.params.customFluidProperties = step?.parameters.customFluidProperties ?? solver.params.customFluidProperties ///отдельно для Псевдо-вещества
        
        timerManager.totalTimeElapsed = step?.totalTimeElapsed ?? 0.0
        timerManager.startTime = step?.startTime ?? Date()
        solver.t = solver.state.t
        solver.dt = solver.state.dt
        solver.step = solver.state.step
        solver.rx = solver.state.rx
                
        solver.u = solver.state.velocityX
        solver.v = solver.state.velocityY
        solver.p = solver.state.pressure
        solver.T = solver.state.temperature
        solver.liquidFraction = solver.state.liquidFraction
        solver.isStone = solver.state.isStone
        solver.q_hotWall = solver.state.heatFluxW
        solver.q_coldWall = solver.state.heatFluxE
        solver.timePoints = solver.state.timePoints
        solver.T_avg_hotWall = solver.state.temperatureHotWall
        solver.T_avg_volume = solver.state.temperatureVolume
        solver.rx_avg = solver.state.rx_avg
        solver.rx_avg_old = solver.state.rx_avg_old
        solver.V_melt_avg = solver.state.V_melt_avg
    }

}
