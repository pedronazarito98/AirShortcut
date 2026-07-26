# Tico

Tico is a native macOS 14+ utility for matching global keyboard, mouse, and advanced trackpad gestures to local actions. The internal SwiftPM product and executable remain named `AirShortcut` for compatibility. It uses SwiftUI for the product UI, CoreGraphics for listen-only keyboard/mouse capture, an isolated private-framework bridge for raw trackpad contacts, and versioned JSON persistence in `Application Support/AirShortcut`.

## Run locally

Requirements: macOS 14+ and a Swift toolchain compatible with Swift 5.10.

```sh
./script/build_and_run.sh
```

The script builds the `AirShortcut` SwiftPM executable, stages and ad hoc signs
`dist/Tico.app`, and opens the app. The Codex environment also exposes the same
command as its **Run** action.

Create an optimized local release candidate with:

```sh
./script/build_and_run.sh --release-package
```

Without a Developer ID certificate this package is for local QA only. See
`outputs/tico-developer-id-guide.md` before distributing it to other Macs.

Useful modes:

```sh
./script/build_and_run.sh --verify
./script/build_and_run.sh --package
./script/build_and_run.sh --logs
./script/build_and_run.sh --telemetry
./script/build_and_run.sh --debug
```

Run the unit suite with `swift test`.

Rules can be backed up or restored from the **File** menu using the versioned JSON import/export commands. Imports merge by stable rule identifier so existing unrelated rules are preserved. Every imported rule is staged disabled and must be reviewed and enabled locally before it can execute.

## Permissions

Global input capture requires Input Monitoring permission. Accessibility is requested only for automation capabilities that need it. macOS permissions are granted manually in System Settings; the app includes a status screen and refresh controls.

Clicking **Iniciar captura** requests Input Monitoring automatically. If an
older ad hoc build is still listed but the permission does not take effect,
remove that old AirShortcut/Tico entry from **System Settings → Privacy &
Security → Input Monitoring**, reopen Tico, and request access once. The local
build script preserves a stable designated requirement so later rebuilds remain
the same TCC client.

When permission is already denied and Tico is missing from the list, use
**Mostrar app no Finder**, click `+` in Input Monitoring, and select that
bundle. Reopen Tico after enabling it.

The event tap is listen-only and never blocks the original key or mouse event.

## Rules, profiles, workflows, and actions

Each rule can be global, limited to a selected frontmost application, or attached to a reusable profile. Profiles combine multiple apps with window-title, display, modifier, weekday, and time-range conditions, and can be toggled from the menu bar. The editor lists apps by name while persistence keeps stable bundle identifiers. Specific contexts win over broader rules, and profile/rule priority resolves ties.

Triggers can be a single keyboard, mouse, or trackpad input, or an ordered sequence of two to five mixed inputs. Sequences support per-step modifiers, configurable timeouts, and deterministic ambiguous-prefix handling. The editor reports identical and overlapping triggers inline; saving an identical trigger offers to replace the existing rule instead of silently creating two competing rules.

Every rule owns a workflow of up to 20 ordered steps with delays, per-step and whole-workflow timeouts, cancellation, stop/continue failure policies, and step-level logs. Reusable workflows and complete gesture presets live in the local library. Actions include URLs, notifications, approved shell scripts and AppleScript, macOS Shortcuts, simulated keyboard shortcuts, clipboard changes, and native application/window operations:

- open, activate, hide, or quit a selected/frontmost app;
- close, minimize, maximize, restore, or center a window;
- move a window to halves, thirds, quarters, or another display;
- tile every controllable window belonging to the selected app.

Continuous window actions map live swipe, pinch, or rotation progress to move/resize sessions with precise, linear, or accelerated response. Cancelling the gesture restores the original frame. Application and window control use narrow `NSWorkspace` and Accessibility services. Window actions require Accessibility permission.

## Advanced global trackpad gestures

When capture starts, Tico dynamically loads Apple's private
`MultitouchSupport` framework and observes raw contacts from the default
trackpad. Frames are processed off the main thread by a session-based engine
that tracks contact transitions, extracts gesture features, evaluates
specialized recognizers, and arbitrates competing candidates. The recognizer
supports single/double/triple taps, holds, TipTap left/right, anchored
add/remove-finger gestures, ordered finger chords, directional swipes, pinch
in/out, and rotation with configurable finger ranges (2–5), start/end regions,
velocity, pressure range, sensitivity, device scope, fallback, and held
modifiers. Single taps are delayed only when a competing double/triple tap
exists. The rule editor can learn a private local template from three to five
trajectory samples; ambiguous templates are rejected instead of guessed, and
the library supports preview and duplication. If the private framework or
expected ABI is unavailable, Tico falls back to the public AppKit gesture
monitor and marks unsupported capabilities.

This mode deliberately keeps App Sandbox disabled. The private bridge is
isolated in `AirShortcutMultitouchBridge`, is loaded at runtime instead of
linked directly, and never intercepts or modifies the system gesture.
System-reserved gestures may therefore perform both the configured Tico action
and the original macOS action.

Open **Laboratório** (or press `⌘6`) to use four focused areas:

- **Ao vivo** shows contacts, pressure, centroid and contact-motion velocity, start/end regions, the accepted candidate, and explicit rejection reasons.
- **Calibração** applies persistent per-gesture conservative, balanced, responsive, or custom thresholds, including minimum/maximum velocity and confidence.
- **Sessões** records real raw frames off the main thread, anonymizes device identity, exports JSON, and imports/replays fixtures without executing rules.
- **Validação** detects local HID trackpads, tracks every current gesture, records false positives during normal use, and guides sleep/wake, reconnect, and public-fallback checks.
- **Regras** uses a when/then editor, live trigger diagnostics, configurable trackpad thresholds, device/pressure controls, and a three-to-five-sample assistant for free-form local gestures.

Rules can constrain both starting and ending positions using legacy quadrants, edges, corners, or a 3×3 grid. Replay fixtures use the same engine and current calibration, so recognition does not depend on physical hardware during automated tests.

Per-device pressure ranges are learned locally from observed frames. Rules can target any, default, built-in, or detected external trackpad and choose whether to fall back when a device disappears.

The **Métricas** area keeps a bounded local history of outcome, confidence, workflow latency, rule, gesture, and device, with filters and CSV export. Raw frames are never stored there.

Rule documents are currently version 6. Older documents are decoded, backed up beside the original file, and rewritten with workflows, profiles, conditions, templates, presets, pressure ranges, and device fallback defaults; future versions are rejected without overwriting the source.

## Safety and scope

- Shell commands and AppleScript require explicit confirmation keyed to their exact content. Changing the automation invalidates prior approval.
- User-selected rule and replay documents are size- and shape-bounded before they can enter live state.
- Shell, AppleScript, macOS Shortcuts, and workflows have timeout/cancellation paths.
- Advanced global trackpad capture uses an undocumented Apple framework and can require maintenance after macOS updates.
- Mac App Store distribution is not compatible with this experimental mode.
- The local development bundle is ad hoc signed and is not a distributable/notarized release.

See `outputs/architecture.md`, `outputs/trackpad-research.md`, and `outputs/signing-and-distribution.md` for design and release details.
