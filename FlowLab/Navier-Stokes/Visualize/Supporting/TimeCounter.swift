//
//  TimeCounter.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 25.11.2025.
//
// MARK: - Controlling the calculation time counter (timer)

import Foundation
import Combine

/// Упрааление счетчиком времени расчетов (таймером)
class TimeCounterManager: ObservableObject {
    // Опубликованные свойства для обновления UI
    @Published var totalTimeElapsed: TimeInterval = 0.0 // Общее время в секундах
    @Published var isRunning: Bool = false
    @Published var startTime: Date? = nil
    
    // Внутренние переменные для учета текущего запуска
    private var currentStartDate: Date? = nil
    private var timer: Timer?
    
    /// Запуск таймера
    func startCounting() {
        if isRunning { return }
        
        isRunning = true
        currentStartDate = Date()
        
        // Устанавливаем дату начала только при самом первом запуске
        if startTime == nil {
            startTime = Date()
        }
        
        // Запускаем таймер, который периодически обновляет общее время
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTotalTime()
        }
    }
    
    /// Остановка таймера
    func pauseCounting() {
        if !isRunning { return }
        
        isRunning = false
        // При паузе фиксируем накопленное время текущего интервала
        updateTotalTime()
        currentStartDate = nil // Сбрасываем начало текущего интервала
        timer?.invalidate() // Останавливаем таймер
        timer = nil
    }
    
    /// Сброс таймера
    func stopAndResetCounting() {
        pauseCounting()
        totalTimeElapsed = 0.0
        startTime = nil
    }
    
    /// Обновление времени, прошедшего с момента последнего запуска/возобновления
    private func updateTotalTime() {
        if let start = currentStartDate {
            // Вычисляем время, прошедшее с момента последнего запуска/возобновления
            let elapsed = Date().timeIntervalSince(start)
            totalTimeElapsed += elapsed
            currentStartDate = Date() // Сбрасываем точку отсчета для следующего интервала таймера
        }
    }
    
    /// Форматирование ЧЧ:ММ:СС с ведущими нулями
    func formattedElapsedTime() -> String {
        let seconds = Int(totalTimeElapsed)
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, remainingSeconds)
    }
    
    /// Формат даты и времени, например, 25.11.2025 23:16:00
    func formattedStartDate() -> String {
        guard let start = startTime else { return "not running" }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        return formatter.string(from: start)
    }
}
