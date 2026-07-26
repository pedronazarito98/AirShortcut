#!/usr/bin/env bash
set -euo pipefail

PUBLIC_APP_NAME="Tico"
EXECUTABLE_NAME="AirShortcut"
BUNDLE_ID="com.pedronazarito.AirShortcut"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARCHIVE_PATH="${1:-$ROOT_DIR/dist/$PUBLIC_APP_NAME.zip}"
TEMP_ROOT="$(/usr/bin/mktemp -d /private/tmp/TicoPreflight.XXXXXXXX)"

cleanup() {
  /bin/rm -rf -- "$TEMP_ROOT"
}
trap cleanup EXIT HUP INT TERM

if [[ ! -f "$ARCHIVE_PATH" ]]; then
  echo "error: archive not found: $ARCHIVE_PATH" >&2
  echo "run ./script/build_and_run.sh --package first" >&2
  exit 2
fi

EXTRACT_DIR="$TEMP_ROOT/extracted"
EXTRACTED_APP="$EXTRACT_DIR/$PUBLIC_APP_NAME.app"
/bin/mkdir -p "$EXTRACT_DIR"
/usr/bin/ditto -x -k "$ARCHIVE_PATH" "$EXTRACT_DIR"

if [[ ! -d "$EXTRACTED_APP" ]]; then
  echo "error: archive does not contain $PUBLIC_APP_NAME.app at its root" >&2
  exit 3
fi

/usr/bin/xattr -cr "$EXTRACTED_APP"
/usr/bin/codesign --verify --deep --strict "$EXTRACTED_APP"

INFO_PLIST="$EXTRACTED_APP/Contents/Info.plist"
/usr/bin/plutil -lint "$INFO_PLIST"
DISPLAY_NAME="$(/usr/bin/plutil -extract CFBundleDisplayName raw "$INFO_PLIST")"
EXECUTABLE_NAME_IN_BUNDLE="$(/usr/bin/plutil -extract CFBundleExecutable raw "$INFO_PLIST")"
BUNDLE_ID_IN_BUNDLE="$(/usr/bin/plutil -extract CFBundleIdentifier raw "$INFO_PLIST")"

if [[ "$DISPLAY_NAME" != "$PUBLIC_APP_NAME" ||
      "$EXECUTABLE_NAME_IN_BUNDLE" != "$EXECUTABLE_NAME" ||
      "$BUNDLE_ID_IN_BUNDLE" != "$BUNDLE_ID" ]]; then
  echo "error: public or technical bundle identity does not match the Tico compatibility contract" >&2
  exit 4
fi

SIGNING_DETAILS="$(/usr/bin/codesign -dvvv "$EXTRACTED_APP" 2>&1)"
SIGNING_AUTHORITY="$(printf '%s\n' "$SIGNING_DETAILS" | /usr/bin/sed -n 's/^Authority=//p' | /usr/bin/head -n 1)"
SIGNING_FLAGS_LINE="$(printf '%s\n' "$SIGNING_DETAILS" | /usr/bin/sed -n '/^CodeDirectory .* flags=/p' | /usr/bin/head -n 1)"

if [[ "$SIGNING_AUTHORITY" == Developer\ ID\ Application:* ]]; then
  SIGNING_MODE="developer-id"
else
  SIGNING_MODE="ad-hoc/development"
fi

ENTITLEMENTS_FILE="$TEMP_ROOT/entitlements.plist"
if /usr/bin/codesign -d --entitlements "$ENTITLEMENTS_FILE" "$EXTRACTED_APP" >/dev/null 2>&1 &&
  [[ -s "$ENTITLEMENTS_FILE" ]]; then
  ENTITLEMENTS_STATUS="present (inspect with codesign before release)"
else
  ENTITLEMENTS_STATUS="none"
fi

HARDENED_RUNTIME="not-confirmed"
if [[ "$SIGNING_FLAGS_LINE" == *runtime* ]]; then
  HARDENED_RUNTIME="enabled"
fi

echo "Tico release preflight"
echo "archive: $ARCHIVE_PATH"
echo "extracted bundle: temporary directory"
echo "public name: $DISPLAY_NAME"
echo "technical executable: $EXECUTABLE_NAME_IN_BUNDLE"
echo "bundle identifier: $BUNDLE_ID_IN_BUNDLE"
echo "strict deep signature: PASS"
echo "signing mode: $SIGNING_MODE"
echo "hardened runtime: $HARDENED_RUNTIME"
echo "entitlements: $ENTITLEMENTS_STATUS"
echo "notarization: not-attempted (no notarytool acceptance evidence inspected)"
echo "staple: not-validated"
echo "clean-machine execution: not-run"

if [[ "$SIGNING_MODE" == "ad-hoc/development" ]]; then
  echo "distribution decision: development-only; Gatekeeper acceptance and notarization are not claimed"
elif [[ "$HARDENED_RUNTIME" != "enabled" ]]; then
  echo "distribution decision: blocked; Developer ID artifact lacks confirmed Hardened Runtime"
else
  echo "distribution decision: pending notarization, staple validation, and clean-machine execution"
fi
