import AppKit
import ApplicationServices
import Foundation

struct WindowContext: Equatable, Sendable {
    var title: String?
    var displayIdentifier: String?
}

protocol WindowContextReading {
    func focusedWindowContext(processIdentifier: pid_t) -> WindowContext
}

final class WindowContextReader: WindowContextReading {
    private let accessibilityCheck: () -> Bool

    init(accessibilityCheck: @escaping () -> Bool = AXIsProcessTrusted) {
        self.accessibilityCheck = accessibilityCheck
    }

    func focusedWindowContext(processIdentifier: pid_t) -> WindowContext {
        guard accessibilityCheck() else { return WindowContext() }
        let app = AXUIElementCreateApplication(processIdentifier)
        var focusedValue: CFTypeRef?
        guard AXUIElementCopyAttributeValue(
            app,
            kAXFocusedWindowAttribute as CFString,
            &focusedValue
        ) == .success,
        let window = focusedValue as! AXUIElement? else {
            return WindowContext()
        }

        var titleValue: CFTypeRef?
        AXUIElementCopyAttributeValue(
            window,
            kAXTitleAttribute as CFString,
            &titleValue
        )
        return WindowContext(
            title: titleValue as? String,
            displayIdentifier: displayIdentifier(for: window)
        )
    }

    private func displayIdentifier(for window: AXUIElement) -> String? {
        var positionValue: CFTypeRef?
        var sizeValue: CFTypeRef?
        guard AXUIElementCopyAttributeValue(
            window,
            kAXPositionAttribute as CFString,
            &positionValue
        ) == .success,
        AXUIElementCopyAttributeValue(
            window,
            kAXSizeAttribute as CFString,
            &sizeValue
        ) == .success,
        let positionAXValue = positionValue as! AXValue?,
        let sizeAXValue = sizeValue as! AXValue? else {
            return nil
        }
        var origin = CGPoint.zero
        var size = CGSize.zero
        AXValueGetValue(positionAXValue, .cgPoint, &origin)
        AXValueGetValue(sizeAXValue, .cgSize, &size)
        let center = CGPoint(x: origin.x + size.width / 2, y: origin.y + size.height / 2)

        return NSScreen.screens.first { screen in
            let appKitPoint = CGPoint(x: center.x, y: screen.frame.maxY - center.y)
            return screen.frame.contains(appKitPoint)
        }?.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")]
            .map { String(describing: $0) }
    }
}

