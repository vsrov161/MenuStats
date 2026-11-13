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

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("--- ПРИЛОЖЕНИЕ ЗАПУСТИЛОСЬ ---")
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.title = "ТЕСТ"
            print("--- КНОПКА СОЗДАНА ---")
            button.action = #selector(quitApp)
            button.target = self
        }

        updateStats()
        
        timer = Timer.scheduledTimer(timeInterval: 2.0,
                                     target: self,
                                     selector: #selector(updateStats),
                                     userInfo: nil,
                                     repeats: true)
    }

    @objc func updateStats() {
        let mem = memoryUsagePercent()
        let disk = freeDiskSpace()
        statusItem.button?.title = "\(mem)% | \(disk)"
    }

    @objc func quitApp() {
        NSApp.terminate(nil)
    }

    func applicationWillTerminate(_ notification: Notification) {
        timer?.invalidate()
    }
}
