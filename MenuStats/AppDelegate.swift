//
//  AppDelegate.swift
//  MenuStats
//
//  Created by Vic on 13.11.2026.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    var statusItem: NSStatusItem!
    var timer: Timer?
    var settingsWindow: SettingsWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.title = "Загрузка..."
            
            // Создаем меню
            let menu = NSMenu()
            
            let settingsItem = NSMenuItem(title: "Настройки...", action: #selector(openSettings), keyEquivalent: ",")
            menu.addItem(settingsItem)
            
            menu.addItem(NSMenuItem.separator())
            
            let quitItem = NSMenuItem(title: "Выход", action: #selector(quitApp), keyEquivalent: "q")
            menu.addItem(quitItem)
            
            statusItem.menu = menu
        }

        // Слушаем уведомления об изменении настроек
        NotificationCenter.default.addObserver(self, selector: #selector(updateStats), name: Notification.Name("SettingsChanged"), object: nil)

        updateStats()
        
        timer = Timer.scheduledTimer(timeInterval: 2.0,
                                     target: self,
                                     selector: #selector(updateStats),
                                     userInfo: nil,
                                     repeats: true)
    }

    @objc func openSettings() {
        if settingsWindow == nil {
            settingsWindow = SettingsWindowController()
        }
        settingsWindow?.showWindow(nil)
        settingsWindow?.window?.makeKeyAndOrderFront(nil)
        
        // Активируем приложение, чтобы окно было поверх всех
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func updateStats() {
        let defaults = UserDefaults.standard
        var parts: [String] = []
        
        // Вспомогательная функция: если ключа нет, возвращает true (включено)
        func getBool(forKey key: String) -> Bool {
            if defaults.object(forKey: key) == nil { return true }
            return defaults.bool(forKey: key)
        }
        
        // --- RAM ---
        var ramParts: [String] = []
        if getBool(forKey: "ramShowPercent") { ramParts.append("\(memoryUsagePercent())%") }
        if getBool(forKey: "ramShowMB") { ramParts.append(memoryUsageMB()) }
        if !ramParts.isEmpty {
            parts.append("RAM: " + ramParts.joined(separator: " "))
        }
        
        // --- HDD ---
        var hddParts: [String] = []
        if getBool(forKey: "hddShowPercent") { hddParts.append("\(freeDiskSpacePercent())%") }
        if getBool(forKey: "hddShowGB") { hddParts.append(freeDiskSpaceGB()) }
        if !hddParts.isEmpty {
            parts.append("HDD: " + hddParts.joined(separator: " "))
        }
        
        // --- CPU ---
        var cpuParts: [String] = []
        if getBool(forKey: "cpuShowPercent") { cpuParts.append("\(cpuUsagePercent())%") }
        if getBool(forKey: "cpuShowCores") { cpuParts.append("(\(cpuCoresCount()) cores)") }
        if !cpuParts.isEmpty {
            parts.append("CPU: " + cpuParts.joined(separator: " "))
        }
        
        // Если всё выключено — показываем заглушку
        if parts.isEmpty {
            statusItem.button?.title = "MenuStats"
        } else {
            statusItem.button?.title = parts.joined(separator: " | ")
        }
    }

    @objc func quitApp() {
        NSApp.terminate(nil)
    }

    func applicationWillTerminate(_ notification: Notification) {
        timer?.invalidate()
    }
}
