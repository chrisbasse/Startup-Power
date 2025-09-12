import Foundation

struct SystemInfo {
    static func isAppleSilicon() -> Bool {
        var size = 0
        sysctlbyname("hw.optional.arm64", nil, &size, nil, 0)
        return size > 0
    }

    static func getMacModel() -> String {
        var size = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        var model = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.model", &model, &size, nil, 0)
        return String(cString: model)
    }

    static func isMacBook() -> Bool {
        let model = getMacModel().lowercased()
        
        // Vérification directe par préfixes/contenus d'identifiants connus
        let portablePatterns = [
            "macbook",      // MacBook, MacBookPro, MacBookAir
            "book",         // Capture toute variation contenant "book"
        ]
        
        // Vérification des patterns
        for pattern in portablePatterns {
            if model.contains(pattern) {
                return true
            }
        }
        
        // Vérification supplémentaire par détection de batterie
        return hasBattery()
    }
    
    // Méthode simple et fiable pour détecter la présence d'une batterie
    private static func hasBattery() -> Bool {
        _ = FileManager.default
        
        // Vérifier la présence des fichiers système typiques des portables
        _ = [
            "/sys/class/power_supply/BAT0",  // Chemin Linux (ne devrait pas exister sur macOS)
            "/System/Library/PrivateFrameworks/AppleSystemInfo.framework"  // Framework Apple
        ]
        
        // Utilisation de pmset pour détecter une batterie (méthode la plus fiable sur macOS)
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/pmset")
        task.arguments = ["-g", "batt"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe() // Ignore les erreurs
        
        do {
            try task.run()
            task.waitUntilExit()
            
            if task.terminationStatus == 0 {
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8) ?? ""
                
                // Si pmset retourne des informations sur la batterie, c'est un portable
                return output.contains("Battery") ||
                       output.contains("InternalBattery") ||
                       output.contains("%)") // Pourcentage de batterie
            }
        } catch {
            // Si pmset échoue, on assume que c'est un Mac de bureau
        }
        
        return false
    }

    static func isPowerSettingsSupported() -> Bool {
        return isMacBook()
    }
}
