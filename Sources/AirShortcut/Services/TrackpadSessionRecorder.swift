import Foundation

final class TrackpadSessionRecorder: @unchecked Sendable {
    private let lock = NSLock()
    private var name = "Sessão do Trackpad"
    private var frames: [RawTrackpadFrame] = []
    private var recording = false

    func start(name: String) {
        lock.lock()
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "Sessão do Trackpad"
            : name
        frames = []
        recording = true
        lock.unlock()
    }

    func append(_ frame: RawTrackpadFrame) {
        lock.lock()
        if recording, frames.count < TrackpadReplayDocument.maximumFrameCount {
            var anonymized = frame
            anonymized.touches = Array(
                anonymized.touches.prefix(TrackpadReplayDocument.maximumTouchesPerFrame)
            )
            if anonymized.deviceID != nil {
                anonymized.deviceID = "recorded-device"
            }
            frames.append(anonymized)
        }
        lock.unlock()
    }

    func frameCount() -> Int {
        lock.lock()
        defer { lock.unlock() }
        return frames.count
    }

    func stop() -> TrackpadReplayDocument? {
        lock.lock()
        defer { lock.unlock() }
        recording = false
        guard !frames.isEmpty else {
            frames = []
            return nil
        }
        let document = TrackpadReplayDocument(name: name, frames: frames)
        frames = []
        return document
    }

    func cancel() {
        lock.lock()
        recording = false
        frames = []
        lock.unlock()
    }
}
