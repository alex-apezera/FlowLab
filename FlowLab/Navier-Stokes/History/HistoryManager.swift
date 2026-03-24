//
//  HistoryManager.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 12.11.2025.
//

import SwiftUI

// MARK: - Менеджер хранения истории

class HistoryManager {
    static let shared = HistoryManager()
    private let fileManager = FileManager.default
    private let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    func saveHistory(_ history: [HistoryStep], fileName: String, comment: String) throws {
        var history = history
        history[0].comment = comment
        let url = documentsURL.appendingPathComponent("\(fileName).history")
        let data = try JSONEncoder().encode(history)
        try data.write(to: url)
    }
    
    func loadHistory(fileName: String) throws -> [HistoryStep] {
        let url = documentsURL.appendingPathComponent("\(fileName).history")
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([HistoryStep].self, from: data)
    }
    
    var listSavedHistories: [String] {
        do {
            let files = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            return files
                .filter { $0.pathExtension == "history" }
                .map { $0.deletingPathExtension().lastPathComponent }
        } catch {
            return []
        }
    }
    
    // Размер одного файла
    func getFileSize(_ fileName: String) -> String {
        let url = documentsURL.appendingPathComponent("\(fileName).history")
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
              let size = attrs[.size] as? UInt64 else { return "0 MB" }
        return String(format: "%.2f MB", Double(size) / 1_048_576.0)
    }

    // Размер всей директории (рекурсивно)
    var getHistoryFolderSize: String {
        var totalSize: UInt64 = 0
        let fileManager = FileManager.default
        
        if let enumerator = fileManager.enumerator(at: documentsURL, includingPropertiesForKeys: [.fileSizeKey]) {
            for case let fileURL as URL in enumerator {
                if let resources = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
                   let size = resources.fileSize {
                    totalSize += UInt64(size)
                }
            }
        }
        return String(format: "%.1f MB", Double(totalSize) / 1_048_576.0)
    }

}
