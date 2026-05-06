//
//  Files.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 28.01.2026.
//
//MARK: - Standard methods for working with files

import SwiftUI
import UniformTypeIdentifiers
extension LiquidFractionEditor {
    
    // Стандартные методы работы с файлами
    
    /// Импорт файла
    func importFile(result: Result<URL, Error>) {
        if case .success(let url) = result {
            if url.startAccessingSecurityScopedResource() {
                defer { url.stopAccessingSecurityScopedResource() }
                if let data = try? Data(contentsOf: url),
                   let state = try? JSONDecoder().decode(SimulationStateLiquidFraction.self, from: data) {
                    solver.applyState(state)
                }
            }
        }
    }
    
    @MainActor
    struct SimulationDocument: @preconcurrency FileDocument {
        // Указываем, что работаем с форматом JSON
        static var readableContentTypes: [UTType] { [.json] }
        var state: SimulationStateLiquidFraction
        // Инициализаторы:
        // для создания нового документа из данных солвера
        init(state: SimulationStateLiquidFraction) {self.state = state}
        //  для чтения файла с диска
        init(configuration: ReadConfiguration) throws {
            guard let data = configuration.file.regularFileContents else { throw CocoaError(.fileReadCorruptFile) }
            self.state = try JSONDecoder().decode(SimulationStateLiquidFraction.self, from: data)
        }
        
        /// Функция записи данных в файл
        func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
            let data = try JSONEncoder().encode(state)
            return FileWrapper(regularFileWithContents: data)
        }
    }

}

