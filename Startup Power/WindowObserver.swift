import Foundation
import AppKit

class WindowObserver: ObservableObject {
    private var windowWillCloseObserver: NSObjectProtocol?
    private var mainWindow: NSWindow?

    init() {
        setupWindowObserver()
    }

    private func setupWindowObserver() {
        // Attendre que la fenêtre principale soit disponible
        DispatchQueue.main.async { [weak self] in
            self?.findMainWindow()
            self?.setupCloseObserver()
        }
    }
    
    private func findMainWindow() {
        // Trouver la fenêtre principale de l'application
        for window in NSApplication.shared.windows {
            if window.isMainWindow || window.isKeyWindow {
                mainWindow = window
                break
            }
        }
        
        // Si pas de fenêtre principale trouvée, prendre la première fenêtre visible
        if mainWindow == nil {
            mainWindow = NSApplication.shared.windows.first { $0.isVisible }
        }
    }
    
    private func setupCloseObserver() {
        windowWillCloseObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: nil,  // Observer toutes les fenêtres
            queue: .main
        ) { [weak self] notification in
            guard let self = self,
                  let closingWindow = notification.object as? NSWindow else { return }
            
            // Ne fermer l'application que si c'est notre fenêtre principale qui se ferme
            if self.isMainApplicationWindow(closingWindow) {
                NSApplication.shared.terminate(nil)
            }
        }
    }
    
    private func isMainApplicationWindow(_ window: NSWindow) -> Bool {
        // Vérifier si c'est notre fenêtre principale
        if let mainWindow = mainWindow, window == mainWindow {
            return true
        }
        
        // Méthode alternative : vérifier le type de fenêtre
        // Les fenêtres système (comme "À propos") ont souvent des caractéristiques différentes
        
        // Si c'est une fenêtre modale ou un panel, ne pas fermer l'app
        if window.isSheet || window.level != NSWindow.Level.normal {
            return false
        }
        
        // Vérifier si c'est une fenêtre de type "About" ou système
        let windowClass = String(describing: type(of: window))
        if windowClass.contains("About") || windowClass.contains("Alert") || windowClass.contains("Panel") {
            return false
        }
        
        // Si on arrive ici et qu'on a une fenêtre principale définie,
        // alors cette fenêtre n'est probablement pas notre fenêtre principale
        if mainWindow != nil {
            return false
        }
        
        // Sinon, considérer que c'est notre fenêtre principale
        return true
    }

    deinit {
        if let observer = windowWillCloseObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
