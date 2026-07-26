# LESSONS — auto-maintained by scripts/lessons.py

> Machine-owned. Do NOT hand-edit. Changes are overwritten on the next `lessons.py` write.
> Canonical state lives in `.specs/lessons.json`. Edit lessons only via the script.
> promote_threshold=2 distinct features · window_days=45 · quarantine_threshold=2

## Confirmed (load these at Specify/Design)

Corroborated across multiple features. Safe to apply as guidance.

_none_

## Candidates (under observation — do NOT load as guidance yet)

Seen once or not yet corroborated. Tracked, not trusted.

### L-001 — Preserve remote CI run evidence before claiming workflow outcomes are verified
- signal: `ac_gap` · recurrence: 1 feature(s) · scope: `ci` · harmful: 0
- features: release-readiness
- evidence: .specs/features/release-readiness/validation.md:RR-01/RR-03 (ci)
- last seen: 2026-07-26T14:20:55Z

### L-002 — Require an owner-approved license choice before declaring the repository publishable
- signal: `ac_gap` · recurrence: 1 feature(s) · scope: `public-release` · harmful: 0
- features: release-readiness
- evidence: .specs/features/release-readiness/validation.md:RR-05 (public-release)
- last seen: 2026-07-26T14:20:55Z

### L-003 — Require sanitized physical trackpad evidence before claiming hardware support
- signal: `ac_gap` · recurrence: 1 feature(s) · scope: `hardware-validation` · harmful: 0
- features: release-readiness
- evidence: .specs/features/release-readiness/validation.md:RR-07/RR-08 (hardware-validation)
- last seen: 2026-07-26T14:20:55Z

### L-004 — Require Developer ID notarization staple Gatekeeper and clean-machine evidence before declaring a distributable release
- signal: `ac_gap` · recurrence: 1 feature(s) · scope: `distribution` · harmful: 0
- features: release-readiness
- evidence: .specs/features/release-readiness/validation.md:RR-14 (distribution)
- last seen: 2026-07-26T14:20:55Z

### L-005 — Assert the complete allowed event mask when isolation requires every unrelated input event to remain unmonitored.
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `Swift AppKit public fallback input isolation` · harmful: 0
- features: release-readiness
- evidence: .specs/features/release-readiness/validation.md:76 (M1) (Swift AppKit public fallback input isolation)
- last seen: 2026-07-26T14:29:27Z

## Quarantined (failed when applied — ignore)

A confirmed lesson that recurred alongside failure. Kept for the maintainer to review.

_none_
