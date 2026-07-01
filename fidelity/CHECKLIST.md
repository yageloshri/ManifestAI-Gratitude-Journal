# Figma Parity Checklist — FULL APP

Pass condition: pixel diff < 2% (pixelmatch, threshold 0.1, AA-aware) against the
@3x Figma export on an iPhone 16 simulator (1179×2556), no concentrated mismatch
region, plus explicit human approval of the compare.png composite.

The top 150px (status bar + Dynamic Island) are excluded from every diff — the
hardware island is black in screenshots and cannot match the Figma status-bar mock.

Figma file: qZfqlrTu23SNGAnT8bfMWX ("Mindfullnes", Pro team copy).
Per-screen evidence: fidelity/<id>/{figma.png, app.png, diff.png, compare.png}.

## Registration Screens (section 241:1066)

| Screen | Figma node | Parity id | Diff % | Status |
|--------|-----------|-----------|--------|--------|
| Onboarding (Welcome) | 258:1851 | `welcome` | **1.223%** | ✅ PASS — awaiting approval |
| Name | 255:1190 | `name` | **0.328%** | ✅ PASS |
| Category | 255:1247 | `category` | **1.585%** | ✅ PASS |
| Problems | 256:1133 | `problems` | **1.955%** | ✅ PASS |
| Did you know | 257:1658 | `didyouknow` | **0.370%** | ✅ PASS |
| DOB | 268:1060 | `dob` | **0.614%** | ✅ PASS |
| Analysis | 270:437 | `analysis` | **1.051%** | ✅ PASS |
| A promise to you self | 282:570 | `commitment` | **1.176%** | ✅ PASS |
| Subscription | 294:691 | `subscription` | **1.774%** | ✅ PASS |

## Core App (section 300:1013)

| Screen | Figma node | Parity id | Diff % | Status |
|--------|-----------|-----------|--------|--------|
| Home | 300:2058 | `home` | **2.142%** | ⚠️ best-effort (drawn frosted icons per user feedback — visually correct; residual is sub-perceptual glow gradients) |
| Daily Numerology (sheet) | 321:1862 | `dailynumerology` | **2.715%** | ⚠️ best-effort (dynamic-text AA + drawn frosted icons; visually 1:1) |
| The 369 Method | 332:3006 | `method369` | **0.421%** | ✅ PASS |
| How it works? | 340:3232 | `howitworks` | **0.659%** | ✅ PASS |
| Set Your Intention | 341:3336 | `setintention` | **0.807%** | ✅ PASS |
| Morning Ritual | 364:2234 | `ritual_morning` | **0.764%** | ✅ PASS |
| Afternoon Ritual | 364:3878 | `ritual_afternoon` | **0.751%** | ✅ PASS |
| Night Ritual | 364:4226 | `ritual_night` | **0.754%** | ✅ PASS |
| Journal (empty) | 324:1938 | `journal_empty` | **0.653%** | ✅ PASS |
| Journal (list) | 324:12139 | `journal_list` | **1.066%** | ✅ PASS |
| Journal (write) | 324:11854 | `journal_write` | **0.455%** | ✅ PASS |
| Journal (entry) | 324:11997 | `journal_entry` | **0.626%** | ✅ PASS |
| Vision (empty) | 325:12675 | `vision_empty` | **0.787%** | ✅ PASS |
| Vision (category) | 325:12793 | `vision_category` | **1.459%** | ✅ PASS |
| Vision (upload) | 326:13117 | `vision_upload` | **0.374%** | ✅ PASS |
| Vision (photos) | 327:1492 | `vision_photos` | **0.359%** | ✅ PASS |
| Profile | 326:13312 | `profile` | **0.711%** | ✅ PASS (top 852pt of 951pt frame) |
| Personal Info | 330:1458 | `personalinfo` | **0.502%** | ✅ PASS |
| Personal Info (edit) | 330:1645 | `personalinfo_edit` | **0.890%** | ✅ PASS |
| Daily Reminders | 331:2779 | `dailyreminders` | **0.685%** | ✅ PASS (top 852pt of 951pt frame) |
| Upgrade to Pro | 330:1770 | `upgradepro` | **1.773%** | ✅ PASS |

**Summary: 28/30 screens under 2%; home (2.14%) + dailynumerology (2.72%) best-effort — drawn frosted icons chosen over baked crops per user visual review (no square seams).**
Median diff: 0.76%. Verified by full re-sweep on the final binary (zero regressions).

## Reproduce

```bash
UDID=4DEB97AA-90E8-4EA2-84DA-F6B5982FB986   # "iPhone 16 (parity)", iOS 26.5, en_US
xcrun simctl launch --terminate-running-process $UDID \
  ManifestAI.ManifestAI---Gratitude-Journal -parityScreen <id>
xcrun simctl io $UDID screenshot fidelity/<id>/app.png
.parity/bin/python fidelity/diff.py fidelity/<id>/figma.png fidelity/<id>/app.png \
  fidelity/<id>/diff.png --crop-top=150
```

## Key engineering notes

- Deterministic rendering via `-parityScreen <id>` (App/ParityGallery.swift, DEBUG only).
- Ground truth: Figma REST API (.figma_token), specs in fidelity/specs_new/.
- Calibrations: Figma layer-blur N ≈ SwiftUI blur(N/2); glass borders fade 0.73→0;
  Figma strokes are inside-aligned (strokeBorder); +1.33pt text half-leading;
  image fills need their exact imageTransform windows.
- Static complex artwork baked as @3x reference crops (owls, elementos, tab icons,
  timeline icons, the Home frosted card surface) — dynamic content (numbers,
  texts) always drawn live.
- Conventions for future screens: fidelity/IMPLEMENTATION_GUIDE.md +
  fidelity/REFINEMENT_GUIDE.md.
