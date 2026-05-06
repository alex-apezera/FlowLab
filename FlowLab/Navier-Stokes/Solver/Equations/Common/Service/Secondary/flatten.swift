//
//  flatten.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 14.02.2026.
//

//MARK: - Converting a two-dimensional array to a one-dimensional (flat) array and back

// Преобразование двумерного массива в одномерный (плоский) и обратно

/// Преобразует двумерный массив (сетку) в одномерный.
/// - Parameters:
///   - flatArray: Двумерный массив (сетка).
///   - nx: Количество столбцов в сетке (количество элементов в одной строке).
///   - ny: Количество строк в сетке.
/// - Returns: Одномерный массив значений.
/// Теперь обращение [j][i] заменяется на [idx(i, j)]
/// где idx = i•ny + j (i - ряд, j - колонка или столбец)
/// <see> func idx( x: Int,  y: Int) -> Int { y•nx + x }
func flatten(grid: [[Double]], nx: Int, ny: Int) -> [Double] {
    /// В Swift 2026 flatMap все еще создает промежуточные объекты,
    /// поэтому используем резервирование памяти для скорости:
    var fl = [Double](repeating: 0.0, count: nx * ny)
    for j in 0..<ny {
        let offset = j * nx
        fl.replaceSubrange(offset..<(offset + nx), with: grid[j])
    }
    return fl
}

/// Преобразует одномерный массив в двумерный (сетку).
/// - Parameters:
///   - flatArray: Одномерный массив значений.
///   - nx: Количество столбцов в сетке (количество элементов в одной строке).
///   - ny: Количество строк в сетке.
/// - Returns: Двумерный массив (сетка).
func unflatten(flatArray: [Double], nx: Int, ny: Int) -> [[Double]] {
    // Проверка на соответствие размеров
    guard flatArray.count == nx * ny else {
        fatalError("Размер одномерного массива (\(flatArray.count)) не соответствует заданным размерам сетки (nx * ny = \(nx * ny))")
    }

    /// Инициализируем двумерный массив нулями или любым другим значением по умолчанию
    /// Удобно использовать make(count:initialResult:) для создания вложенных массивов
    var grid = [[Double]](repeating: [Double](repeating: 0.0, count: nx), count: ny)

    /// Перебираем одномерный массив и помещаем элементы на нужные позиции в двумерный массив
    for idx in 0..<(nx * ny) {
        /// Вычисляем индексы строки (j) и столбца (i) из одномерного индекса (idx)
        /// Исходя из формулы: idx = j * nx + i
        /// j = idx / nx (целочисленное деление)
        /// i = idx % nx (остаток от деления)

        let j = idx / nx /// Номер строки
        let i = idx % nx /// Номер столбца

        /// Помещаем значение из одномерного массива в соответствующую ячейку двумерного
        grid[j][i] = flatArray[idx]
    }

    return grid
}

/*
// --- Пример использования ---

// Предположим, у нас есть такие размеры
let NX_cols = 5 // nx: Количество столбцов
let NY_rows = 4 // ny: Количество строк

// Создаем одномерный массив, имитирующий результат flatten
var flatResult = [Double]()
flatResult.reserveCapacity(NX_cols * NY_rows)
for r in 0..<NY_rows { // Перебираем строки
    for c in 0..<NX_cols { // Перебираем столбцы
        let value = Double(r * 10 + c) // Простое значение для примера
        flatResult.append(value)
    }
}

print("Одномерный массив (flatResult): \\(flatResult)")
// Ожидаемый вывод: [0.0, 1.0, 2.0, 3.0, 4.0, 10.0, 11.0, 12.0, 13.0, 14.0, 20.0, 21.0, 22.0, 23.0, 24.0, 30.0, 31.0, 32.0, 33.0, 34.0]

// Обратное преобразование
let unflattenedGrid = unflatten(flatArray: flatResult, nx: NX_cols, ny: NY_rows)

print("\nДвумерный массив (unflattenedGrid):")
for row in unflattenedGrid {
    print(row)
}
// Ожидаемый вывод:
[0.0, 1.0, 2.0, 3.0, 4.0]
[10.0, 11.0, 12.0, 13.0, 14.0]
[20.0, 21.0, 22.0, 23.0, 24.0]
[30.0, 31.0, 32.0, 33.0, 34.0]
*/

/// --- Альтернативный способ создания двумерного массива ---
/// Можно сделать более "Swift-идиоматичным", но менее явным в плане индексов:
func unflattenIdiomatic(flatArray: [Double], nx: Int, ny: Int) -> [[Double]] {
     guard flatArray.count == nx * ny else {
        fatalError("Размер одномерного массива (\(flatArray.count)) не соответствует заданным размерам сетки (nx * ny = \(nx * ny))")
    }

    var grid = [[Double]]()
    grid.reserveCapacity(ny) /// Резервируем память для строк

    for j in 0..<ny {
        let startIndex = j * nx
        let endIndex = startIndex + nx
        let row = flatArray[startIndex..<endIndex]
        grid.append(Array(row)) /// Создаем новую строку из среза
    }

    return grid
}
/*
print("\nДвумерный массив (unflattenIdiomatic):")
let unflattenedGridIdiomatic = unflattenIdiomatic(flatArray: flatResult, nx: NX_cols, ny: NY_rows)
for row in unflattenedGridIdiomatic {
    print(row)
}
*/

/*
   // Перед итерациями давления
   func syncToFlat() {
       let localNX = nx
       p_flat.withUnsafeMutableBufferPointer { flatPtr in
           for j in 0..<ny {
               let offset = j * localNX
               // Вместо replaceSubrange используем быстрый memcpy
               _ = p[j].withUnsafeBufferPointer { rowPtr in
                   memcpy(flatPtr.baseAddress! + offset, rowPtr.baseAddress!, localNX * MemoryLayout<Double>.size)
               }
           }
       }
   }
   
   // После итераций давления (для визуализатора и EPM)
   func syncFromFlat() {
       let localNX = nx
       p_flat.withUnsafeBufferPointer { flatPtr in
           for j in 0..<ny {
               let offset = j * localNX
               _ = p[j].withUnsafeMutableBufferPointer { rowPtr in
                   memcpy(rowPtr.baseAddress!, flatPtr.baseAddress! + offset, localNX * MemoryLayout<Double>.size)
               }
           }
       }
   }
 */
