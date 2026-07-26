#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_BUNDLE="$ROOT_DIR/dist/Tico.app"
APP_ARCHIVE="$ROOT_DIR/dist/Tico.zip"
NOTARY_PROFILE="${TICO_NOTARYTOOL_PROFILE:-}"

if [[ -z "$NOTARY_PROFILE" ]]; then
  echo "TICO_NOTARYTOOL_PROFILE is required." >&2
  echo "Create a Keychain profile with xcrun notarytool store-credentials first." >&2
  exit 2
fi

if [[ ! -d "$APP_BUNDLE" || ! -f "$APP_ARCHIVE" ]]; then
  echo "missing release artifacts; run ./script/build_and_run.sh --release-package first" >&2
  exit 1
fi

SIGNATURE_AUTHORITY="$(codesign -dv --verbose=4 "$APP_BUNDLE" 2>&1 \
  | /usr/bin/sed -n 's/^Authority=//p' \
  | /usr/bin/head -1)"
if [[ "$SIGNATURE_AUTHORITY" != Developer\ ID\ Application:* ]]; then
  echo "Tico.app is not signed with a Developer ID Application certificate." >&2
  exit 1
fi

codesign --verify --deep --strict --verbose=2 "$APP_BUNDLE"
xcrun notarytool submit "$APP_ARCHIVE" \
  --keychain-profile "$NOTARY_PROFILE" \
  --wait
xcrun stapler staple "$APP_BUNDLE"
xcrun stapler validate "$APP_BUNDLE"

/bin/rm -f "$APP_ARCHIVE"
/usr/bin/ditto -c -k --norsrc --keepParent "$APP_BUNDLE" "$APP_ARCHIVE"
codesign --verify --deep --strict --verbose=2 "$APP_BUNDLE"
spctl -a -vv --type execute "$APP_BUNDLE"

echo "Notarized release ready: $APP_ARCHIVE"
