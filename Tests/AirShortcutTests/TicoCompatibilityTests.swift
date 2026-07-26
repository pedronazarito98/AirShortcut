import Foundation
import XCTest
@testable import AirShortcut

final class TicoCompatibilityTests: XCTestCase {
    private var temporaryDirectories: [URL] = []
    private var defaultsSuites: [String] = []

    override func tearDown() {
        for directory in temporaryDirectories {
            try? FileManager.default.removeItem(at: directory)
        }
        for suite in defaultsSuites {
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }
        super.tearDown()
    }

    func testDefaultStorePathsKeepLegacyApplicationSupportDirectory() {
        let expectedDirectory = TicoBrand.legacyApplicationSupportDirectoryName

        XCTAssertEqual(
            ShortcutStore.defaultFileURL().deletingLastPathComponent().lastPathComponent,
            expectedDirectory
        )
        XCTAssertEqual(
            EventLogStore.defaultFileURL().deletingLastPathComponent().lastPathComponent,
            expectedDirectory
        )
        XCTAssertEqual(
            MetricsStore.defaultFileURL().deletingLastPathComponent().lastPathComponent,
            expectedDirectory
        )
    }

    func testTicoLoadsCompleteAirShortcutInstallationWithoutMovingData() throws {
        let root = makeTemporaryDirectory()
        let legacyDirectory = root.appendingPathComponent(
            TicoBrand.legacyApplicationSupportDirectoryName,
            isDirectory: true
        )
        let renamedDirectory = root.appendingPathComponent(TicoBrand.displayName, isDirectory: true)
        let shortcutsURL = legacyDirectory.appendingPathComponent("shortcuts.json")
        let logURL = legacyDirectory.appendingPathComponent("execution-log.json")
        let metricsURL = legacyDirectory.appendingPathComponent("metrics.json")

        let legacyShortcutStore = ShortcutStore(fileURL: shortcutsURL, seedExamples: false)
        let profile = ShortcutProfile(
            name: "Perfil legado",
            applicationBundleIdentifiers: ["com.apple.Preview"],
            priority: 4
        )
        let workflow = ActionWorkflow(
            name: "Workflow legado",
            steps: [
                WorkflowStep(action: .setClipboard(text: "compatível")),
                WorkflowStep(action: .notification(title: "AirShortcut", body: "Concluído"))
            ]
        )
        let template = makeGestureTemplate()
        let preset = GesturePreset(
            name: "Preset legado",
            trigger: .customTrackpad(template: template),
            workflow: workflow,
            profileID: profile.id,
            createdAt: Date(timeIntervalSince1970: 1_800_000_000)
        )
        let rule = ShortcutRule(
            name: "Regra legada completa",
            trigger: .customTrackpad(template: template),
            action: .setClipboard(text: "compatível"),
            workflow: workflow,
            profileID: profile.id,
            createdAt: Date(timeIntervalSince1970: 1_800_000_000),
            updatedAt: Date(timeIntervalSince1970: 1_800_000_000)
        )

        try legacyShortcutStore.addProfile(profile)
        try legacyShortcutStore.saveReusableWorkflow(workflow)
        try legacyShortcutStore.saveCustomGestureTemplate(template)
        try legacyShortcutStore.savePreset(preset)
        try legacyShortcutStore.add(rule)

        let legacyLogStore = EventLogStore(fileURL: logURL)
        try legacyLogStore.record(rule: rule, result: .succeeded("Executada"))

        let legacyMetricsStore = MetricsStore(fileURL: metricsURL)
        legacyMetricsStore.record(GestureMetricEvent(
            ruleID: rule.id,
            ruleName: rule.name,
            gesture: .swipeRight,
            outcome: .success,
            confidence: 0.91,
            latency: 0.012
        ))

        let ticoShortcutStore = ShortcutStore(fileURL: shortcutsURL, seedExamples: false)
        let ticoLogStore = EventLogStore(fileURL: logURL)
        let ticoMetricsStore = MetricsStore(fileURL: metricsURL)

        XCTAssertEqual(ticoShortcutStore.rules, [rule])
        XCTAssertEqual(ticoShortcutStore.profiles, [profile])
        XCTAssertEqual(ticoShortcutStore.reusableWorkflows, [workflow])
        XCTAssertEqual(ticoShortcutStore.customGestureTemplates, [template])
        XCTAssertEqual(ticoShortcutStore.presets, [preset])
        XCTAssertEqual(ticoLogStore.entries.map(\.ruleID), [rule.id])
        XCTAssertEqual(ticoMetricsStore.events.map(\.ruleID), [rule.id])
        XCTAssertTrue(FileManager.default.fileExists(atPath: shortcutsURL.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: renamedDirectory.path))
    }

