# Release Readiness Validation

**Date**: 2026-07-26
**Spec**: `.specs/features/release-readiness/spec.md`
**Diff range**: `27e0650..837f3c3`
**Verifier**: second independent sub-agent (author != verifier)
**Verdict**: **BLOCKED**

The automated preview baseline is healthy, but the feature is not fully
verified. The fallback-input mutant found by the second independent sensor was
killed by the post-review correction recorded below. Explicit `NOT-RUN` and
external blockers are not counted as PASS.

## Task Completion

| Tasks | Status | Notes |
| --- | --- | --- |
| T1-T3 | Partial | Shared local gate passes; no real GitHub Actions run or controlled failing PR was supplied. |
| T4-T7 | Partial | Public/status/security docs are coherent; `LICENSE` is intentionally absent pending owner choice. |
| T8-T11 | Done | Evidence schema, validator, replay, permission, and fallback automated checks are present. |
| T12 | Blocked | Report is sanitized and structurally valid, but physical session/UAT is `NOT-RUN`. |
| T13-T15 | Done for ad hoc | ZIP dry-run passes strict/deep signature verification and is honestly labeled development-only. |
| T16 | Blocked | No Developer ID identity, notarization, staple, Gatekeeper, or clean-machine evidence. |
| T17-T19 | Partial | Preview/blocker map and lessons tooling exist; the second-sensor survivor was fixed and grounded as lesson `L-005`, while external gates remain blocked. |

## Spec-Anchored Acceptance Criteria

| AC | Spec-defined outcome | Evidence-or-zero | Result |
| --- | --- | --- | --- |
| RR-01 | A PR to `main` runs macOS build, tests, shell validation, and package verification and fails on non-zero. | `.github/workflows/ci.yml:3-23` configures the event/runner/gate; `script/ci_verify.sh:37-58` is fail-fast. No real workflow run or controlled failing PR evidence. | **BLOCKED** |
| RR-02 | The documented local gate is CI-equivalent and reports tests/artifacts. | `README.md:47-70`; `script/ci_verify.sh:67-76`; verifier gate: 100 tests and verified `dist/AirShortcut.zip`. | **PASS** |
| RR-03 | Successful CI summary distinguishes replay/automation from physical hardware and never claims hardware PASS. | `.github/workflows/ci.yml:25-34` has the required wording. No successful remote CI job summary was supplied. | **BLOCKED** |
| RR-04 | README and QA use executable shortcut `⌘6`, with no contradictory `⌘4`. | `README.md:105`; `outputs/qa-checklist.md:31-35`; range search found no `⌘4` in the changed public docs. | **PASS** |
| RR-05 | Published repo contains chosen license, status/support, and private-framework disclosure. | `README.md:5-25` supplies status/private API; `outputs/release-readiness-checklist.md:41` records missing `LICENSE`. | **BLOCKED** |
| RR-06 | Vulnerability reports use GitHub private reporting and exclude sensitive local artifacts. | `SECURITY.md:8-28` explicitly prohibits public reporting and sensitive attachments. | **PASS** |
| RR-07 | Completed manual report records OS, device, mode, gesture, expected, observed, and PASS/FAIL/NOT-RUN for every row. | `outputs/hardware-validation/report-2026-07-26.md:9-36` has the schema but explicitly states no physical session; rows are `NOT-RUN`. | **BLOCKED** |
| RR-08 | Unavailable/denied private capture is explained and keyboard/mouse remain safe. | Automated assertions: `Tests/AirShortcutTests/PermissionCoordinatorTests.swift:38-54`, `Tests/AirShortcutTests/TrackpadGestureServiceTests.swift:49-79`. Manual outcomes remain `NOT-RUN` at `outputs/hardware-validation/report-2026-07-26.md:15-16,30-32`. | **BLOCKED** |
| RR-09 | Replay at 0.5x/1x/2x updates only the laboratory and adds no action entry. | `Tests/AirShortcutTests/TrackpadLaboratoryPhaseOneTests.swift:190-203` asserts exact progress, ended/accepted state, gesture, and unchanged action log at all speeds. | **PASS** |
| RR-10 | Missing required physical scenarios prevents physical-support PASS. | `outputs/hardware-validation/report-2026-07-26.md:5-11,17-33` keeps the verdict `NOT-RUN`; `outputs/release-readiness-checklist.md:46` blocks physical PASS. | **PASS** |
| RR-11 | `--package` produces app/ZIP whose extracted app passes strict/deep verification. | Verifier gate passed; `script/ci_verify.sh:50-58` extracts and verifies; `script/release_preflight.sh:20-31` independently applies strict/deep verification. | **PASS** |
| RR-12 | Without Developer ID, result is ad hoc/development and makes no trust/notarization claim. | `script/release_preflight.sh:37-40,56-68`; verifier output classified the package as ad hoc and CI summary did not claim notarization. | **PASS** |
| RR-13 | Developer ID checklist requires nested signing, Hardened Runtime, notarization acceptance, staple validation, and clean-machine execution. | `outputs/release-validation-2026-07-26.md:11-39` and `outputs/release-template.md:32-52` require every gate and preserve `NOT-RUN`. | **PASS** |
| RR-14 | A published release includes version, commit, signing, minimum macOS, private-API limitation, and verification evidence. | `outputs/release-template.md:6-18,20-61` defines the contract, but no publishable Developer ID release artifact/notes exist. | **BLOCKED** |
| RR-15 | Independent verifier maps every AC to evidence or a gap. | This report maps RR-01-RR-18 with file/line evidence or explicit zero/blocker. | **PASS** |
| RR-16 | One to three scratch behavior mutations are killed; survivors become fix tasks. | Post-review test asserts the complete allowed fallback mask at `Tests/AirShortcutTests/TrackpadGestureServiceTests.swift:69-80`; focused scratch rerun with M1 (`.mouseMoved`) failed with the expected mask mismatch. M2 and M3 remain killed by the second sensor. | **PASS** |
| RR-17 | Any AC gap/survivor/precision/deviation/gate failure records a grounded lesson through `scripts/lessons.py`. | `scripts/lessons.py add` recorded candidate `L-005` with signal `surviving_mutant`, grounded at M1 in this report; the four prior `ac_gap` lessons remain present. | **PASS** |
| RR-18 | Required ACs still unverified after the bounded cycle are escalated as not ready. | `outputs/release-readiness-checklist.md:63-70` lists blockers; this independent verdict remains BLOCKED and does not silently complete them. | **PASS** |

