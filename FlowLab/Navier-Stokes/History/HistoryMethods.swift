//
//  HistoryMethods.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 11.12.2025.
//
import SwiftUI
extension HistoryManagerView {
    
    //MARK: - Методы управления файлами истории
    
    func loadAction(_ fileName: String)  {
        isLoading = true /// Показываем спиннер
        solver.reset()
        Task(priority: .userInitiated) {
            await loadSelectedFile(fileName)
            await MainActor.run { self.isLoading = false }/// конец загрузки
        }
    }
    
    func saveAction() {
        isLoading = true /// Показываем спиннер
        Task(priority: .userInitiated) {
            await saveHistory()
            await MainActor.run { self.isLoading = false }/// конец сохранения
        }
    }
    
    func loadSelectedFile(_ file: String) async {
        solver.initArrays() /// инициализация массивов под новую сетку
        timerManager.stopAndResetCounting() /// сброс таймера
        loadHistory(fileName: file) /// загрузка истории
        solver.generateGrid() /// генерация новой сетки
    }
    
    func refreshFileList() {
        savedFiles = HistoryManager.shared.listSavedHistories
    }
    
    func saveHistory() async {
        let historyManager = HistoryManager.shared
        do { useJSON ?
            try historyManager.saveHistory(steps, fileName, comment) :
            try historyManager.saveHistoryPlist(steps, fileName, comment)
            refreshFileList()
        } catch { print("Save history error: \(error)") }
    }
 
    func loadHistory(fileName: String)  {
        let historyManager = HistoryManager.shared
        do { guard let steps = useJSON ?
                try historyManager.loadHistory(fileName) :
                try historyManager.loadHistoryPlist(fileName)
            else { return}
            loadHistorySteps(steps, fileName)
        } catch { print("Load history error: \(error)") }
    }
        
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
    
    func deleteHistoryFile(_ fileName: String) {
        let ext = useJSON ? "json" : "bin"
        // Реализация удаления файла истории
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("\(fileName).\(ext)")
        do { try FileManager.default.removeItem(at: url); refreshFileList() }
        catch { print(#function, "Delete file error: \(error)") }
    }
}
