# AirShortcut hardware validation report

Date: YYYY-MM-DD

Physical-support verdict: NOT-RUN

The verdict remains `NOT-RUN` while any required physical scenario is
`NOT-RUN`, and becomes `FAIL` when a required scenario fails.

| OS | Device class | Capture mode | Gesture/scenario | Expected | Observed | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| macOS VERSION | internal | unavailable | Tap | One configured tap is recognized | Not executed | NOT-RUN | Replace with an objective observation |
| macOS VERSION | internal | unavailable | Hold | Hold fires once while contacts remain down | Not executed | NOT-RUN | Replace with an objective observation |
| macOS VERSION | internal | unavailable | Swipe left | Configured left swipe is recognized | Not executed | NOT-RUN | Replace with an objective observation |
| macOS VERSION | internal | unavailable | Swipe right | Configured right swipe is recognized | Not executed | NOT-RUN | Replace with an objective observation |
| macOS VERSION | internal | unavailable | Swipe up | Configured upward swipe is recognized | Not executed | NOT-RUN | Replace with an objective observation |
| macOS VERSION | internal | unavailable | Swipe down | Configured downward swipe is recognized | Not executed | NOT-RUN | Replace with an objective observation |
| macOS VERSION | internal | unavailable | Pinch | Pinch direction and progress are coherent | Not executed | NOT-RUN | Test both directions |
| macOS VERSION | internal | unavailable | Rotation | Rotation direction and progress are coherent | Not executed | NOT-RUN | Test both directions |
| macOS VERSION | internal | unavailable | Sleep/wake | Capture resumes after a real sleep/wake cycle | Not executed | NOT-RUN | A simulated pause is insufficient |
| macOS VERSION | magic-trackpad | unavailable | Reconnection | Capture restores or explains its state after physical reconnection | Not executed | NOT-RUN | Requires an external trackpad |
| macOS VERSION | internal | public-fallback | Public fallback | Supported gestures work and unavailable capabilities are labeled | Not executed | NOT-RUN | Forced fallback is distinct from private capture |
| macOS VERSION | internal | public-fallback | Input safety | Original keyboard and mouse input is not consumed | Not executed | NOT-RUN | Observe both input types |
| macOS VERSION | internal | unavailable | False-positive observation | Accidental recognitions are recorded during a stated period | Not executed | NOT-RUN | Record duration and count |
