//
//  updateStatus.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 11.02.2026.
//
//MARK: - Emergence message

import AVFoundation

extension NavierStokesSolver {
    
    @MainActor
    func updateStatus(_ msg: String) async {
        self.statusMessage = msg
        
        // --- ЗВУК ДЛЯ iPad/Mac Catalyst ---
        /// Tink :  Сбой
        let soundID: SystemSoundID = msg.contains("⚠️") ? 1003 : 1004
        AudioServicesPlaySystemSound(soundID)
        
        print("📢 [Step: \(step)] \(msg)")

        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            if self.statusMessage == msg { self.statusMessage = "" }
        }
    }
    
}
