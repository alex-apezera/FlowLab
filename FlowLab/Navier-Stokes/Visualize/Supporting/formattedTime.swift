//
//  formattedTime.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 16.11.2025.
//
//MARK: - Convert time in seconds to days-hours-seconds string

import Foundation

/// Преобразование времени в секундах в строку дни-часы-секунды
func formattedTime(_ totalSeconds: Double) -> String {

    guard totalSeconds.isFinite && totalSeconds > Double(Int.min) else {
        return "99d:99h:99m:99s" }
    // Преобразуем общее количество секунд в целое число для расчетов
    let totalSecondsInt = Int(totalSeconds)
    
    // Новое: Рассчитываем дни: общее количество секунд, деленное на 86400 (секунд в сутках: 60*60*24)
    let days = totalSecondsInt / 86400
    
    // Рассчитываем часы: остаток секунд после вычета дней, деленный на 3600
    let hours = (totalSecondsInt % 86400) / 3600
    
    // Рассчитываем минуты: остаток секунд после вычета часов, деленный на 60
    let minutes = (totalSecondsInt % 3600) / 60
    
    // Рассчитываем оставшиеся секунды: остаток секунд после вычета часов и минут
    let seconds = totalSecondsInt % 60
    
    // Используем форматирование String(format:)
    // %02d гарантирует, что каждое число будет иметь минимум 2 цифры, с ведущим нулем
    var finalTime: String = String(format: "%dd:%02dh:%02dm:%02ds", days, hours, minutes, seconds)
    if days == 0 && hours != 0 && minutes != 0 {
        finalTime = String(format: "%02dh:%02dm:%02ds", hours, minutes, seconds)
    } else if days == 0 && hours == 0 && minutes != 0 {
        finalTime = String(format: "%02dm:%02ds", minutes, seconds)
    } else if days == 0 && hours == 0 && minutes == 0 {
        finalTime = String(format: "%llds", seconds)
    }
    return finalTime
}

