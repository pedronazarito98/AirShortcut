#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-run}"
APP_NAME="AirShortcut"
BUNDLE_ID="com.pedronazarito.AirShortcut"
MIN_SYSTEM_VERSION="14.0"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
APP_BUNDLE="$DIST_DIR/$APP_NAME.app"
APP_BINARY="$APP_BUNDLE/Contents/MacOS/$APP_NAME"
APP_ARCHIVE="$DIST_DIR/$APP_NAME.zip"
TEMP_ROOT="$(/usr/bin/mktemp -d /private/tmp/AirShortcut.XXXXXXXX)"
/bin/chmod 700 "$TEMP_ROOT"
cleanup() {
  /bin/rm -rf -- "$TEMP_ROOT"
}
trap cleanup EXIT HUP INT TERM

STAGING_DIR="$TEMP_ROOT/staging"
STAGED_APP_BUNDLE="$STAGING_DIR/$APP_NAME.app"
STAGED_CONTENTS="$STAGED_APP_BUNDLE/Contents"
STAGED_MACOS="$STAGED_CONTENTS/MacOS"
STAGED_BINARY="$STAGED_MACOS/$APP_NAME"
INFO_PLIST="$STAGED_CONTENTS/Info.plist"
RUN_DIR="$TEMP_ROOT/run"
RUN_APP_BUNDLE="$RUN_DIR/$APP_NAME.app"
VERIFY_DIR="$TEMP_ROOT/verify"
VERIFY_APP_BUNDLE="$VERIFY_DIR/$APP_NAME.app"

if [[ "$MODE" != "--package" && "$MODE" != "package" ]]; then
  pkill -x "$APP_NAME" >/dev/null 2>&1 || true
fi
cd "$ROOT_DIR"
if [[ "${AIRSHORTCUT_DISABLE_SWIFTPM_SANDBOX:-0}" == "1" ]]; then
  swift build --disable-sandbox --product "$APP_NAME"
  BUILD_BINARY="$(swift build --disable-sandbox --show-bin-path)/$APP_NAME"
else
  swift build --product "$APP_NAME"
  BUILD_BINARY="$(swift build --show-bin-path)/$APP_NAME"
fi

mkdir -p "$STAGED_MACOS"
cp "$BUILD_BINARY" "$STAGED_BINARY"
chmod +x "$STAGED_BINARY"

cat >"$INFO_PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "https://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>$APP_NAME</string>
  <key>CFBundleIdentifier</key>
  <string>$BUNDLE_ID</string>
  <key>CFBundleName</key>
  <string>$APP_NAME</string>
  <key>CFBundleDisplayName</key>
  <string>$APP_NAME</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>0.1.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>LSMinimumSystemVersion</key>
  <string>$MIN_SYSTEM_VERSION</string>
  <key>NSPrincipalClass</key>
  <string>NSApplication</string>
  <key>NSHumanReadableCopyright</key>
  <string>Copyright © 2026 Pedro Nazarito</string>
</dict>
</plist>
PLIST

/usr/bin/xattr -cr "$STAGED_APP_BUNDLE"
/usr/bin/xattr -d com.apple.FinderInfo "$STAGED_APP_BUNDLE" 2>/dev/null || true
CODESIGN_IDENTITY="${AIRSHORTCUT_CODESIGN_IDENTITY:--}"
if [[ "$CODESIGN_IDENTITY" == "-" ]]; then
  # An ordinary ad hoc signature gets a cdhash-only designated requirement,
  # which changes after every rebuild and breaks TCC permission continuity.
  # This explicit development-only requirement keeps AirShortcut recognizable.
  codesign \
    --force \
    --deep \
    --sign - \
    --identifier "$BUNDLE_ID" \
    --requirements "=designated => identifier \"$BUNDLE_ID\"" \
    "$STAGED_APP_BUNDLE" >/dev/null
else
  codesign --force --deep --sign "$CODESIGN_IDENTITY" "$STAGED_APP_BUNDLE" >/dev/null
fi
/usr/bin/xattr -d com.apple.FinderInfo "$STAGED_APP_BUNDLE" 2>/dev/null || true
codesign --verify --deep --strict "$STAGED_APP_BUNDLE"

rm -rf "$APP_BUNDLE"
rm -rf "$DIST_DIR/.signed"
rm -f "$APP_ARCHIVE"
mkdir -p "$DIST_DIR"
# The visible .app is convenient for local use. The zip is the distributable
# artifact because synced folders can reattach FinderInfo to bundle directories.
/usr/bin/ditto --norsrc "$STAGED_APP_BUNDLE" "$APP_BUNDLE"
/usr/bin/ditto -c -k --norsrc --keepParent "$STAGED_APP_BUNDLE" "$APP_ARCHIVE"
/usr/bin/xattr -cr "$APP_BUNDLE"
/usr/bin/ditto -x -k "$APP_ARCHIVE" "$VERIFY_DIR"
/usr/bin/xattr -cr "$VERIFY_APP_BUNDLE"
codesign --verify --deep --strict "$VERIFY_APP_BUNDLE"
open_app() {
  # Launch Services may attach more metadata to the opened bundle. Run from a
  # clean temporary copy so the distributable zip stays untouched.
  mkdir -p "$RUN_DIR"
  /usr/bin/ditto --norsrc "$APP_BUNDLE" "$RUN_APP_BUNDLE"
  /usr/bin/xattr -cr "$RUN_APP_BUNDLE"
  codesign --verify --deep --strict "$RUN_APP_BUNDLE"
  /usr/bin/open -n "$RUN_APP_BUNDLE" "$@"
}

case "$MODE" in
  run)
    open_app
    ;;
  --debug|debug)
    lldb -- "$APP_BINARY"
    ;;
  --logs|logs)
    open_app
    /usr/bin/log stream --info --style compact --predicate "process == \"$APP_NAME\""
    ;;
  --telemetry|telemetry)
    open_app
    /usr/bin/log stream --info --style compact --predicate "subsystem == \"$BUNDLE_ID\""
    ;;
  --verify|verify)
    open_app
    sleep 1
    pgrep -x "$APP_NAME" >/dev/null
    ;;
  --package|package)
    ;;
  --capture-diagnostic|capture-diagnostic)
    open_app --args --start-capture
    sleep 3
    pgrep -x "$APP_NAME" >/dev/null
    /usr/bin/log show --last 1m --info --style compact \
      --predicate "subsystem == \"$BUNDLE_ID\" && (category == \"Permissions\" || category == \"GlobalCapture\" || category == \"GlobalTrackpad\")"
    ;;
  --laboratory-verify|laboratory-verify)
    open_app --args --open-laboratory
    sleep 2
    pgrep -x "$APP_NAME" >/dev/null
    ;;
  --fallback-diagnostic|fallback-diagnostic)
    open_app --args --open-laboratory --force-trackpad-fallback
    sleep 2
    pgrep -x "$APP_NAME" >/dev/null
    /usr/bin/log show --last 1m --info --style compact \
      --predicate "subsystem == \"$BUNDLE_ID\" && category == \"GlobalTrackpad\""
    ;;
  *)
    echo "usage: $0 [run|--package|--debug|--logs|--telemetry|--verify|--capture-diagnostic|--laboratory-verify|--fallback-diagnostic]" >&2
    exit 2
    ;;
esac

# Synced folders may reattach Finder metadata to the visible local bundle.
# Strict verification therefore happens on staging and on the zip after it is
# extracted to /private/tmp; the visible app is still cleaned for local use.
/usr/bin/xattr -cr "$APP_BUNDLE"
