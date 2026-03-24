//
//  SystemMonitor.swift
//  Navier-Stokes
//
//  Created by Алексей Езерский on 13.01.2026.
//

import Foundation
struct SystemMonitor {
    
    static var getMemoryUsage: Double {
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        return kerr == KERN_SUCCESS ? Double(taskInfo.resident_size) / 1024 / 1024 : 0
    }
    
    static var getCPUUsage: Double {
        var threadList: thread_act_array_t?
        var threadCount: mach_msg_type_number_t = 0
        
        // Получаем список всех потоков текущей задачи
        let kerr = task_threads(mach_task_self_, &threadList, &threadCount)
        if kerr != KERN_SUCCESS { return 0.0 }
        
        var totalCPU: Double = 0
        
        if let threads = threadList {
            for i in 0..<Int(threadCount) {
                var threadInfo = thread_basic_info()
                // Использование MemoryLayout гарантирует правильный размер для компилятора Swift
                var count = mach_msg_type_number_t(MemoryLayout<thread_basic_info_data_t>.size / MemoryLayout<integer_t>.size)
                
                let result = withUnsafeMutablePointer(to: &threadInfo) {
                    $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                        thread_info(threads[i], thread_flavor_t(THREAD_BASIC_INFO), $0, &count)
                    }
                }
                
                if result == KERN_SUCCESS {
                    // cpu_usage измеряется в долях от TH_USAGE_SCALE (обычно 1000)
                    let cpu = Double(threadInfo.cpu_usage) / Double(TH_USAGE_SCALE)
                    totalCPU += cpu
                }
            }
            
            // Обязательно освобождаем память, выделенную под список потоков
            let size = vm_size_t(threadCount) * vm_size_t(MemoryLayout<thread_t>.size)
            vm_deallocate(mach_task_self_, vm_address_t(bitPattern: threadList), size)
        }
        
        // Результат в процентах (например, 100.0 — это полная загрузка одного ядра)
        return totalCPU * 100.0
    }
    
}
