import Combine
import Foundation

final class TrackpadValidationStore: ObservableObject {
    @Published private(set) var report: TrackpadValidationReport {
        didSet { persist() }
    }
    @Published private(set) var lastAcceptedGesture: TrackpadGesture?

    private let defaults: UserDefaults
    private let storageKey: String

    init(
        defaults: UserDefaults = .standard,
        storageKey: String = TicoBrand.legacyUserDefaultsPrefix + "trackpad-validation"
    ) {
        self.defaults = defaults
        self.storageKey = storageKey
        if let data = defaults.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(TrackpadValidationReport.self, from: data) {
            var value = decoded
            // A running timer cannot survive process termination accurately.
            value.normalUseStartedAt = nil
            report = value
        } else {
            report = TrackpadValidationReport()
        }
    }

    func record(_ snapshot: TrackpadLaboratorySnapshot, acceptedEvent: GestureEvent?) {
        if let acceptedEvent {
            report.recognizedByGesture[acceptedEvent.kind, default: 0] += 1
            lastAcceptedGesture = acceptedEvent.kind
        } else if snapshot.phase == .ended {
            switch snapshot.diagnostic.outcome {
            case .rejected:
                report.rejectedSessionCount += 1
            case .ignored:
                report.ignoredSessionCount += 1
            case .inProgress, .accepted, .cancelled:
                break
            }
        }
        report.updatedAt = Date()
    }

    func recordPublicFallbackGesture(_ gesture: TrackpadGesture) {
        report.recognizedByGesture[gesture, default: 0] += 1
        report.completedChecks.insert(.publicFallback)
        lastAcceptedGesture = gesture
        report.updatedAt = Date()
    }

    func markLastRecognitionAsFalsePositive() {
        guard let lastAcceptedGesture else { return }
        report.falsePositivesByGesture[lastAcceptedGesture, default: 0] += 1
        report.updatedAt = Date()
    }

    func setCheck(_ check: HardwareValidationCheck, completed: Bool) {
        if completed {
            report.completedChecks.insert(check)
        } else {
            report.completedChecks.remove(check)
        }
        report.updatedAt = Date()
    }

    func startNormalUseMonitoring() {
        guard report.normalUseStartedAt == nil else { return }
        report.normalUseStartedAt = Date()
        report.updatedAt = Date()
    }

    func stopNormalUseMonitoring() {
        guard let startedAt = report.normalUseStartedAt else { return }
        report.accumulatedNormalUseDuration += Date().timeIntervalSince(startedAt)
        report.normalUseStartedAt = nil
        report.completedChecks.insert(.normalUse)
        report.updatedAt = Date()
    }

    func reset() {
        report = TrackpadValidationReport()
        lastAcceptedGesture = nil
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(report) {
            defaults.set(data, forKey: storageKey)
        }
    }
}
