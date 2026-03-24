//
//  TimeCounterView.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 11.12.2025.
//
/*
import SwiftUI

struct TimeCounterView: View {
    @StateObject private var timerManager = TimeCounterManager()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Дата начала: \(timerManager.formattedStartDate())")
            
            Text("Пройдено времени: \(timerManager.formattedElapsedTime())")
                .font(.largeTitle)
            
            HStack {
                Button(action: {
                    if timerManager.isRunning {
                        timerManager.pauseCounting()
                    } else {
                        // Здесь вы можете запустить вашу реальную задачу Task {}
                        // и вызвать startCounting() когда она начнет работу
                        timerManager.startCounting()
                    }
                }) {
                    Text(timerManager.isRunning ? "Пауза" : "Старт")
                }
                
                Button(action: {
                    timerManager.stopAndResetCounting()
                }) {
                    Text("Сброс")
                }
            }
        }
    }
}
*/
