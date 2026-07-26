import Foundation

extension Notification.Name {
    static let airShortcutOpenMainWindow = Notification.Name("AirShortcut.openMainWindow")
    static let airShortcutCreateRule = Notification.Name("AirShortcut.createRule")
    static let airShortcutDeleteSelectedRule = Notification.Name("AirShortcut.deleteSelectedRule")
    static let airShortcutStartCapture = Notification.Name("AirShortcut.startCapture")
    static let airShortcutStopCapture = Notification.Name("AirShortcut.stopCapture")
    static let airShortcutSelectSection = Notification.Name("AirShortcut.selectSection")
    static let airShortcutImportRules = Notification.Name("AirShortcut.importRules")
    static let airShortcutExportRules = Notification.Name("AirShortcut.exportRules")
}
