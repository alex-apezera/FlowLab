//
//  GlobalParams.swift
//  FlowLab
//
//  Created by Алексей Езерский on 24.03.2026.
//
// MARK: - Global properties and types

import SwiftUI

/// Определение типа устройства
let iPadDevice = UIDevice.current.userInterfaceIdiom == .pad

// Синонимы типов указателей (более компактно)
typealias Mutable = UnsafeMutableBufferPointer<Double>
typealias ReadOnly = UnsafeBufferPointer<Double>
typealias PtrUInt8 = UnsafeBufferPointer<UInt8>
typealias PtrInt = UnsafePointer<UInt8>

/// Используем NumberFormatter для корректного отображения и ввода Double
let numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.maximumFractionDigits = 10 // Точность
    formatter.minimumFractionDigits = 0
    return formatter
}()
