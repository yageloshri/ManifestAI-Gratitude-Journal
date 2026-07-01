# Per-screen refinement protocol (for refinement agents)

You are tightening one or more ALREADY-IMPLEMENTED SwiftUI screens to <2% pixel
diff against their Figma reference. Work ONE screen at a time, max 6 build-diff
iterations per screen, then move on (note the final % either way).

## The loop (per screen)

```bash
cd /Users/yageloshri/ManifestAI-Gratitude-Journal
UDID=4DEB97AA-90E8-4EA2-84DA-F6B5982FB986
BUNDLE=ManifestAI.ManifestAI---Gratitude-Journal

# 1. build once per code change (use xcodebuild directly):
xcodebuild -project "ManifestAI - Gratitude Journal.xcodeproj" \
  -scheme "ManifestAI - Gratitude Journal" -configuration Debug \
  -destination "id=$UDID" -derivedDataPath /tmp/parity_dd build | tail -3
xcrun simctl install $UDID "/tmp/parity_dd/Build/Products/Debug-iphonesimulator/ManifestAI - Gratitude Journal.app"

# 2. render + capture:
xcrun simctl launch --terminate-running-process $UDID $BUNDLE -parityScreen <id>
sleep 3.5
xcrun simctl io $UDID screenshot fidelity/<id>/app.png

# 3. diff (reference: figma.png, or figma_852.png when the frame is 951pt tall):
.parity/bin/python fidelity/diff.py fidelity/<id>/figma.png fidelity/<id>/app.png \
  fidelity/<id>/diff.png --crop-top=150
```

PASS = pct < 2.0 AND no single huge concentrated blob. NOTE: the `region` lines
print coordinates in CROPPED space — add 150 to y for real screenshot pixels.

## Diagnosing (do these, in order, before changing code)

1. Crop fig|app|diff side-by-side around the worst region (PIL, like
   `fidelity/home/inspect_*.png` examples). LOOK at it.
2. Sample exact pixels (numpy) to compare colors — never guess a color delta.
3. Measure translation with the MSE shift search (window ±10) before assuming
   appearance differs. Low-MSE best shift (dy,dx) → apply offset nudge of
   dy/3, dx/3 pt. High MSE at best shift → appearance issue, not position.

## Known calibrations (apply, don't re-derive)

- Figma layer-blur N ≈ SwiftUI `.blur(radius: N/2)`, fill opacity carries over.
- Glass borders: `figmaGlassSurface` already fades 0.73→0; selected borders
  fade 0.84→0.48. Figma strokes are INSIDE-aligned → use `strokeBorder`
  for ≥3pt or high-contrast strokes.
- Multi-line text: +1.33pt y offset; set lineSpacing from UIFont.lineHeight.
- Tab bar: FigmaTabBar already calibrated (dark overlay 0.78 + items at 0.68).
- WHITE-FROSTED cards (white container fill behind glass): the journal card on
  Home bakes its frost from the reference (see the python in the conversation
  history of fidelity/home — derivation script pattern: alpha=(lum-bg)/(255-bg),
  mask content rects, interpolate, save as 3x imageset). If your screen has a
  frosted-white card, derive its frost the same way from ITS reference export
  into a new imageset (e.g. "XyzCardFrost"), masked under its texts.
- Static complex artwork (icons with glows, illustrations): BAKE a crop from
  the reference export into a 3x imageset and place it at the exact rect
  (pattern: ElementoLove, SubTimelineIcon1..3, AnalysisOwlCrop, CommitHandsCrop).
  Add a small margin (4-8pt) to capture glow, and bake from a region whose
  background your SwiftUI reproduces well.
- Raw Figma source images: /tmp/figma_images.json maps imageRef→S3 URL
  (download with urllib; key prefix-match the 12-hex ref from the spec).
- Image fills: FILL → scaledToFill+clipped; STRETCH+imageTransform
  [[a,0,tx],[0,d,ty]] → rendered size = box/(a,d), offset = (-tx,-ty)*rendered,
  clipped to the box.
- Specs (geometry ground truth): fidelity/specs_new/<id>.txt (USE THESE, not
  specs/). If an element renders differently than its spec suggests, fetch the
  node's full JSON: curl -s -H "X-Figma-Token: $(cat .figma_token)"
  "https://api.figma.com/v1/files/qZfqlrTu23SNGAnT8bfMWX/nodes?ids=<nodeid>"
  — check fills on CONTAINER frames (white underlays!), characterStyleOverrides
  on texts (mixed spans), imageTransform on image fills.

## Rules

- Never weaken the diff or crop extra regions to "pass".
- Keep parityMode semantics; don't break live behavior (animations stay for
  non-parity mode).
- Update fidelity/sweep_results.txt line for your screen with the final pct.
- Final message: raw data — per screen: final pct, iterations used, what changed.

## Frosted-container icons (Elemento) — PROVEN POLICY (2026-06-11)

User-validated rule: translucent/frosted containers must be DRAWN live (they
blend with the real background); baked rectangular crops of them show visible
square seams and harsh dark cores. Only OPAQUE artwork gets baked.

Per elemento:
1. DRAW the container: frost fill (LinearGradient #F8FBFF@0.07-0.12 → clear,
   topLeading→bottomTrailing), rim stroke (subtle! e.g. gold rim EABD4E@0.28→0.10
   at 1.5pt — NOT 0.6), inner color ring (color@0.10-0.20, lw≈container/5,
   blur≈lw/2, clipped), drop shadow black@0.08.
2. DRAW the glows: inner color rect (≈2/3 width, blur 12, opacity ~0.6, slightly
   below center) + bottom pool ellipse (opacity ~0.45, y≈container_h-4, blur 14).
   In Figma the pool is clipped by the container — keep it tight, it must NOT
   leak below (measure: fig goes dark within ~5pt below the container).
3. BAKE only the glyph: tight crop (icon rect +1pt), ring-median difference
   matte (scripts in conversation; gain 6→60). If the glyph sits ON a bright
   glow (non-uniform bg), bake glyph+glow TOGETHER as one wider soft crop
   (gain 5→45) and skip the drawn inner-rect glow for that icon
   (see Glyph369 + elementoSmall(glyphIncludesGlow:) in HomeView).
4. Verify BOTH ways: pixel diff (<2% or document) AND a zoomed fig|app crop of
   the icon — the eye catches seams the metric forgives.

Reference implementation: HomeView.swift (elementoSmall, goldNumberSmall),
ParityDailyNumerologyView.swift (insightCard mini-elementos, bigGoldElemento).
Baking helpers: the bake()/matte scripts used throughout (ring-median + local-bg
variants) — see fidelity/asset_backups for original baked versions.