    func testTicoReadsAndContinuesWritingLegacyUserDefaultsKeys() {
        let defaults = makeDefaults()
        let prefix = TicoBrand.legacyUserDefaultsPrefix + "settings."
        defaults.set(true, forKey: prefix + "launchAtLogin")
        defaults.set(false, forKey: prefix + "showMenuBarExtra")
        defaults.set(true, forKey: prefix + "startEventCaptureOnLaunch")

        let settings = AppSettingsStore(defaults: defaults)

        XCTAssertTrue(settings.launchAtLogin)
        XCTAssertFalse(settings.showMenuBarExtra)
        XCTAssertTrue(settings.startEventCaptureOnLaunch)

        settings.showMenuBarExtra = true

        XCTAssertEqual(defaults.object(forKey: prefix + "showMenuBarExtra") as? Bool, true)
        XCTAssertEqual(
            defaults.integer(forKey: prefix + "version"),
            AppSettingsStore.currentSettingsVersion
        )
        XCTAssertNil(defaults.object(forKey: "com.tico.settings.showMenuBarExtra"))
    }

    @MainActor
    func testAuxiliaryStoresKeepLegacyUserDefaultsKeys() {
        let defaults = makeDefaults()

        let calibration = GestureCalibration(
            preset: .custom,
            sensitivity: 1.4,
            minimumVelocity: 0.08,
            confidenceThreshold: 0.63
        )
        TrackpadCalibrationStore(defaults: defaults).update(calibration, for: .swipeRight)
        TrackpadValidationStore(defaults: defaults).recordPublicFallbackGesture(.pinchOut)
        AutomationApprovalStore(defaults: defaults).approve("tell application \"Finder\"")

        let capabilityStore = TrackpadCapabilityStore(defaults: defaults)
        for _ in 0..<10 {
            capabilityStore.observe(deviceID: "legacy-trackpad", pressure: 0.42)
        }

        let reloadedCalibration = TrackpadCalibrationStore(defaults: defaults)
        let reloadedValidation = TrackpadValidationStore(defaults: defaults)
        let reloadedApprovals = AutomationApprovalStore(defaults: defaults)
        let reloadedCapabilities = TrackpadCapabilityStore(defaults: defaults)

        XCTAssertEqual(reloadedCalibration.calibration(for: .swipeRight), calibration)
        XCTAssertEqual(reloadedValidation.report.recognizedByGesture[.pinchOut], 1)
        XCTAssertTrue(reloadedApprovals.isApproved("tell application \"Finder\""))
        XCTAssertEqual(reloadedCapabilities.devices["legacy-trackpad"]?.pressureSampleCount, 10)
        XCTAssertNotNil(defaults.data(
            forKey: TicoBrand.legacyUserDefaultsPrefix + "trackpad-calibration"
        ))
        XCTAssertNil(defaults.data(forKey: "com.tico.trackpad-calibration"))
    }

    private func makeGestureTemplate() -> CustomGestureTemplate {
        let points = [
            TrackpadPoint(x: 0, y: 0),
            TrackpadPoint(x: 0.5, y: 1),
            TrackpadPoint(x: 1, y: 0)
        ]
        let normalized = CustomGesturePath.normalized(
            points,
            pointCount: CustomGestureTemplate.defaultPointCount
        )!
        return CustomGestureTemplate(
            name: "Gesto legado",
            fingerCount: 3...3,
            samplePaths: [normalized, normalized, normalized],
            createdAt: Date(timeIntervalSince1970: 1_800_000_000)
        )
    }

    private func makeTemporaryDirectory() -> URL {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("TicoCompatibility-\(UUID().uuidString)", isDirectory: true)
        temporaryDirectories.append(directory)
        return directory
    }

    private func makeDefaults() -> UserDefaults {
        let suite = "TicoCompatibility.\(UUID().uuidString)"
        defaultsSuites.append(suite)
        UserDefaults.standard.removePersistentDomain(forName: suite)
        return UserDefaults(suiteName: suite)!
    }
}
