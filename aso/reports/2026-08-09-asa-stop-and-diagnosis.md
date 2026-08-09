# ASA — full stop, and the reason (2026-08-09)

## Decision

All Apple Search Ads campaigns **PAUSED** 2026-08-09, on Yagel's approval, under the stop rule
agreed on 2026-08-08 ("15 more taps with 0 installs → pause everything").

| Campaign | Result | Final state |
|---|---|---|
| 2144404347 exact / US | 0 impressions in 44h | PAUSED |
| 2144414959 discovery / US | 657 impr, 9 taps, 0 installs, $15.35 | PAUSED |
| 2144421268 broad / GB-CA-AU | 820 impr, 23 taps, 0 installs, $38.14 | PAUSED |
| **Account lifetime** | **~1,480 impr, 32 taps, 0 installs, ~$53.5** | all stopped |

## The finding

The guard had flagged for four consecutive runs that 0 installs across 31 taps was statistically
impossible as bad luck (P = 0.099% at a 20% tap→install rate) and recommended ruling out an
attribution bug before blaming the product page. That check is now done, and it is **not**
attribution:

1. **ASA install counts do not depend on any app-side SDK.** Apple attributes tap-through installs
   server-side from App Store data; AdServices / AAAttribution exists for *third-party MMPs*, not for
   the numbers in Apple's own report. A missing framework cannot zero out this column.
2. **The product page itself explains it.** `itunes.apple.com/lookup` per storefront:

| Storefront | Ratings | Average | Screenshots |
|---|---|---|---|
| 🇬🇧 GB | **0** | — | 4 |
| 🇺🇸 US | **0** | — | 4 |
| 🇮🇱 IL | 2 | 3.0 | 4 |

Every ad tap in this test landed on a page with **no ratings, no reviews, and 4 of the 10 allowed
screenshots**. What it was competing against on `gratitude journal` / GB:

```
  9,941 ratings  4.8*  10 shots  Gratitude: Self-Care Journal
 37,527 ratings  4.7*   8 shots  Journal
 16,418 ratings  4.7*  10 shots  Day One
 14,040 ratings  4.7*  10 shots  Daylio
    519 ratings  4.9*   8 shots  Good Things gratitude journal
```

The ad was winning the auction (TTR 2.7%, above the US campaign's 1.37%) and losing the page. Paid
traffic converts worse than organic here, not better: an ad tap is a colder, more comparison-shopping
visitor than someone who already scrolled to us, and it arrives at the weakest possible page.

## Consequence for spend

Nothing about the keywords, bids, negatives or geography was the problem, so nothing about them is
worth fixing yet. Re-running paid acquisition before the product page has social proof would repeat
the same result at the same price. The 17 negatives, 10 keywords and the campaign structure are all
preserved and can be re-enabled in one call.

## Prerequisites before any ASA restart

1. **Ratings.** In-app rating prompt at a genuine success moment (completed 369 cycle / first
   gratitude streak). Nothing else on this list matters until the page shows a star count.
2. **Screenshots 5–10.** Six unused slots; the first two carry most of the decision.
3. Only then: re-enable 2144421268 unchanged and compare against this run's 32-tap baseline.

## What is unaffected

The organic side is working and needs no intervention — see the same-day SEO/ASO numbers: web clicks
14 → 47 week over week, 12 App Store #1s, 125 top-10 placements. Those channels deliver installs
against the same product page, which is the point: they cost nothing per visitor, so a weak
conversion rate is survivable there and fatal at $1.67/tap.
