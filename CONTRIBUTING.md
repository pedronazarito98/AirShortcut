# Contributing to AirShortcut

AirShortcut is currently a technical preview. Contributions are welcome for
review, but the repository does not yet contain an owner-approved open source
license. This is an explicit release-readiness blocker: until the project owner
selects and adds a license, do not assume permission to copy, redistribute, or
publish derivative versions of the code.

## Before opening a pull request

1. Keep changes focused and preserve the existing SwiftPM architecture.
2. Run the automated gate without opening the app:

   ```sh
   ./script/ci_verify.sh --package
   ```

3. Add or update tests for behavior changes. Do not weaken, skip, or remove
   existing assertions to make the suite pass.
4. Describe the change, its impact, and how reviewers can verify it.

The automated gate covers compilation, Swift tests, security regressions, and
local ad hoc packaging. It does not prove physical trackpad support,
private-framework compatibility across macOS versions, Developer ID signing,
or notarization. Changes that affect trackpad behavior also require the manual
matrix in `outputs/qa-checklist.md`; `NOT-RUN` is not a passing result.

## Security reports

Do not disclose a suspected vulnerability in a public issue or pull request.
Follow the private reporting process in `SECURITY.md` and remove credentials,
personal paths, device identifiers, TCC data, and raw trackpad recordings from
all shared evidence.

## Licensing blocker

The project owner must explicitly choose the license after reviewing the
project's dependencies and distribution intent. Adding a `LICENSE` file is
deferred until that decision is recorded; contributors must not add a license
on the owner's behalf.
