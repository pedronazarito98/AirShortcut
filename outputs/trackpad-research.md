# Trackpad gesture feasibility

## Decision

Advanced global gestures are the product's primary capability. AirShortcut now uses an experimental raw-contact provider backed by Apple's private `MultitouchSupport` framework, with a public AppKit fallback if the framework or ABI becomes unavailable.

| Capability | Public API | Scope | MVP decision |
| --- | --- | --- | --- |
| Click and secondary click | `NSEvent` / click recognizers | App-local | Supported as local research |
| Magnification | Raw contact span | Global, private framework | Supported with 2–5 fingers |
| Rotation | Raw contact angle | Global, private framework | Supported with 2–5 fingers |
| Directional swipe | Raw contact centroid | Global, private framework | Supported with 2–5 fingers |
| Tap and hold | Raw contact sequence | Global, private framework | Supported with 2–5 fingers |
| Extra mouse buttons | `CGEventTap` | Global with permission | Supported by MVP |
| Arbitrary multi-finger trackpad gestures | `MultitouchSupport` (private) | Global | Experimental core feature |

The private API is contained in a small C bridge loaded with `dlopen`. Failure to load it must never prevent keyboard, mouse, rules, or actions from working. This approach is unsuitable for Mac App Store review and must be regression-tested on every supported macOS release.

## Product wording

The trigger editor exposes gesture type, finger count, and starting quadrant. Runtime status must distinguish “Global avançada” from the public system-gesture fallback.

## Revisit criteria

Replace the private provider if Apple introduces a supported global raw-touch API. Until then, keep the ABI bridge isolated, dynamically loaded, and covered by synthetic recognizer tests.
