import Foundation

enum PowerSettingState: CaseIterable {
    case disabled, plugOnly, lidOnly, enabled

    var displayName: String {
        switch self {
        case .disabled:
            return NSLocalizedString("setting_disabled", bundle: .main, comment: "")
        case .plugOnly:
            return NSLocalizedString("setting_plug_only", bundle: .main, comment: "")
        case .lidOnly:
            return NSLocalizedString("setting_lid_only", bundle: .main, comment: "")
        case .enabled:
            return NSLocalizedString("setting_both_enabled", bundle: .main, comment: "")
        }
    }

    var bootPreferenceValue: String? {
        switch self {
        case .disabled: return "%00"
        case .plugOnly: return "%01"
        case .lidOnly: return "%02"
        case .enabled: return nil
        }
    }

    var autoBootValue: String? {
        switch self {
        case .disabled: return "%00"
        case .enabled: return "%03"
        default: return nil
        }
    }
}
