import Foundation
import AppKit

class WindowObserver: ObservableObject {
    private var windowWillCloseObserver: NSObjectProtocol?

    init() {
        setupWindowObserver()
    }

    private func setupWindowObserver() {
        windowWillCloseObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: nil,
            queue: .main
        ) { _ in
            NSApplication.shared.terminate(nil)
        }
    }

    deinit {
        if let observer = windowWillCloseObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
