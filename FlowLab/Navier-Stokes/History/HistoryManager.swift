//
//  HistoryManager.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 12.11.2025.
//
// MARK: - Save/load History file in different formats

import SwiftUI
/// Управление файлами истории
class HistoryManager {
    static let shared = HistoryManager()
    private let fileManager = FileManager.default
    private let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    @AppStorage("useJSON") var useJSON: Bool = false

    func saveHistory(_ history: [HistoryStep], _ fileName: String, _ comment: String) throws {
        var history = history
        guard !history.isEmpty else { return }
        history[0].comment = comment
        let url = documentsURL.appendingPathComponent("\(fileName).json")
        let data = try JSONEncoder().encode(history)
        try data.write(to: url)
    }
        
    func loadHistory(_ fileName: String) throws -> [HistoryStep]? {
        let url = documentsURL.appendingPathComponent("\(fileName).json")
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([HistoryStep].self, from: data)
    }
    
    func saveHistoryPlist(_ history: [HistoryStep], _ fileName: String, _ comment: String) throws {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        
        var history = history
        guard !history.isEmpty else { return }
        history[0].comment = comment
        
        let url = documentsURL.appendingPathComponent("\(fileName).bin")
        let data = try encoder.encode(history)
        
        // Используем системное сжатие (iOS 13.0+)
        let compressedData = try (data as NSData).compressed(using: .lzfse) as Data
        try compressedData.write(to: url, options: .atomic)
    }
    
    func loadHistoryPlist(_ fileName: String) throws -> [HistoryStep]? {
        let url = documentsURL.appendingPathComponent("\(fileName).bin")
        let compressedData = try Data(contentsOf: url)
        
        // Системная декомпрессия сама выделит нужный объем памяти
        let decompressedData = try (compressedData as NSData).decompressed(using: .lzfse) as Data
        
        let decoder = PropertyListDecoder()
        return try decoder.decode([HistoryStep].self, from: decompressedData)
    }
    
    var listSavedHistories: [String] {
        let ext = useJSON ? "json" : "bin"
        do {
            let files = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            return files
                .filter { $0.pathExtension == ext }
                .map { $0.deletingPathExtension().lastPathComponent }
        } catch {
            return []
        }
    }
    
    // Размер одного файла
    func getFileSize(_ fileName: String) -> String {
        let ext = useJSON ? "json" : "bin"
        let url = documentsURL.appendingPathComponent("\(fileName).\(ext)")
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
              let size = attrs[.size] as? UInt64 else { return "0 Mb" }
        return String(format: "%4.0f Mb", Double(size) / 1_048_576.0)
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
        return String(format: "%4.0f Mb", Double(totalSize) / 1_048_576.0)
    }

}
