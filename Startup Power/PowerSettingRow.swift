import SwiftUI

struct PowerSettingRow: View {
    let icon: String
    let title: String
    let isEnabled: Bool
    let isSupported: Bool
    let isMacBook: Bool
    let onToggle: (Bool) -> Void

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(effectiveSupport ? .green : .secondary)
                .frame(width: 20, height: 20)

            Text(title)
                .font(.system(size: 16))
                .foregroundColor(effectiveSupport ? .primary : .secondary)

            Spacer()

            Toggle("", isOn: Binding(
                get: { effectiveSupport && isEnabled },
                set: { newValue in
                    if effectiveSupport {
                        onToggle(newValue)
                    }
                }
            ))
            .disabled(!effectiveSupport)
            .toggleStyle(.switch)
        }
        .opacity(effectiveSupport ? 1.0 : 0.6)
    }

    private var effectiveSupport: Bool {
        return isSupported && isMacBook
    }
}
