//
//  Startup_PowerApp.swift
//  Startup Power
//
//  Created by Christophe BASSETTE on 11/09/2025.
//

import SwiftUI

@main
struct PowerSettingsApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 650, height: 580)
        }
        .windowResizability(.contentSize)
        .commands {
            // Personnaliser les menus pour éviter les conflits
            CommandGroup(replacing: .appInfo) {
                Button("À propos de Startup Power") {
                    showAboutPanel()
                }
            }
        }
    }
    
    private func showAboutPanel() {
        let aboutPanel = NSAlert()
        aboutPanel.messageText = "Startup Power"
        aboutPanel.informativeText = """
        An application to manage the automatic starting settings of your Mac.
        
        Une application pour gérer les paramètres de démarrage automatique de votre Mac.
        
        Version 1.0
        © 2025 Christophe BASSETTE
        """
        aboutPanel.alertStyle = .informational
        aboutPanel.addButton(withTitle: "OK")
        
        // S'assurer que le panel apparaît au premier plan
        if let window = NSApplication.shared.windows.first {
            aboutPanel.beginSheetModal(for: window) { _ in
                // Ne rien faire quand le panel se ferme
            }
        } else {
            aboutPanel.runModal()
        }
    }
}

// Delegate pour mieux contrôler le comportement de l'application
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // L'application se ferme quand la dernière fenêtre se ferme
        return true
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // Rouvrir la fenêtre si l'utilisateur clique sur l'icône dans le Dock
        if !flag {
            NSApplication.shared.windows.first?.makeKeyAndOrderFront(nil)
        }
        return true
    }
}
