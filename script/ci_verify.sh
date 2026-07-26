#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGE_MODE=0
APP_NAME="AirShortcut"
ARCHIVE_PATH="$ROOT_DIR/dist/$APP_NAME.zip"
TEST_LOG="$(/usr/bin/mktemp /private/tmp/AirShortcut-ci-tests.XXXXXXXX)"
VERIFY_DIR=""
SWIFT_ARGS=()

if [[ "${AIRSHORTCUT_DISABLE_SWIFTPM_SANDBOX:-0}" == "1" ]]; then
  SWIFT_ARGS+=(--disable-sandbox)
fi

cleanup() {
  /bin/rm -f -- "$TEST_LOG"
  if [[ -n "$VERIFY_DIR" ]]; then
    /bin/rm -rf -- "$VERIFY_DIR"
  fi
}
trap cleanup EXIT HUP INT TERM

if [[ "${1:-}" == "--package" ]]; then
  PACKAGE_MODE=1
elif [[ $# -ne 0 ]]; then
  echo "usage: $0 [--package]" >&2
  exit 2
fi

step() {
  printf '\n==> %s\n' "$1"
}

cd "$ROOT_DIR"

step "Validating shell scripts"
bash -n script/build_and_run.sh
bash -n script/ci_verify.sh

step "Building AirShortcut"
swift build ${SWIFT_ARGS[@]+"${SWIFT_ARGS[@]}"} --product "$APP_NAME"

step "Running complete Swift test suite"
swift test ${SWIFT_ARGS[@]+"${SWIFT_ARGS[@]}"} 2>&1 | /usr/bin/tee "$TEST_LOG"

step "Running security regression suite"
swift test ${SWIFT_ARGS[@]+"${SWIFT_ARGS[@]}"} --filter SecurityRegressionTests

if [[ "$PACKAGE_MODE" -eq 1 ]]; then
  step "Building and verifying local ad hoc package"
  ./script/build_and_run.sh --package
  [[ -f "$ARCHIVE_PATH" ]]

  VERIFY_DIR="$(/usr/bin/mktemp -d /private/tmp/AirShortcut-ci-package.XXXXXXXX)"
  /usr/bin/ditto -x -k "$ARCHIVE_PATH" "$VERIFY_DIR"
  /usr/bin/xattr -cr "$VERIFY_DIR/$APP_NAME.app"
  codesign --verify --deep --strict "$VERIFY_DIR/$APP_NAME.app"
fi

TEST_COUNT="$(/usr/bin/sed -nE 's/.*Executed ([0-9]+) tests?.*/\1/p' "$TEST_LOG" | /usr/bin/tail -n 1)"
if [[ -z "$TEST_COUNT" ]]; then
  echo "Unable to determine the executed test count." >&2
  exit 1
fi

step "Automated verification summary"
echo "Swift tests: $TEST_COUNT"
echo "Local app path: $ROOT_DIR/dist/$APP_NAME.app"
if [[ "$PACKAGE_MODE" -eq 1 ]]; then
  echo "Verified ad hoc archive: $ARCHIVE_PATH"
else
  echo "Package verification: not requested (use --package)"
fi
echo "Physical trackpad coverage: not exercised by this automated gate"
echo "Notarization: not exercised by this automated gate"
