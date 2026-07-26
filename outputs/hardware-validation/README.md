# Hardware validation evidence

This directory contains sanitized summaries of manual AirShortcut validation.
It is evidence for a specific macOS and device class, not a claim of universal
hardware support.

1. Copy `report-template.md` to `report-YYYY-MM-DD.md`.
2. Use one row per observed scenario and device class.
3. Record only objective, summarized observations.
4. Run `script/validate_hardware_report.sh` before committing the report.

Allowed values:

- Device class: `internal`, `magic-trackpad`, `other`, `unknown`
- Capture mode: `advanced-private`, `public-fallback`, `unavailable`
- Status: `PASS`, `FAIL`, `NOT-RUN`

`NOT-RUN` means the scenario was not executed or the required hardware was not
available. It never counts as `PASS`. Missing required physical rows block a
physical-support PASS.

## Never commit

- Device serial numbers, computer names, usernames, or personal paths
- TCC database dumps or permission-database identifiers
- Raw trackpad frames, touch coordinates, or personal replay sessions
- Unredacted logs that expose user, device, file, or application identifiers

Use macOS version, non-identifying device class, capture mode, and a concise
behavioral summary. `sample-report.md` demonstrates the format without real
personal or hardware data.
