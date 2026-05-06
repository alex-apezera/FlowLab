//
//  FlowLabApp.swift
//  FlowLab
//
//  Created by Алексей Езерский on 24.03.2026.
//
// MARK: - Запуск Приложения, Start FlowLabApp

import SwiftUI

@main
struct FlowLabApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

/// Запуск визуализатора
struct ContentView: View {
    
    var body: some View {
        Visualizator()
    }
}

