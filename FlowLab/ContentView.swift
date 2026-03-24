//
//  ContentView.swift
//  FlowLab
//
//  Created by Алексей Езерский on 24.03.2026.
//

import SwiftUI

// MARK: - Основное приложение

let iPadDevice = UIDevice.current.userInterfaceIdiom == .pad

struct ContentView: View {
    
    var body: some View {
        Visualizator()
    }
}
