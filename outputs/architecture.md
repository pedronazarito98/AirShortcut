# AirShortcut architecture

AirShortcut is a native macOS 14+ SwiftUI application packaged from SwiftPM. The main window and menu bar extra share app-wide stores and platform services, while each window owns its navigation selection.

## Boundaries

- `Models`: Codable domain values with no SwiftUI, AppKit, or CoreGraphics dependencies.
- `Stores`: rule persistence, app settings, per-gesture calibration, hardware-validation progress, and the bounded recent-event log.
- `Services`: permission checks, event capture, matching, action execution, advanced trackpad recognition, replay, and OS integrations.
- `AirShortcutMultitouchBridge`: narrow C boundary that dynamically loads the private trackpad framework and emits normalized raw contacts.
- `Views`: desktop navigation, rule editing, permissions, recording, logs, settings, and menu bar affordances.
- `App`: lifecycle, scenes, commands, and dependency composition.
- `Support`: structured logging and small presentation helpers.

The global event tap is listen-only. It emits normalized `InputEventDescriptor` values; `TriggerMatcher` remains pure, and `ActionRunner` receives only matched actions. No CoreGraphics event crosses into the UI.

## Data flow

1. `PermissionCoordinator` verifies Input Monitoring before capture starts.
2. `GlobalEventTapService` normalizes keyboard and extra-mouse-button events.
3. `TrackpadGestureService` selects `MultitouchFrameProvider` or the public fallback. Raw frames are sent to a dedicated serial worker, never processed by `AppController`.
4. `ContactSessionEngine` emits contact lifecycle snapshots; `GestureFeatureExtractor` calculates geometry, velocity, pressure, and regions without classifying.
5. Specialized tap/hold, advanced-finger, directional, and pinch/rotation recognizers use the persisted calibration for their target gesture. Transition history distinguishes TipTap, stable add/remove-finger gestures, and time-ordered chords without reclassifying ordinary multi-finger swipes.
6. `GestureDiagnosticBuilder` explains accepted, rejected, ignored, in-progress, and cancelled sessions using the actual measurements and thresholds.
7. `TrackpadSessionRecorder` copies raw frames on the provider thread, anonymizes device identity, and produces a versioned replay document. Raw frames still never reach `AppController`.
8. Imported and recorded documents use a separate replay worker; snapshots are visible in the laboratory, but replay events never enter the live rule handler.
9. The recorder may consume the compatible `InputEventDescriptor` projection to populate an editor. The laboratory receives coalesced semantic snapshots at no more than display-relevant frequency.
10. `TrackpadHardwareDetector` enumerates HID touchpads for diagnostics. Device identity from the private capture ABI remains intentionally unclaimed.
11. `ContextSnapshotService` captures the frontmost application and held modifiers once per input. `TriggerSequenceRuntime` evaluates app scope, simple triggers, mixed two-to-five-step sequences, tap prefixes, timeouts, and explicit priority.
12. `RuleConflictAnalyzer` detects identical triggers, overlapping trackpad ranges, ambiguous sequence prefixes, and global/app-specific shadowing before persistence.
13. `ActionRunner` delegates to narrow launcher, notification, script, application-control, and Accessibility window-control services.
14. Results are appended to the recent-event log and surfaced in the UI.

Shell actions require an explicit user confirmation path. The MVP does not intercept or suppress system input.

## Persistence

Rules are stored as versioned JSON under Application Support. Version 5 includes `TrackpadTriggerSpec` advanced-finger/tap metadata, mixed trigger sequences, application scope, priority, and native app/window actions. Loading an older document creates an idempotent versioned backup before rewriting it; a future version is rejected without modifying the file. Calibration and validation summaries use separate versioned preferences. Explicitly recorded laboratory sessions are portable JSON; raw frames are otherwise never persisted.

## Platform stance

The app is intentionally outside App Sandbox because global input observation, arbitrary local processes, and the experimental private trackpad provider do not fit a conventional App Store product. Direct distribution should use Developer ID, Hardened Runtime, and notarization after a stable signing identity and bundle identifier are chosen.
