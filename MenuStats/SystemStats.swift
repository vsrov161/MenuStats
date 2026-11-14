//
//  SystemStats.swift
//  MenuStats
//
//  Created by Vic on 13.11.2026.
//

import Foundation

// MARK: - Память
func memoryUsagePercent() -> Int {
    let stats = getVMStats()
    let pageSize = UInt64(vm_kernel_page_size)
    let used = (UInt64(stats.active_count) + UInt64(stats.wire_count) + UInt64(stats.compressor_page_count)) * pageSize
    let total = ProcessInfo.processInfo.physicalMemory
    guard total > 0 else { return 0 }
    return Int((Double(used) / Double(total)) * 100.0)
}

func memoryUsageMB() -> String {
    let stats = getVMStats()
    let pageSize = UInt64(vm_kernel_page_size)
    let used = (UInt64(stats.active_count) + UInt64(stats.wire_count) + UInt64(stats.compressor_page_count)) * pageSize
    return "\(used / 1024 / 1024) MB"
}

func getVMStats() -> vm_statistics64 {
    var stats = vm_statistics64()
    var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)
    _ = withUnsafeMutablePointer(to: &stats) { ptr -> kern_return_t in
        ptr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPtr in
            host_statistics64(mach_host_self(), HOST_VM_INFO64, intPtr, &count)
        }
    }
    return stats
}

// MARK: - Диск
func freeDiskSpaceGB() -> String {
    let url = URL(fileURLWithPath: "/")
    guard let values = try? url.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey]),
          let freeBytes = values.volumeAvailableCapacityForImportantUsage else { return "?" }
    let formatter = ByteCountFormatter()
    formatter.allowedUnits = [.useGB]
    formatter.countStyle = .file
    return formatter.string(fromByteCount: freeBytes)
}

func freeDiskSpacePercent() -> Int {
    let url = URL(fileURLWithPath: "/")
    guard let values = try? url.resourceValues(forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityForImportantUsageKey]),
          let total = values.volumeTotalCapacity,
          let free = values.volumeAvailableCapacityForImportantUsage else { return 0 }
    let used = Double(total) - Double(free)
    return Int((used / Double(total)) * 100.0)
}

// MARK: - CPU
func cpuUsagePercent() -> Int {
    var loadInfo = host_cpu_load_info()
    var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info>.size / MemoryLayout<integer_t>.size)
    _ = withUnsafeMutablePointer(to: &loadInfo) { ptr -> kern_return_t in
        ptr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPtr in
            host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, intPtr, &count)
        }
    }
    let user = Double(loadInfo.cpu_ticks.0)
    let system = Double(loadInfo.cpu_ticks.1)
    let idle = Double(loadInfo.cpu_ticks.2)
    let nice = Double(loadInfo.cpu_ticks.3)
    let total = user + system + idle + nice
    guard total > 0 else { return 0 }
    return Int(((user + system + nice) / total) * 100.0)
}

func cpuCoresCount() -> Int {
    return ProcessInfo.processInfo.processorCount
}
