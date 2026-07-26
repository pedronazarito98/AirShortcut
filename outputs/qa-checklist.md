# Tico QA checklist

Use one row per observed result. Allowed statuses are `PASS`, `FAIL`, and
`NOT-RUN`. `NOT-RUN` means the scenario was not executed or the required
hardware was unavailable; it is never equivalent to `PASS`. Replace the
placeholder in **Observed** and add objective notes before changing a status.

## Automated gate

Run `./script/ci_verify.sh --package` without opening the app.

| Scenario | Expected | Observed | Status | Notes |
| --- | --- | --- | --- | --- |
| Shared build/test gate | Build, complete Swift suite, and security regressions pass with a reported test count | Not executed in this session | NOT-RUN | Attach the command result or CI run |
| Ad hoc package | Extracted `dist/Tico.zip` contains `Tico.app` and passes strict signature verification | Not executed in this session | NOT-RUN | This does not prove Developer ID or notarization |
| Public and technical identity | Bundle displays `Tico`, keeps executable `AirShortcut` and bundle identifier `com.pedronazarito.AirShortcut`, and embeds `Tico.icns` | Not executed in this session | NOT-RUN | Run the plist and resource assertions from `TicoCompatibilityTests` |
| Release candidate | `./script/build_and_run.sh --release-package` creates an optimized `dist/Tico.zip` | Not executed in this session | NOT-RUN | An ad hoc release candidate remains local-only |

For a public release, additionally require:

- a `Developer ID Application` identity in the Keychain;
- `TICO_NOTARYTOOL_PROFILE` configured;
- `./script/notarize_release.sh` completes successfully;
- `spctl` reports `accepted` and `Notarized Developer ID`.

Automated success does not validate physical trackpad behavior. Continue with
the manual gates on the target Mac and device.

## Manual gate: permissions and input safety

| Scenario | Expected | Observed | Status | Notes |
| --- | --- | --- | --- | --- |
| Main window | The staged app opens and brings its main window forward | Not executed in this session | NOT-RUN | Record macOS version |
| Permission state | Accessibility and Input Monitoring show their current system state | Not executed in this session | NOT-RUN | Do not attach TCC dumps |
| Input Monitoring denied | Capture stays stopped and an explanation is visible | Not executed in this session | NOT-RUN | Test before granting permission |
| Permission refresh | Granting permission and refreshing updates the app state | Not executed in this session | NOT-RUN | Reopen the app when macOS requires it |
| Keyboard pass-through | A captured keyboard event still reaches the original app | Not executed in this session | NOT-RUN | Capture must remain listen-only |
| Mouse pass-through | A captured mouse event still reaches the original app | Not executed in this session | NOT-RUN | Include an extra button when available |

## Manual gate: advanced trackpad

Open **Laboratório** with `⌘6`. Record the device as `internal`,
`magic-trackpad`, or another non-identifying class. Validate each connected
device separately.

| Scenario | Expected | Observed | Status | Notes |
| --- | --- | --- | --- | --- |
| Advanced capability | Overview reports advanced private capture when the framework, ABI, permission, and device are available | Not executed in this session | NOT-RUN | A fallback result is not an advanced PASS |
| Tap | Validation accepts the configured tap once | Not executed in this session | NOT-RUN | Record finger count |
| Hold | Validation fires once while contacts remain down | Not executed in this session | NOT-RUN | Confirm no repeated firing |
| Swipe left | Validation accepts a left swipe with the expected fingers | Not executed in this session | NOT-RUN | Record rejection reason on failure |
| Swipe right | Validation accepts a right swipe with the expected fingers | Not executed in this session | NOT-RUN | Record rejection reason on failure |
| Swipe up | Validation accepts an upward swipe with the expected fingers | Not executed in this session | NOT-RUN | Record rejection reason on failure |
| Swipe down | Validation accepts a downward swipe with the expected fingers | Not executed in this session | NOT-RUN | Record rejection reason on failure |
| Pinch in | Validation accepts pinch-in and reports coherent progress | Not executed in this session | NOT-RUN | Record finger count |
| Pinch out | Validation accepts pinch-out and reports coherent progress | Not executed in this session | NOT-RUN | Record finger count |
| Clockwise rotation | Validation accepts clockwise rotation and reports coherent progress | Not executed in this session | NOT-RUN | Record finger count |
| Counterclockwise rotation | Validation accepts counterclockwise rotation and reports coherent progress | Not executed in this session | NOT-RUN | Record finger count |
| Sleep and wake | Raw capture resumes after a real sleep/wake cycle | Not executed in this session | NOT-RUN | A simulated pause is insufficient |
| Device reconnection | Disconnecting and reconnecting an external trackpad keeps the app responsive and restores or explains capture | Not executed in this session | NOT-RUN | Mark NOT-RUN when no external device exists |
| Public fallback | Forced fallback accepts supported public gestures and labels unavailable capabilities | Not executed in this session | NOT-RUN | Run `./script/build_and_run.sh --fallback-diagnostic` |
| Fallback input safety | Keyboard and mouse capture remain listen-only while fallback is active | Not executed in this session | NOT-RUN | Confirm original input is not consumed |
| False-positive observation | Normal use completes for the chosen duration with every accidental recognition recorded | Not executed in this session | NOT-RUN | Record duration and objective count |

## Manual gate: replay isolation

| Scenario | Expected | Observed | Status | Notes |
| --- | --- | --- | --- | --- |
| Record/export/import | A real session increases frame count and round-trips as sanitized JSON | Not executed in this session | NOT-RUN | Do not commit raw personal sessions |
| Replay 0.5× | Laboratory state and progress update without an action log entry | Not executed in this session | NOT-RUN | Record final diagnostic |
| Replay 1× | Laboratory state and progress update without an action log entry | Not executed in this session | NOT-RUN | Record final diagnostic |
| Replay 2× | Laboratory state and progress update without an action log entry | Not executed in this session | NOT-RUN | Record final diagnostic |

## Manual gate: rules, actions, and desktop regression

| Scenario | Expected | Observed | Status | Notes |
| --- | --- | --- | --- | --- |
| Rule lifecycle | Record, save, relaunch, disable, enable, delete, import, and export preserve the documented behavior and stable identifiers | Not executed in this session | NOT-RUN | Imported rules must start disabled |
| Action safety | Invalid actions fail visibly; cancelled shell approval launches no process; approved action reports status/output | Not executed in this session | NOT-RUN | Use synthetic commands and data |
| Appearance and navigation | Light/Dark appearance, keyboard navigation, menus, toolbar, and menu-bar reopening work | Not executed in this session | NOT-RUN | Record accessibility observations |
| Settings and relaunch | Settings and login-item state persist; a bundle rebuild does not lose rule data | Not executed in this session | NOT-RUN | Back up local rules first |
| Public identity | Finder, Dock, Spotlight, menu bar and System Settings show `Tico` with the intended icon | Not executed in this session | NOT-RUN | Check Light and Dark appearances |
| Upgrade compatibility | An upgrade from AirShortcut keeps `Contents/MacOS/AirShortcut`, local data and existing permissions | Not executed in this session | NOT-RUN | Both builds must use the same Developer ID identity for definitive TCC evidence |
