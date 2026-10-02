//
//  HistoryMethods.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 11.12.2025.
//
//MARK: - History files manager

import SwiftUI
extension HistoryManagerView {
        
    // Методы управления файлами истории
    
    /// Сброс и действия по загрузке файла истории
    func loadAction(_ fileName: String)  {
        isLoading = true /// Показываем спиннер
        solver.reset()
        Task(priority: .background) {
            await loadSelectedFile(fileName)
            await MainActor.run { self.isLoading = false }
        }
    }
    
    /// Действия по сохранению истории
    func saveAction() {
        isLoading = true /// Показываем спиннер
        Task(priority: .background) {
            await saveHistory()
            await MainActor.run { self.isLoading = false }
        }
    }
    
    /// Загрузка файла истории и сопутствующие процедуры
    func loadSelectedFile(_ file: String) async {
        timerManager.stopAndResetCounting() /// сброс таймера
        loadHistory(fileName: file) /// загрузка истории
        solver.generateGrid() /// генерация новой сетки
    }
    
    /// Обновление списка файлоа истории
    func refreshFileList() {
        savedFiles = HistoryManager.shared.listSavedHistories
    }
    
    /// Сохранение истории в разных форматах
    func saveHistory() async {
        let historyManager = HistoryManager.shared
        do { useJSON ?
            try historyManager.saveHistory(steps, fileName, comment) :
            try historyManager.saveHistoryPlist(steps, fileName, comment)
            refreshFileList()
        } catch { print("Save history error: \(error)") }
    }
    
    /// Загрузка файла истории из разных форматов
    func loadHistory(fileName: String)  {
        let historyManager = HistoryManager.shared
        do { guard let steps = useJSON ?
                try historyManager.loadHistory(fileName) :
                try historyManager.loadHistoryPlist(fileName)
            else { return}
            loadHistorySteps(steps, fileName)
        } catch { print("Load history error: \(error)") }
    }
    
    /// Удаление файла из списка
    func deleteHistory(at offsets: IndexSet) {
        let ext = useJSON ? "json" : "bin"
        for index in offsets {
            let fileName = savedFiles[index]
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("\(fileName).\(ext)")
            do { try FileManager.default.removeItem(at: url); refreshFileList() }
            catch { print("Delete file error: \(error)") }
        }
    }
    
    /// Реализация удаления файла истории
    func deleteHistoryFile(_ fileName: String) {
        let ext = useJSON ? "json" : "bin"
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("\(fileName).\(ext)")
        do { try FileManager.default.removeItem(at: url); refreshFileList() }
        catch { print(#function, "Delete file error: \(error)") }
    }
    
}
