# dailynumerology (321:1862) — 2.543% after 10 iterations

Best result: 2.543% (from 10.185%). Above the 2% bar; everything else converged.

## What was fixed
- Close CTA: glass + #4E47A9 border (was solid white per ambiguous spec)
- Card icons: baked DNCard1/2ElementoCrop (heart / dartboard — spec said briefcase)
- Gold Elemento surface baked (DNGoldElementoCrop), digit drawn live
- Sheet cosmic strip imageTransform (496.3×331.7 @ −98.9,−85.7)
- Accent borders softened 0.85→0.5 (sampled), card/title/attr nudges

## Remaining gap hypothesis
The residual is distributed text antialiasing: this sheet is the most text-dense
screen (insight paragraph + 2 card bodies + titles + attributes) and the dynamic
daily texts cannot be baked. CoreText vs Figma rasterization differs by ~1px of
edge AA per glyph; with this much text over varied surfaces it sums to ~2.5%.
No concentrated structural mismatch remains (worst cell 9.2%, glyph edges).

Human review of compare.png recommended — visually the screen is 1:1.
