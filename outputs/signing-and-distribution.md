# Signing and distribution

## Current development artifact

`script/build_and_run.sh` builds the SwiftPM executable, stages `dist/AirShortcut.app`, writes bundle metadata, and applies an ad hoc signature. The `--package` mode is a local dry-run that creates and strictly verifies `dist/AirShortcut.zip` without opening the app.

Both outputs are suitable for local development only. An ad hoc signature is
not a Developer ID signature, does not carry notarization evidence, and must
not be described as Gatekeeper-ready or as a distributable release.

For local ad hoc builds, the script embeds an explicit development-only designated requirement based on the stable bundle identifier. Without it, the default ad hoc identity is a changing `cdhash`, so TCC may forget Input Monitoring after every rebuild. Set `AIRSHORTCUT_CODESIGN_IDENTITY` to a real code-signing identity when one becomes available; the script then uses the certificate-backed identity instead.

The script clears extended attributes and validates the signature immediately before launch. Because this checkout lives under `Documents`, macOS File Provider may attach `com.apple.FinderInfo` again after Launch Services opens the app; a later strict verification from that synchronized location can therefore fail on metadata that was not present in the signed artifact. Produce release archives from a non-synchronized staging directory and validate before first launch.

## Distribution target

The practical MVP path is a non-sandboxed Developer ID application distributed outside the Mac App Store.

Advanced global trackpad gestures depend on a private Apple framework loaded dynamically. This rules out Mac App Store review and increases compatibility risk, but it does not change the local ad hoc workflow. A direct Developer ID release must be tested on each supported macOS version and retain the public fallback when the private ABI is unavailable.

Required Developer ID release gates:

1. Choose and keep a stable reverse-DNS bundle identifier.
2. Enroll in the Apple Developer Program and install a Developer ID Application certificate.
3. Build a release artifact with Hardened Runtime enabled and inspect the required entitlements.
4. Sign every nested framework, library, helper, and executable before signing the outer bundle with the same Developer ID identity.
5. Verify the nested and outer signatures with `codesign --verify --deep --strict`.
6. Archive the signed app, submit it with `notarytool`, and retain explicit acceptance evidence.
7. Staple the accepted ticket and require `stapler validate` to succeed.
8. Run Gatekeeper assessment and launch the final artifact on a clean Mac or clean user account before approval.

Failure or `NOT-RUN` at any required gate stops release approval. A successful
local ad hoc dry-run cannot substitute for Developer ID, Hardened Runtime,
notarization acceptance, stapling, or clean-machine execution.

Apple credentials stay outside the repository and release reports. Provide
signing identities and `notarytool` credentials through the owner's protected
local keychain or CI secret store; never commit certificates, passwords,
profiles, API keys, or unsanitized notarization logs.

## Entitlement policy

Start with no App Sandbox and no optional entitlements. Add Apple Events automation only when a concrete cross-app automation feature ships. Accessibility and Input Monitoring remain TCC permissions requested at runtime; they are not a reason to invent unrelated entitlements.

Arbitrary shell scripts are incompatible with a tightly sandboxed App Store posture. If App Store distribution becomes a requirement, redesign script execution and global input capture before enabling the sandbox.

## Validation commands

```sh
codesign -dvvv --entitlements :- dist/AirShortcut.app
codesign --verify --deep --strict --verbose=2 dist/AirShortcut.app
spctl -a -vv --type execute dist/AirShortcut.app
plutil -lint dist/AirShortcut.app/Contents/Info.plist
```

For a Developer ID release candidate, also retain the accepted notarization
submission identifier, inspect a sanitized notarization log, run `stapler
validate` after stapling, and record the clean-machine result. Gatekeeper
rejection of the current ad hoc build is expected and is distinct from a
compilation or local launch failure.
