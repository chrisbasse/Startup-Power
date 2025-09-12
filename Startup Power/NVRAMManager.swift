import Foundation
import SwiftUI

class NVRAMManager: ObservableObject {
    @Published var currentSetting: PowerSettingState = .enabled
    @Published var pendingSetting: PowerSettingState = .enabled
    @Published var isLoading = false
    @Published var lastError: String?
    @Published var isAppleSilicon: Bool
    @Published var isMacBook: Bool
    @Published var isSupported: Bool

    init() {
        self.isAppleSilicon = SystemInfo.isAppleSilicon()
        self.isMacBook = SystemInfo.isMacBook()
        self.isSupported = SystemInfo.isPowerSettingsSupported()

        if isSupported {
            loadCurrentSettings()
        } else {
            lastError = String(format: NSLocalizedString("macbook_only_app", bundle: .main, comment: ""), SystemInfo.getMacModel())
        }
    }

    func loadCurrentSettings() {
        guard isSupported else { return }

        isLoading = true
        lastError = nil

        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }

            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/usr/sbin/nvram")
            task.arguments = ["-p"]

            let pipe = Pipe()
            task.standardOutput = pipe
            task.standardError = pipe

            do {
                try task.run()
                task.waitUntilExit()

                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8) ?? ""

                DispatchQueue.main.async {
                    self.parseNVRAMOutput(output)
                    self.pendingSetting = self.currentSetting
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.lastError = String(format: NSLocalizedString("nvram_read_failed", bundle: .main, comment: ""), error.localizedDescription)
                    self.isLoading = false
                }
            }
        }
    }

    private func parseNVRAMOutput(_ output: String) {
        if isAppleSilicon {
            if let bootPrefLine = output.components(separatedBy: .newlines).first(where: { $0.contains("BootPreference") }) {
                if bootPrefLine.contains("%00") {
                    currentSetting = .disabled
                } else if bootPrefLine.contains("%01") {
                    currentSetting = .plugOnly
                } else if bootPrefLine.contains("%02") {
                    currentSetting = .lidOnly
                } else {
                    currentSetting = .enabled
                }
            } else {
                currentSetting = .enabled
            }
        } else {
            if let autoBootLine = output.components(separatedBy: .newlines).first(where: { $0.contains("AutoBoot") }) {
                if autoBootLine.contains("%00") {
                    currentSetting = .disabled
                } else if autoBootLine.contains("%03") {
                    currentSetting = .enabled
                } else {
                    currentSetting = .enabled
                }
            } else {
                currentSetting = .enabled
            }
        }
    }

    func updatePendingPlugSetting(_ enabled: Bool) {
        guard isAppleSilicon else { return }

        let currentLidEnabled = pendingSetting == .enabled || pendingSetting == .lidOnly

        switch (enabled, currentLidEnabled) {
        case (true, true): pendingSetting = .enabled
        case (true, false): pendingSetting = .plugOnly
        case (false, true): pendingSetting = .lidOnly
        case (false, false): pendingSetting = .disabled
        }
    }

    func updatePendingLidSetting(_ enabled: Bool) {
        if isAppleSilicon {
            let currentPlugEnabled = pendingSetting == .enabled || pendingSetting == .plugOnly

            switch (currentPlugEnabled, enabled) {
            case (true, true): pendingSetting = .enabled
            case (true, false): pendingSetting = .plugOnly
            case (false, true): pendingSetting = .lidOnly
            case (false, false): pendingSetting = .disabled
            }
        } else {
            pendingSetting = enabled ? .enabled : .disabled
        }
    }

    var hasUnsavedChanges: Bool {
        return currentSetting != pendingSetting
    }

    func applySetting(_ setting: PowerSettingState) {
        guard isSupported && isMacBook else {
            lastError = NSLocalizedString("modification_refused", bundle: .main, comment: "")
            return
        }

        let currentModel = SystemInfo.getMacModel()
        guard SystemInfo.isMacBook() else {
            lastError = String(format: NSLocalizedString("security_nvram_blocked", bundle: .main, comment: ""), currentModel)
            return
        }

        isLoading = true
        lastError = nil

        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }

            let success: Bool

            if self.isAppleSilicon {
                success = self.applyAppleSiliconSetting(setting)
            } else {
                success = self.applyIntelSetting(setting)
            }

            DispatchQueue.main.async {
                if success {
                    self.currentSetting = setting
                    self.pendingSetting = setting
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.loadCurrentSettings()
                    }
                }
                self.isLoading = false
            }
        }
    }

    private func applyAppleSiliconSetting(_ setting: PowerSettingState) -> Bool {
        var script: String

        if setting == .enabled {
            script = "do shell script \"nvram -d BootPreference\" with administrator privileges"
        } else if let value = setting.bootPreferenceValue {
            script = "do shell script \"nvram BootPreference=\(value)\" with administrator privileges"
        } else {
            return false
        }

        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        task.arguments = ["-e", script]

        return executeNVRAMCommand(task)
    }

    private func applyIntelSetting(_ setting: PowerSettingState) -> Bool {
        guard let value = setting.autoBootValue else {
            return false
        }

        let script = "do shell script \"nvram AutoBoot=\(value)\" with administrator privileges"

        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        task.arguments = ["-e", script]

        return executeNVRAMCommand(task)
    }

    private func executeNVRAMCommand(_ task: Process) -> Bool {
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        do {
            try task.run()
            task.waitUntilExit()

            if task.terminationStatus != 0 {
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let errorOutput = String(data: data, encoding: .utf8) ?? "Unknown error"

                DispatchQueue.main.async { [weak self] in
                    self?.lastError = String(format: NSLocalizedString("command_failed", bundle: .main, comment: ""), errorOutput)
                }
                return false
            }

            return true
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.lastError = String(format: NSLocalizedString("cannot_execute_command", bundle: .main, comment: ""), error.localizedDescription)
            }
            return false
        }
    }
}
