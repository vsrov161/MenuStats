//
//  SystemStats.swift
//  MenuStats
//
//  Created by Vic on 13.11.2026.
//

import Foundation

// MARK: - Память
func memoryUsagePercent() -> Int {
    var stats = vm_statistics64()
    var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)

    let result = withUnsafeMutablePointer(to: &stats) { ptr -> kern_return_t in
        ptr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPtr in
            host_statistics64(mach_host_self(), HOST_VM_INFO64, intPtr, &count)
        }
    }

    guard result == KERN_SUCCESS else { return 0 }

    let pageSize = UInt64(vm_kernel_page_size)

    let active     = UInt64(stats.active_count) * pageSize
    let wired      = UInt64(stats.wire_count) * pageSize
    let compressed = UInt64(stats.compressor_page_count) * pageSize

    let used = active + wired + compressed
    let total = ProcessInfo.processInfo.physicalMemory

    guard total > 0 else { return 0 }
    return Int((Double(used) / Double(total)) * 100.0)
}

// MARK: - Диск
func freeDiskSpace() -> String {
    let url = URL(fileURLWithPath: "/")
    guard let values = try? url.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey]),
          let freeBytes = values.volumeAvailableCapacityForImportantUsage else {
        return "?"
    }
    let formatter = ByteCountFormatter()
    formatter.allowedUnits = [.useGB]
    formatter.countStyle = .file
    return formatter.string(fromByteCount: freeBytes)
}
