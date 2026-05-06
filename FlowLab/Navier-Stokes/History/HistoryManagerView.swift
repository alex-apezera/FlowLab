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
    @AppStorage("useJSON") var useJSON: Bool = false
    @State var isLoading = false /// Состояние для спиннера
        
    var body: some View {
        @State var params = solver.params

        NavigationView {
            ZStack {
                VStack {
                    // Панель сохранения
                    Section(header: Text("Save history").font(.headline)) {
                        
                        HStack{
                            editString("File name", $fileName)
                            Button { saveAction() }
                            label: {Image(systemName: "square.and.arrow.down")}
                                .disabled(fileName.isEmpty || history.frames.isEmpty)
                            editString("Enter comment", $comment)
                        }
                        .padding(.horizontal, 10)
                        
                        Toggle("OFF: -> .bin, ON: -> .json", isOn: $useJSON)
                            .clipMode(350)
                    }.padding(.horizontal, 5)
                    
                    // Список файлов с действиями
                    Section(header: Text("History files, total size: \(HistoryManager.shared.getHistoryFolderSize)")
                        .font(.callout).foregroundStyle(.tertiary)) {
                            List {
                                ForEach(savedFiles, id: \.self) { file in
                                    HStack {
                                        Text(file)
                                        Spacer()
                                        let comment = file == activeFile ? loadedComment : "File not loaded"
                                        Text(comment)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        HStack {
                                            if file == activeFile {
                                                Image(systemName: "checkmark")
                                            }
                                            Text(HistoryManager.shared.getFileSize(file))
                                                .foregroundColor(.secondary)
                                        }
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
                .disabled(isLoading) /// Блокируем кнопки при загрузке
                .navigationModifier("History service")
                .done($isPresented)
                .onAppear(perform: refreshFileList)
                .onChange(of: useJSON) {refreshFileList()}
                .onAppear{ comment = solver.params.comment }
                .onDisappear { solver.params.comment = comment }
                .confirmationDialog(
                    "File actions",
                    isPresented: $showingFileActions,
                    titleVisibility: .visible
                ) {
                    Button("Load") {
                        if let selectedFile { loadAction(selectedFile) }
                    }
                    Button("Delete", role: .destructive) {
                        if let file = selectedFile { deleteHistoryFile(file) }
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text(selectedFile ?? "") /// имя файла
                }

                // Спиннер поверх всего (не работает с айФоном)
                if isLoading {
                    Color.black.opacity(0.2) /// Darkening the background
                        .ignoresSafeArea()
                    ProgressView("Data processing...")
                        .padding()
                        .background(Color.secondary.colorInvert())
                        .cornerRadius(10)
                        .shadow(radius: 10)
                }
            } ///ZStack
        }
    }
    
}
