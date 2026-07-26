#!/usr/bin/env bash
set -euo pipefail

APP_NAME="AirShortcut"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARCHIVE_PATH="${1:-$ROOT_DIR/dist/$APP_NAME.zip}"
TEMP_ROOT="$(/usr/bin/mktemp -d /private/tmp/AirShortcutPreflight.XXXXXXXX)"

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
EXTRACTED_APP="$EXTRACT_DIR/$APP_NAME.app"
/bin/mkdir -p "$EXTRACT_DIR"
/usr/bin/ditto -x -k "$ARCHIVE_PATH" "$EXTRACT_DIR"

if [[ ! -d "$EXTRACTED_APP" ]]; then
  echo "error: archive does not contain $APP_NAME.app at its root" >&2
  exit 3
fi

/usr/bin/xattr -cr "$EXTRACTED_APP"
/usr/bin/codesign --verify --deep --strict "$EXTRACTED_APP"

SIGNING_DETAILS="$(/usr/bin/codesign -dvvv "$EXTRACTED_APP" 2>&1)"
SIGNING_AUTHORITY="$(printf '%s\n' "$SIGNING_DETAILS" | /usr/bin/sed -n 's/^Authority=//p' | /usr/bin/head -n 1)"
SIGNING_FLAGS="$(printf '%s\n' "$SIGNING_DETAILS" | /usr/bin/sed -n 's/^CodeDirectory .* flags=\\([^ ]*\\).*/\\1/p' | /usr/bin/head -n 1)"

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
if [[ "$SIGNING_FLAGS" == *runtime* ]]; then
  HARDENED_RUNTIME="enabled"
fi

echo "AirShortcut release preflight"
echo "archive: $ARCHIVE_PATH"
echo "extracted bundle: temporary directory"
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
