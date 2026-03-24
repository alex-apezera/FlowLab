//
//  cellInfoPopup.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 19.03.2026.
//
import SwiftUI
extension Visualizator {
    /// Всплывающее окно с иинформацией об узле с переменными поля
    func cellInfoPopup(_ info: CellInfo) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            // Заголовок с индексами
            Text("Узел: [\(info.xIndex), \(info.yIndex)]")
                .font(.caption.bold())
                .foregroundColor(.secondary)
            
            Divider()
            
            // Данные (используем VStack для надежности типов)
            VStack(alignment: .leading, spacing: 2) {
                Text("T: \(info.T, specifier: "%.2f") ºC")
                Text("P: \(info.p, specifier: "%.4f") Pa")
                Text("U: \(info.u*1000, specifier: "%.4f") mm/s")
                Text("V: \(info.v*1000, specifier: "%.4f") mm/s")
                Text("Жидкость: \(info.liq * 100, specifier: "%.0f")%")
            }
            .font(.system(size: 10, design: .monospaced))
            
            // Статус препятствия
            if info.isStone {
                Text("КАМЕНЬ")
                    .font(.system(size: 9, weight: .black))
                    .foregroundColor(.red)
                    .padding(.top, 2)
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
        .overlay( RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.2), lineWidth: 0.5) )
        .frame(width: 140)
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}
