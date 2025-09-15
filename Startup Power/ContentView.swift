import SwiftUI

struct ContentView: View {
    @StateObject private var nvramManager = NVRAMManager()
    @StateObject private var windowObserver = WindowObserver()
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 0) {
            // Header
            ZStack {
                LinearGradient(
                    colors: [Color.green.opacity(0.8), Color.green],
                    startPoint: .top,
                    endPoint: .bottom
                )

                HStack {
                    Image(systemName: "power")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)

                    Text("startup_settings", bundle: .main)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.white)

                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
            .frame(height: 80)

            // Content
            VStack(spacing: 24) {
                // System Info with fixed height for notification area
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: nvramManager.isMacBook ? "laptopcomputer" : "desktopcomputer")
                            .font(.system(size: 16))
                            .foregroundColor(nvramManager.isMacBook ? .green : .red)

                        Text("\(NSLocalizedString("system", bundle: .main, comment: "")): \(nvramManager.isAppleSilicon ? "Apple Silicon" : "Intel") \(nvramManager.isMacBook ? "MacBook" : "Mac")")
                            .font(.system(size: 14))
                            .foregroundColor(nvramManager.isMacBook ? .primary : .red)

                        Spacer()

                        if nvramManager.isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }

                    Text("\(NSLocalizedString("model", bundle: .main, comment: "")): \(SystemInfo.getMacModel())")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)

                    // Zone réservée pour la notification avec hauteur fixe
                    Group {
                        if nvramManager.hasUnsavedChanges {
                            HStack {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.orange)
                                Text("unsaved_changes", bundle: .main)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.orange)
                                Spacer()
                            }
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        } else {
                            // Spacer invisible pour maintenir la hauteur constante
                            HStack {
                                Text("")
                                    .font(.system(size: 12, weight: .medium))
                                Spacer()
                            }
                            .opacity(0)
                        }
                    }
                    .frame(height: 16) // Hauteur fixe pour éviter le mouvement
                    .animation(.easeInOut(duration: 0.2), value: nvramManager.hasUnsavedChanges)
                }

                if !nvramManager.isMacBook {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text("warning_macbook_only", bundle: .main)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.red)
                        }

                        Text(String(format: NSLocalizedString("model_not_supported", bundle: .main, comment: ""), SystemInfo.getMacModel()))
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
                }

                if nvramManager.isMacBook {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("auto_startup_description", bundle: .main)
                            .font(.system(size: 16))
                            .foregroundColor(.primary)

                        Text("modify_behavior_instruction", bundle: .main)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .italic()
                            .fixedSize(horizontal: false, vertical: true)

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "lock")
                                    .foregroundColor(.blue)
                                Text("admin_privileges_required", bundle: .main)
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(8)
                    }
                }

                Divider()
                    .padding(.vertical, 8)

                // Settings
                VStack(alignment: .leading, spacing: 16) {
                    Text("auto_start_mac", bundle: .main)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(nvramManager.isSupported ? .primary : .secondary)

                    VStack(spacing: 12) {
                        if nvramManager.isAppleSilicon {
                            PowerSettingRow(
                                icon: "cable.connector",
                                title: NSLocalizedString("on_power_cable_connect", bundle: .main, comment: ""),
                                isEnabled: nvramManager.pendingSetting == .enabled || nvramManager.pendingSetting == .plugOnly,
                                isSupported: nvramManager.isSupported,
                                isMacBook: nvramManager.isMacBook,
                                onToggle: { enabled in
                                    nvramManager.updatePendingPlugSetting(enabled)
                                }
                            )
                        }

                        PowerSettingRow(
                            icon: "laptopcomputer",
                            title: NSLocalizedString("on_lid_open", bundle: .main, comment: ""),
                            isEnabled: nvramManager.pendingSetting == .enabled || nvramManager.pendingSetting == .lidOnly,
                            isSupported: nvramManager.isSupported,
                            isMacBook: nvramManager.isMacBook,
                            onToggle: { enabled in
                                nvramManager.updatePendingLidSetting(enabled)
                            }
                        )
                    }
                }

                Spacer()

                // Action Buttons avec container à hauteur fixe
                VStack {
                    HStack(spacing: 16) {
                        Button(NSLocalizedString("cancel", bundle: .main, comment: "")) {
                            NSApplication.shared.terminate(nil)
                        }
                        .buttonStyle(.bordered)
                        .disabled(nvramManager.isLoading)
                        .keyboardShortcut(.cancelAction)

                        // Bouton Reset avec largeur réservée
                        Group {
                            if nvramManager.hasUnsavedChanges {
                                Button(NSLocalizedString("reset", bundle: .main, comment: "")) {
                                    nvramManager.pendingSetting = nvramManager.currentSetting
                                }
                                .buttonStyle(.bordered)
                                .disabled(nvramManager.isLoading)
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                            } else {
                                // Bouton invisible pour maintenir l'espacement
                                Button("") { }
                                    .buttonStyle(.bordered)
                                    .opacity(0)
                                    .disabled(true)
                            }
                        }
                        .frame(minWidth: 60) // Largeur minimale réservée
                        .animation(.easeInOut(duration: 0.2), value: nvramManager.hasUnsavedChanges)

                        Spacer()

                        Button(NSLocalizedString("apply_settings", bundle: .main, comment: "")) {
                            applySettingWithConfirmation(nvramManager.pendingSetting)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(nvramManager.isLoading || !nvramManager.isSupported || !nvramManager.hasUnsavedChanges)
                    }
                }
                .frame(height: 32) // Hauteur fixe pour les boutons
            }
            .padding(24)
        }
        .background(Color(NSColor.windowBackgroundColor))
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            if nvramManager.isSupported {
                nvramManager.loadCurrentSettings()
            }
        }
        .onChange(of: nvramManager.lastError) { error in
            if let error = error {
                alertTitle = NSLocalizedString("error", bundle: .main, comment: "")
                alertMessage = error
                showingAlert = true
            }
        }
    }

    private func applySettingWithConfirmation(_ setting: PowerSettingState) {
        guard nvramManager.isSupported && nvramManager.isMacBook else {
            alertTitle = NSLocalizedString("action_forbidden", bundle: .main, comment: "")
            alertMessage = NSLocalizedString("feature_reserved_macbook", bundle: .main, comment: "")
            showingAlert = true
            return
        }

        let alert = NSAlert()
        alert.messageText = NSLocalizedString("confirm_changes", bundle: .main, comment: "")
        alert.informativeText = String(format: NSLocalizedString("nvram_modification_warning", bundle: .main, comment: ""), setting.displayName)
        alert.alertStyle = .warning
        alert.addButton(withTitle: NSLocalizedString("apply", bundle: .main, comment: ""))
        alert.addButton(withTitle: NSLocalizedString("cancel", bundle: .main, comment: ""))

        let response = alert.runModal()

        if response == .alertFirstButtonReturn {
            nvramManager.applySetting(setting)
        }
    }
}
