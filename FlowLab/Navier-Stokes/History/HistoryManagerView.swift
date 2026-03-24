//
//  HistoryManagerView.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 13.11.2025.
//

import SwiftUI

// MARK: - Представление для управления историей

struct HistoryManagerView: View {
    @Binding var isPresented: Bool
    @ObservedObject var solver: NavierStokesSolver
    @ObservedObject var history: HistoryStore
    @ObservedObject var timerManager: TimeCounterManager
    @Binding var activeFile: String?
    
    @State var fileName = ""
    @State var comment = ""
    @AppStorage("loadedComment") var loadedComment = ""
    @State var savedFiles: [String] = []
    @State var showingFileActions = false
    @State var selectedFile: String?
        
    var body: some View {
        @State var params = solver.params

        NavigationView {
            VStack {
                // Панель сохранения
                Section(header: Text("Сохранить историю").font(.headline)) {
                    HStack{
                        TextField("Имя файла", text: $fileName)
                        TextField("Комментарий", text: $comment)
                        Button { Task { await saveHistory() } }
                        label: {Image(systemName: "square.and.arrow.down")}
                        .disabled(fileName.isEmpty)
                    }
                    .editText(.asciiCapable)
                    .padding()
                }
                
                // Список файлов с действиями
                Section(header: Text("Файлы истории, всего: \(HistoryManager.shared.getHistoryFolderSize)").font(.headline)) {
                    List {
                        ForEach(savedFiles, id: \.self) { file in
                            HStack {
                                Text(file).frame(width: 260, height: 30, alignment: .leading)
                                let comment = file == activeFile ? loadedComment : "Файл не загружен"
                                Text(comment)
                                    .foregroundColor(.secondary)
                                Spacer()
                                if file == activeFile {
                                    Image(systemName: "checkmark")
                                }
                                Text(HistoryManager.shared.getFileSize(file))
                                    .foregroundColor(.secondary)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedFile = file
                                showingFileActions = true
                            }
                        }
                        .onDelete(perform: deleteHistory)
                    }
                }
            }
            .navigationModifier("Управление историей")
            .navigationBarItems(trailing: Button("Готово") {
                isPresented = false
            })
            .onAppear(perform: refreshFileList)
            .actionSheet(isPresented: $showingFileActions) {
                ActionSheet(
                    title: Text("Действия с файлом"),
                    message: Text(selectedFile ?? ""),
                    buttons: [
                        .default(Text("Загрузить")) {
                            if let file = selectedFile {
                                Task { await loadSelectedFile(file) }
                            }
                        },
                        .destructive(Text("Удалить")) {
                            if let file = selectedFile {
                                deleteHistoryFile(file)
                            }
                        },
                        .cancel()
                    ]
                )
            }
        }
    }
    
}
