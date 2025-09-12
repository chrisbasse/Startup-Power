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
        let macbookModels = ["macbook", "macbookpro", "macbookair"]
        return macbookModels.contains { model.contains($0) }
    }

    static func isPowerSettingsSupported() -> Bool {
        return isMacBook()
    }
}