**Spec-anchored status**: 12/18 PASS; 0/18 FAIL; 6/18 BLOCKED; 0 false PASS.

## Build Gate

- **Canonical command**: `./script/ci_verify.sh --package`
- **Environment isolation**:
  `CLANG_MODULE_CACHE_PATH`, `SWIFTPM_MODULECACHE_OVERRIDE`, and
  `XDG_CACHE_HOME` pointed to `/private/tmp`, with
  `AIRSHORTCUT_DISABLE_SWIFTPM_SANDBOX=1`.
- **Result at `837f3c3`**: **PASS**
- **Swift suite**: 100 executed, 100 passed, 0 failed, 0 skipped.
- **Focused security suite**: 8 executed, 8 passed, 0 failed, 0 skipped.
- **Package**: `dist/AirShortcut.zip`; extracted app passed
  `codesign --verify --deep --strict`.
- **Signing scope**: ad hoc/development only; physical hardware and
  notarization not exercised.
- **Test count**: author freeze records 97 baseline and 100 current (+3);
  the verifier independently observed 100 current tests.
- **Diff hygiene**: `git diff --check 27e0650..837f3c3` passed.
- **Post-review gate after `24d6f4d`**: `./script/ci_verify.sh --package`
  passed with 100/100 Swift tests, 8/8 focused security tests, and verified
  `dist/AirShortcut.zip`; hardware and notarization remained unexercised.

## Discrimination Sensor

Scratch root: `/private/tmp/AirShortcut-verifier2.KjiiQs` (archive copy of
`837f3c3`; real working tree was never mutated).

| Mutation | Target and behavioral fault | Probe | Result |
| --- | --- | --- | --- |
| M1 | `TrackpadGestureService.fallbackEventMask`: added `.mouseMoved`. | `swift test --disable-sandbox --filter TrackpadGestureServiceTests/testPublicFallbackDoesNotMonitorKeyboardOrMouseEvents` still passed because the test checks mouse-button-down events but not pointer movement. | **SURVIVED** |
| M2 | Hardware-report validator accepted `UNKNOWN` as a status. | The invalid-status fixture changed from required non-zero to exit 0. | **KILLED** |
| M3 | Disabled the mandatory non-empty `--source` check in `scripts/lessons.py`. | The missing-source probe changed from required exit 2 to adding an ungrounded candidate. | **KILLED** |

