import SwiftUI

@main
@MainActor
struct AirShortcutApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    @StateObject private var shortcutStore: ShortcutStore
    @StateObject private var settings: AppSettingsStore
    @StateObject private var eventLogStore: EventLogStore
    @StateObject private var permissions: PermissionCoordinator
    @StateObject private var calibrationStore: TrackpadCalibrationStore
    @StateObject private var validationStore: TrackpadValidationStore
    @StateObject private var controller: AppController

    init() {
        let shortcutStore: ShortcutStore = ShortcutStore()
        let settings: AppSettingsStore = AppSettingsStore()
        let eventLogStore: EventLogStore = EventLogStore()
        let permissions: PermissionCoordinator = PermissionCoordinator()
        let calibrationStore: TrackpadCalibrationStore = TrackpadCalibrationStore()
        let validationStore: TrackpadValidationStore = TrackpadValidationStore()
        _shortcutStore = StateObject(wrappedValue: shortcutStore)
        _settings = StateObject(wrappedValue: settings)
        _eventLogStore = StateObject(wrappedValue: eventLogStore)
        _permissions = StateObject(wrappedValue: permissions)
        _calibrationStore = StateObject(wrappedValue: calibrationStore)
        _validationStore = StateObject(wrappedValue: validationStore)
        _controller = StateObject(
            wrappedValue: AppController(
                shortcutStore: shortcutStore,
                settings: settings,
                eventLogStore: eventLogStore,
                permissions: permissions,
                calibrationStore: calibrationStore,
                validationStore: validationStore
            )
        )
    }

    var body: some Scene {
        WindowGroup("AirShortcut", id: "main") {
            ContentView(
                controller: controller,
                shortcutStore: shortcutStore,
                eventLogStore: eventLogStore,
                permissions: permissions
            )
        }
        .defaultSize(width: 1_080, height: 700)
        .commands {
            AirShortcutCommands()
        }

        Settings {
            SettingsView(settings: settings)
        }

        MenuBarExtra(
            "AirShortcut",
            systemImage: controller.captureIsRunning ? "bolt.circle.fill" : "bolt.circle",
            isInserted: menuBarExtraIsInserted
        ) {
            MenuBarContentView(controller: controller, shortcutStore: shortcutStore)
        }
    }

    private var menuBarExtraIsInserted: Binding<Bool> {
        Binding(
            get: { settings.showMenuBarExtra },
            set: { isInserted in
                // MenuBarExtra may write its current value while SwiftUI is
                // updating scenes. Re-publishing an unchanged value creates a
                // scene-update feedback loop and freezes the whole app.
                guard settings.showMenuBarExtra != isInserted else { return }
                settings.showMenuBarExtra = isInserted
            }
        )
    }
}
