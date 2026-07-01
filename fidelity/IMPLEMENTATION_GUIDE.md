# Figma Parity Implementation Guide (for screen-implementation agents)

You are implementing ONE OR MORE SwiftUI screens that must match a Figma frame
pixel-for-pixel. The spec for each screen is a tree dump at `fidelity/specs/<name>.txt`
with lines like:

```
[TEXT] 'Today' id=299:887  xywh=(93,188,244,21)  fill=#EBEBEB  font=Poppins Poppins-SemiBold 14.0pt w600 lh=21px ...  chars='Today'
[RECT] 'Rectangle 39318' id=...  xywh=(20,208,353,82)  fill=#FBFBFB@0.01  stroke=GRADIENT_LINEAR[#63507A:0, #332643@0:1] ... r=16.0  fx=[INNER_SHADOW...; BACKGROUND_BLUR(113)]
```

`xywh` is in points relative to the 393×852 frame. NEVER invent values — every
position, size, color, font and opacity comes from the spec line.

## Required structure for every screen view

```swift
struct XyzView: View {
    // mock-friendly inputs with defaults matching the Figma content exactly
    var parityMode: Bool = false

    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / 393
            let sy = geo.size.height / 852
            ZStack(alignment: .topLeading) {
                DesignTokens.Colors.background          // frame fill, usually #16062A
                // ... children as absolute offsets: .offset(x: X * sx, y: Y * sy)
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .accessibilityIdentifier("<screenid>.root")
    }
}
```

Position pattern for every element: build it at its Figma size
(`.frame(width: W * sx, height: H * sy, alignment: .topLeading)`) and place it
with `.offset(x: X * sx, y: Y * sy)` inside the topLeading ZStack. Do NOT use
VStack/Spacer layout for positioning (except gap-based stacks that exactly match
repeated Figma rows, e.g. lists with constant pitch).

## Existing shared components (USE THESE, do not re-implement)

- `DesignTokens` (Core/DesignSystem/DesignTokens.swift): colors
  (.background #16062A, .primary #685EF5, .secondary #FCD471, .textPrimary #EBEBEB,
  .textSecondary #B9B9B9, .lightGrey #9F9E9E, .glassBorder #63507A, .surfaceDark #291846,
  .streakCardBg #2C1855, …), typography (h1 = Bitter-SemiBold 26, h4 = Bitter-Bold 18,
  bodyMedium/bodyRegular/bodySemibold = Poppins 16, smallText/smallMedium/smallTextSemibold
  = Poppins 14, label = Poppins-Regular 12), Gradients.primary (#3B2DF7→#7C38FF),
  Gradients.golden (#FCD471→#BF8800), Radii (card=16, button=13, smallCard=12).
- `EllipseGlowBackground(sx:sy:xOffset:figmaOpacity:)` — the purple glow. Use the
  `fill=#4F31EC@<op>` value from the spec's 'Ellipse 1' line as figmaOpacity
  (default 0.29), and its x as xOffset (0 or -30).
- `Color.clear.figmaGlassSurface(cornerRadius:compact:)` — glass panel with the
  full Figma inset-shadow stack + fading gradient border. Use compact:false for
  big cards (≥100pt tall), compact:true for small controls.
- `FigmaTabBar(active:onSelect:sx:sy:)` — bottom tab bar at (0,774,393,78).
- `PrimaryButton(title:icon:action:)` — gradient CTA, height 56, radius 13.
- `GlassBackButton(action:)` — 56×56 glass square, purple arrow.
- `OnboardingStepper(currentStep:)` — 6-segment progress bar.
- `ArrowRightShape`, `CheckmarkShape`, `ChevronDownShape`, `ChevronRightSmallShape`,
  `VuesaxChevronShape` — stroke shapes for the recurring vector icons.
- 42×42 "Elemento" icon containers: copy the `elementoSmall(...)` pattern from
  `Features/Dashboard/HomeView.swift`.

## Conventions learned from passed screens (deviating WILL fail the pixel diff)

- Text vertical position: Figma `xywh` y is the text box top. SwiftUI text usually
  needs +1.33pt (Poppins 16/24) when you use lineSpacing; single-line labels are fine
  at the raw y. Multi-line text: set `.lineSpacing(figmaLineHeight - uifont.lineHeight)`
  via `UIFont(name:size:)` and add +1.33 * sy to the offset.
- Glass borders fade: never use a solid stroke for glass surfaces — that's what
  `figmaGlassSurface` is for. Selected/colored borders also fade (top alpha ≈0.84,
  bottom ≈0.45 for #685EF5 selections).
- Images with `mode=FILL` → `.resizable().scaledToFill().frame(...).clipped()`.
  `mode=STRETCH` → plain `.resizable().frame(...)` (exact box) — but check for an
  imageTransform note in the spec.
- Image fills reference assets by ref hash. If an imageset already exists in
  Assets.xcassets use it; otherwise note "NEEDS ASSET <ref> at <name>" in your report
  and render a clear placeholder (Color.clear) at the exact rect.
- Complex multi-path vector icons: use the closest SF Symbol at the Figma rect as a
  placeholder and add a `// PARITY-TODO: bake icon crop <node id>` comment.
- Interactive elements get `.accessibilityIdentifier("<screenid>.<element>")`.
- Keep all animation OFF when `parityMode == true`; default state must visually equal
  the Figma frame (same texts, same selection, same numbers).
- Status bar elements in the spec are SKIPPED (the device renders its own).
- Comment every element with its Figma node id, like the existing views.

## References to read before writing code

- `ManifestAI - Gratitude Journal/Features/Dashboard/HomeView.swift` (canonical example)
- `ManifestAI - Gratitude Journal/Features/Onboarding/Steps/PainPointsStepView.swift`
- `ManifestAI - Gratitude Journal/Core/DesignSystem/Components/FigmaGlassEffects.swift`

## Hard rules

- Create NEW files only; do NOT modify shared files (DesignTokens, FigmaGlassEffects,
  ParityGallery, existing screens). The orchestrator wires the gallery afterward.
- Pure SwiftUI, no extra dependencies, must compile against iOS 17+.
- File goes in the feature folder you're told, one view per screen.

## CRITICAL: positioning and hit-testing

NEVER place interactive elements with `.offset` — offset is a render-only
geometry effect; gestures stay at the un-offset layout slot, which makes the
whole screen feel dead. Use `.parityPosition(x:y:)` (View extension in
FigmaGlassEffects.swift): it positions via padding (layout-real, hit-testable)
and falls back to offset only for negative components (decorative crops).
Attach `.contentShape`/`.onTapGesture`/`.onLongPressGesture` BEFORE
`.parityPosition`, never after — otherwise the hit area covers the whole
padded rect from the origin and overlapping siblings steal taps.
