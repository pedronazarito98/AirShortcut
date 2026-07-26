# Tico QA checklist

## Automated

- `swift build --product AirShortcut`
- `swift test`
- `bash -n script/build_and_run.sh`
- `./script/build_and_run.sh --package`
- `./script/build_and_run.sh --release-package`
- `plutil -lint dist/Tico.app/Contents/Info.plist`
- `test "$(plutil -extract CFBundleDisplayName raw dist/Tico.app/Contents/Info.plist)" = "Tico"`
- `test "$(plutil -extract CFBundleExecutable raw dist/Tico.app/Contents/Info.plist)" = "AirShortcut"`
- `test "$(plutil -extract CFBundleIdentifier raw dist/Tico.app/Contents/Info.plist)" = "com.pedronazarito.AirShortcut"`
- `test -f dist/Tico.app/Contents/Resources/Tico.icns`
- `codesign --verify --deep --strict --verbose=2 dist/Tico.app`
- `./script/build_and_run.sh --verify`

For a public release, additionally require:

- a `Developer ID Application` identity in the Keychain;
- `TICO_NOTARYTOOL_PROFILE` configured;
- `./script/notarize_release.sh` completes successfully;
- `spctl` reports `accepted` and `Notarized Developer ID`.

## Manual: clean permission state

- Launch the `.app` bundle and confirm the main window comes to the front.
- Verify Accessibility and Input Monitoring display their real current state.
- With Input Monitoring denied, verify capture does not start and an explanation appears.
- Grant a permission in System Settings, return to Tico, and refresh.

## Manual: capture and rules

- Start capture and verify a keyboard event appears without being consumed.
- Verify an extra mouse button appears with the correct number.
- Record a trigger into a new rule, save it, relaunch, and verify persistence.
- Disable the rule and verify it does not run.
- Re-enable it and verify the configured action produces one log entry.
- Verify delete, import, and export retain stable rule identifiers.

## Manual: advanced global trackpad

- Confirm the overview reports `Global avançada`, not the AppKit fallback.
- Open the Laboratory with `⌘4` and confirm the four tabs: Ao vivo, Calibração, Sessões, and Validação.
- In Validação, perform tap and hold, four directional swipes, pinch in/out, and clockwise/counterclockwise rotation; each row must receive a green check.
- Record a real session, confirm the frame count increases, export it, import it, and replay at 0.5×, 1×, and 2×.
- Confirm replay updates the laboratory but never executes a rule or adds an action log entry.
- Apply conservative, balanced, and responsive presets to the same borderline gesture and confirm the diagnostic explains different outcomes.
- Configure minimum and maximum velocity and verify rejected gestures cite the violated limit.
- Verify hold fires once while fingers remain down.
- Verify legacy quadrants plus start/end edges, corners, and all 3×3 grid cells.
- Confirm the HID list shows the internal trackpad and a Magic Trackpad when one is connected; because the private callback uses the default device, validate each physical device separately and mark the corresponding check manually.
- Sleep and wake the Mac, then confirm raw capture resumes.
- Disconnect/reconnect an external trackpad and confirm the app remains responsive; restore advanced capture if the private callback does not resume automatically.
- Activate public fallback, perform a public swipe/pinch/rotation, and confirm its validation check completes without breaking keyboard or mouse capture.
- Start normal-use observation, browse normally, mark any accidental recognition immediately, then finish the session and review the false-positive rate.

## Manual: actions and safety

- Open a valid URL and app path.
- Show a notification after granting notification permission.
- Trigger an invalid action and verify the failure is visible without crashing.
- Cancel shell confirmation and verify no process launches.
- Confirm an approved short shell command and verify exit status/output handling.

## Desktop regression

- Light and Dark appearances.
- Keyboard navigation, menu commands, and toolbar actions.
- Main window reopening from menu bar.
- Settings persistence and login item state.
- Relaunch after bundle rebuild without losing rule data.
- Confirm Finder, Dock, Spotlight, and System Settings show `Tico` and its icon.
- Confirm `Contents/MacOS/AirShortcut` remains the executable and existing
  permissions are retained after upgrading from an AirShortcut build.
