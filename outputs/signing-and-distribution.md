# Signing and distribution

## Current development artifact

`script/build_and_run.sh` builds the SwiftPM product and executable
`AirShortcut`, stages the public bundle as `dist/Tico.app`, creates
`dist/Tico.zip`, writes bundle metadata, applies an ad hoc signature, and opens
the bundle. The public rename deliberately preserves
`CFBundleExecutable=AirShortcut` and
`CFBundleIdentifier=com.pedronazarito.AirShortcut` for technical and TCC
continuity. This is suitable for local development only; notarization is not
required for that workflow.

For local ad hoc builds, the script embeds an explicit development-only designated requirement based on the stable bundle identifier. Without it, the default ad hoc identity is a changing `cdhash`, so TCC may forget Input Monitoring after every rebuild. Set `AIRSHORTCUT_CODESIGN_IDENTITY` to a real code-signing identity when one becomes available; the script then uses the certificate-backed identity instead.

The script clears extended attributes and validates the signature immediately before launch. Because this checkout lives under `Documents`, macOS File Provider may attach `com.apple.FinderInfo` again after Launch Services opens the app; a later strict verification from that synchronized location can therefore fail on metadata that was not present in the signed artifact. Produce release archives from a non-synchronized staging directory and validate before first launch.

## Distribution target

The practical MVP path is a non-sandboxed Developer ID application distributed outside the Mac App Store.

Advanced global trackpad gestures depend on a private Apple framework loaded dynamically. This rules out Mac App Store review and increases compatibility risk, but it does not change the local ad hoc workflow. A direct Developer ID release must be tested on each supported macOS version and retain the public fallback when the private ABI is unavailable.

Required prerequisites:

1. Choose and keep a stable reverse-DNS bundle identifier.
2. Enroll in the Apple Developer Program and install a Developer ID Application certificate.
3. Build a release artifact with Hardened Runtime enabled.
4. Sign every nested executable and then the outer bundle with the same identity.
5. Archive the signed app, submit it with `notarytool`, wait for acceptance, and staple the ticket.
6. Validate the final artifact on a clean Mac/user account.

The repository exposes two separate commands:

```sh
./script/build_and_run.sh --release-package
./script/notarize_release.sh
```

The first command always creates an optimized release candidate. With
`AIRSHORTCUT_CODESIGN_IDENTITY` unset it uses an ad hoc signature and prints a
local-only warning. With a Developer ID Application identity configured it
adds Hardened Runtime and a secure timestamp.

The second command requires `TICO_NOTARYTOOL_PROFILE`, refuses ad hoc builds,
submits the ZIP, waits for Apple, staples the ticket, recreates the archive and
checks both `codesign` and Gatekeeper.

## Entitlement policy

Start with no App Sandbox and no optional entitlements. Add Apple Events automation only when a concrete cross-app automation feature ships. Accessibility and Input Monitoring remain TCC permissions requested at runtime; they are not a reason to invent unrelated entitlements.

Arbitrary shell scripts are incompatible with a tightly sandboxed App Store posture. If App Store distribution becomes a requirement, redesign script execution and global input capture before enabling the sandbox.

## Validation commands

```sh
codesign -dvvv --entitlements :- dist/Tico.app
codesign --verify --deep --strict --verbose=2 dist/Tico.app
spctl -a -vv --type execute dist/Tico.app
plutil -lint dist/Tico.app/Contents/Info.plist
```

For a release candidate, also inspect the notarization log and run `stapler validate` after stapling. Gatekeeper rejection of the current ad hoc build is expected and is distinct from a compilation or local launch failure.

The distributable artifact is `dist/Tico.zip`. Validate it from a clean
temporary directory before delivery:

```sh
ditto -x -k dist/Tico.zip /private/tmp/tico-package-check
xattr -cr /private/tmp/tico-package-check/Tico.app
codesign --verify --deep --strict --verbose=2 /private/tmp/tico-package-check/Tico.app
```

## Compatibilidade durante a mudança de nome

O nome público `Tico` não altera o cliente técnico reconhecido pelo macOS:

- `CFBundleIdentifier` continua `com.pedronazarito.AirShortcut`;
- o executável continua `AirShortcut`;
- builds locais continuam usando o mesmo requisito designado;
- dados continuam em `Application Support/AirShortcut`;
- preferências continuam usando chaves `com.airshortcut.*`.

Essa estabilidade é necessária para que uma atualização não apareça como um
novo cliente para TCC. A assinatura ad hoc permite testar a igualdade do
identificador e do requisito designado, mas a confirmação definitiva de
permissões entre versões distribuídas depende de ambas serem assinadas pelo
mesmo certificado Developer ID.

Não mover dados para `Application Support/Tico` nesta transição. Uma migração
futura precisa ser uma etapa própria, com cópia atômica, verificação do
conteúdo, rollback e fallback de leitura para a pasta anterior.
