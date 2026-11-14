//
//  SettingsWindowController.swift
//  MenuStats
//
//  Created by Vic on 14.11.2026.
//

import Cocoa

class SettingsWindowController: NSWindowController {
    
    // Чекбоксы (сохраняем ссылки, чтобы читать их состояние)
    var ramShowPercent: NSButton!
    var ramShowMB: NSButton!
    
    var hddShowPercent: NSButton!
    var hddShowGB: NSButton!
    
    var cpuShowPercent: NSButton!
    var cpuShowCores: NSButton!
    
    convenience init() {
        // Создаем небольшое окно по центру
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 350, height: 250),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Настройки MenuStats"
        window.center() // Ставим по центру экрана
        
        self.init(window: window)
        setupUI()
    }
    
    func setupUI() {
        guard let contentView = window?.contentView else { return }
        
        // Создаем вкладки
        let tabView = NSTabView(frame: contentView.bounds)
        tabView.autoresizingMask = [.width, .height]
        contentView.addSubview(tabView)
        
        // --- Вкладка GENERAL ---
        let generalTab = NSTabViewItem(identifier: "general")
        generalTab.label = "General"
        generalTab.view = createGeneralView()
        tabView.addTabViewItem(generalTab)
        
        // --- Вкладка RAM ---
        let ramTab = NSTabViewItem(identifier: "ram")
        ramTab.label = "RAM"
        ramTab.view = createCheckboxView(items: [
            ("Show %", #selector(ramShowPercentChanged)),
            ("Show MB", #selector(ramShowMBChanged))
        ])
        // Привязываем чекбоксы
        let ramSubviews = ramTab.view!.subviews
        ramShowPercent = ramSubviews[0] as? NSButton
        ramShowMB = ramSubviews[1] as? NSButton
        tabView.addTabViewItem(ramTab)
        
        // --- Вкладка HDD ---
        let hddTab = NSTabViewItem(identifier: "hdd")
        hddTab.label = "HDD"
        hddTab.view = createCheckboxView(items: [
            ("Show %", #selector(hddShowPercentChanged)),
            ("Show GBs", #selector(hddShowGBChanged))
        ])
        let hddSubviews = hddTab.view!.subviews
        hddShowPercent = hddSubviews[0] as? NSButton
        hddShowGB = hddSubviews[1] as? NSButton
        tabView.addTabViewItem(hddTab)
        
        // --- Вкладка CPU ---
        let cpuTab = NSTabViewItem(identifier: "cpu")
        cpuTab.label = "CPU"
        cpuTab.view = createCheckboxView(items: [
            ("Show %", #selector(cpuShowPercentChanged)),
            ("Show Cores", #selector(cpuShowCoresChanged))
        ])
        let cpuSubviews = cpuTab.view!.subviews
        cpuShowPercent = cpuSubviews[0] as? NSButton
        cpuShowCores = cpuSubviews[1] as? NSButton
        tabView.addTabViewItem(cpuTab)
        
        // Загружаем сохраненные настройки
        loadSettings()
    }
    
    // Вспомогательная функция для создания вкладки GENERAL
    func createGeneralView() -> NSView {
        let view = NSView()
        let label = NSTextField(labelWithString: "Настройки отображения виджета.\nИзменения применяются мгновенно.")
        label.frame = NSRect(x: 20, y: 100, width: 300, height: 60)
        label.alignment = .center
        view.addSubview(label)
        return view
    }
    
    // Вспомогательная функция для создания вкладок с чекбоксами в столбик
    func createCheckboxView(items: [(String, Selector)]) -> NSView {
        let view = NSView()
        var yPos: CGFloat = 160 // Начинаем сверху
        
        for item in items {
            let checkbox = NSButton(checkboxWithTitle: item.0, target: self, action: item.1)
            checkbox.frame = NSRect(x: 30, y: yPos, width: 200, height: 20)
            view.addSubview(checkbox)
            yPos -= 30 // Шаг вниз для следующего чекбокса
        }
        return view
    }
    
    // --- Действия при клике на чекбоксы ---
    @objc func ramShowPercentChanged() { saveSettings() }
    @objc func ramShowMBChanged() { saveSettings() }
    @objc func hddShowPercentChanged() { saveSettings() }
    @objc func hddShowGBChanged() { saveSettings() }
    @objc func cpuShowPercentChanged() { saveSettings() }
    @objc func cpuShowCoresChanged() { saveSettings() }
    
    // --- Сохранение и загрузка ---
    func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(ramShowPercent.state == .on, forKey: "ramShowPercent")
        defaults.set(ramShowMB.state == .on, forKey: "ramShowMB")
        
        defaults.set(hddShowPercent.state == .on, forKey: "hddShowPercent")
        defaults.set(hddShowGB.state == .on, forKey: "hddShowGB")
        
        defaults.set(cpuShowPercent.state == .on, forKey: "cpuShowPercent")
        defaults.set(cpuShowCores.state == .on, forKey: "cpuShowCores")
        
        // Отправляем уведомление главному окну, что настройки изменились
        NotificationCenter.default.post(name: Notification.Name("SettingsChanged"), object: nil)
    }
    
    func loadSettings() {
        let defaults = UserDefaults.standard
        
        func getBool(forKey key: String) -> Bool {
            if defaults.object(forKey: key) == nil { return true }
            return defaults.bool(forKey: key)
        }
        
        ramShowPercent.state = getBool(forKey: "ramShowPercent") ? .on : .off
        ramShowMB.state = getBool(forKey: "ramShowMB") ? .on : .off
        hddShowPercent.state = getBool(forKey: "hddShowPercent") ? .on : .off
        hddShowGB.state = getBool(forKey: "hddShowGB") ? .on : .off
        cpuShowPercent.state = getBool(forKey: "cpuShowPercent") ? .on : .off
        cpuShowCores.state = getBool(forKey: "cpuShowCores") ? .on : .off
    }
}
