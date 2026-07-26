# AirShortcut hardware validation report — sanitized example

Date: 2000-01-01

Physical-support verdict: FAIL

This fictional example demonstrates the evidence format only.

| OS | Device class | Capture mode | Gesture/scenario | Expected | Observed | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| macOS 14.x | internal | advanced-private | Tap | One configured tap is recognized | One recognition was shown after one configured tap | PASS | Fictional example; no raw frames retained |
| macOS 14.x | internal | advanced-private | Swipe left | Configured left swipe is recognized | Validation rejected the gesture as too short | FAIL | Fictional example of an objective failure |
| macOS 14.x | magic-trackpad | unavailable | Reconnection | Capture restores or explains its state after physical reconnection | No external trackpad was available | NOT-RUN | Missing hardware blocks physical PASS |