**Sensor depth**: lightweight, 3 targeted behavior mutations.
**Original result**: 2/3 killed; 1 survived — fix required.

### Post-review M1 verification

- **Correction**: the fallback test now compares the complete event mask with
  exactly `.magnify`, `.rotate`, and `.swipe`, so every unrelated event mask is
  rejected without maintaining a partial denylist.
- **Focused baseline**:
  `swift test --disable-sandbox --filter TrackpadGestureServiceTests/testPublicFallbackDoesNotMonitorKeyboardOrMouseEvents`
  executed 1 test with 0 failures.
- **Scratch mutant**: adding `.mouseMoved` produced the expected
  `XCTAssertEqual` mask mismatch and exit 1.
- **Corrected result**: 3/3 targeted mutations killed — **PASS**.

## Interactive UAT and Manual Evidence

No interactive or physical session was performed. The committed report states
this directly at `outputs/hardware-validation/report-2026-07-26.md:5-11`.
Internal/Magic Trackpad gestures, permission denial, fallback pass-through,
sleep/wake, reconnection, and false-positive observation remain `NOT-RUN`.
Developer ID, notarization, staple, `spctl`, and clean-machine execution remain
`BLOCKED/NOT-RUN` at `outputs/release-validation-2026-07-26.md:15-29`.

## Code Quality

| Check | Status |
| --- | --- |
| Scope limited to release readiness | PASS |
| Surgical production change | PASS: only fallback mask exposure/usage changed in product code |
| Existing patterns/style retained | PASS |
| No test weakening/deletion found in range | PASS |
| Spec-anchored assertions are value/state assertions | PASS for automated replay, permission, and fallback scope |
| Manual/external outcomes are not inferred from automation | PASS |
| Changed docs/scripts map to RR criteria or task done-when | PASS |
| Guidelines followed | PASS: `README.md`, `SECURITY.md`, `outputs/qa-checklist.md`, `Package.swift`, TLC validation/coding principles, and macOS build/signing skills |

## Ranked Gaps and Fix Tasks

1. **Blocker — RR-05**: owner must choose a compatible open-source license and
   add `LICENSE`; legal choice cannot be inferred by the verifier.
2. **Blocker — RR-07/RR-08/RR-10**: execute and sanitize the full internal and
   Magic Trackpad matrix, including permission denial, fallback input safety,
   sleep/wake, reconnection, and false-positive duration/count.
3. **Blocker — RR-13/RR-14 distribution outcome**: produce one Developer ID
   artifact with Hardened Runtime, nested signing, accepted notarization,
   staple validation, `spctl`, and clean-machine execution before binary
   release. RR-13's checklist contract passes; the actual distribution remains
   blocked.
4. **Major — RR-01/RR-03**: run the workflow on a real PR, inject a controlled
   failing test in a throwaway branch to prove red status, then preserve a clean
   successful run and its summary.
## Lessons

The canonical TLC lessons layer is available at `scripts/lessons.py`.
Four `ac_gap` lessons were recorded through the script and remain candidates,
as required until corroboration across a distinct feature:

- `L-001`: preserve remote CI run evidence before claiming workflow outcomes;
- `L-002`: require an owner-approved license before declaring publication ready;
- `L-003`: require sanitized physical evidence before claiming hardware support;
- `L-004`: require Developer ID/notarization/staple/Gatekeeper/clean-machine
  evidence before declaring a distributable release.

`L-005` records the M1 signal as a `surviving_mutant` candidate, grounded at
line 76 of this report and added through the canonical script after the
post-review correction.

## Summary

**Overall**: **BLOCKED — the automated gate and corrected discrimination
sensor pass, but release readiness remains incomplete.**

What works: local SwiftPM build/tests/security gate, ad hoc packaging and
strict extracted-signature verification, honest preview documentation, replay
isolation, fallback/permission automated assertions, sanitized-report
structure, and all three targeted mutation probes killed.

What blocks completion: real CI evidence, license decision, physical UAT,
publishable Developer ID/notarization evidence, and final release metadata.
