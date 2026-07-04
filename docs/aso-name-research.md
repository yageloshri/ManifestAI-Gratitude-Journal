# ASO Name + Subtitle Research — "Gratitude Journal: Manifest"

**Prepared:** July 2026 · **Method:** Free iTunes Search API (`itunes.apple.com/search`), no auth, real live App Store data pulled directly via `curl`/`jq` — not vibes. Cross-checked against 5 storefronts (US, GB, DE, BR, FR) and 2026 ASO best-practice research (WebSearch).

---

## 0. Headline finding before anything else

The app currently registered in App Store Connect — **"Gratitude Journal: Manifest"** (`id6757018484`) — was pulled live via `itunes.apple.com/lookup?id=6757018484`:

```json
{
  "trackName": "Gratitude Journal: Manifest",
  "releaseDate": "2026-01-20T08:00:00Z",
  "averageUserRating": 0,
  "userRatingCount": 0
}
```

**Zero ratings, zero reviews, released ~5.5 months ago.** This matters strategically: the standard ASO advice "don't destroy the keyword equity of a live, indexed app" (repeated in `docs/growth-plan-100k.md` §2.3) **does not apply here** — there is no equity yet to protect. This is functionally a pre-launch optimization window, not a rename-risk situation. That changes the recommendation materially from "tweak the subtitle only" to "pick the structurally best name+subtitle now, before any organic momentum builds."

Also flagged in passing (not this doc's core scope, but a real compliance risk): the current live app **description** opens with *"the #1 premium Gratitude Journal"* — Apple's Review Guidelines (2.3.7 / unverifiable superlative claims) can reject or require removal of unverifiable "#1" claims. Worth fixing regardless of which name/subtitle is chosen.

---

## 1. Method

1. Queried the free iTunes Search API for 21 candidate keywords across the US storefront (`entity=software&country=us&limit=25`), extracting `trackName`, `artistName`, `averageUserRating`, `userRatingCount` for the top 10 results per keyword. `userRatingCount` is used as the proxy for incumbent install-base/entrenchment strength — a keyword with top-10 incumbents in the low hundreds or single digits is a **weak-competition / high-opportunity** signal; a keyword whose top incumbents carry 50K–1M+ ratings is **effectively unwinnable for #1** in the near term.
2. Repeated the 6 highest-signal keywords across **GB, DE, BR, FR** to check whether weak-competition keywords are a US fluke or a global pattern.
3. WebSearched 2026 ASO best-practice sources (AppFollow, ASOMobile, AppRadar, Phiture) for title/subtitle/keyword-field weighting rules.
4. Built 8 App-Store-compliant name+subtitle candidate pairs (≤30 chars each field, no superlative claims, no competitor trademarks, no cross-field keyword duplication), scored against the real competition data.

---

## 2. Raw data — US storefront, top results per keyword

`resultCount` = total matches iTunes Search API returned (proxy for how "crowded" the term is as an app-title space). Rating count = incumbent strength.

### `gratitude journal` (23 results) — **SATURATED, avoid chasing #1**
| App | Publisher | Rating | # Ratings |
|---|---|---|---|
| Journal | Apple | 4.78 | 292,242 |
| Day One: Daily Journal & Diary | Bloom Built Inc | 4.83 | 117,082 |
| Gratitude: Self-Care Journal | Hapjoy Technologies | 4.88 | 44,875 |
| 5 Minute Journal | Intelligent Change LLC | 4.76 | 17,444 |
| Gratitude Plus – Journal | Redwheel Apps | 4.86 | 16,024 |
| stoic. mental health journal | Stoic app inc. | 4.82 | 34,899 |
| 365 Gratitude Journal & Diary | UofHappy, LLC | 4.76 | 4,503 |

**Read:** Apple's own bundled "Journal" app alone has 292K ratings. #1 here is not a realistic near-term target regardless of naming.

### `gratitude journal manifest` (24 results, exact current phrase)
| App | Publisher | Rating | # Ratings |
|---|---|---|---|
| **Gratitude Journal: Manifest** | **Yagel Oshri (this app)** | 0 | 0 |
| Gratitude: Self-Care Journal | Hapjoy Technologies | 4.88 | 44,875 |
| Gratitude Plus – Journal | Redwheel Apps | 4.86 | 16,024 |
| 5 Minute Journal | Intelligent Change LLC | 4.76 | 17,444 |
| Vision Board Gratitude Journal | Tuan Hoang Anh | 0 | 0 |
| Myla : Manifest & Vision Board | Succeed Software LLC | 4.79 | 691 |

**Read:** exact-title match puts this app first by string relevance today (0 rating count doesn't hurt exact-title matching), but the broader "gratitude journal" incumbents still bleed into this query.

### `369 method` (19 results) — **BLUE OCEAN**
| App | Publisher | Rating | # Ratings |
|---|---|---|---|
| Myla : Manifest & Vision Board | Succeed Software LLC | 4.79 | 691 |
| Manifest Anything - 369 App | Jackson Fall | 0 | 0 |
| 369 Manifestation & Meditation | Thomas Mayrl | 2.33 | **12** |
| 369 Journal: Manifestation | Tejas Rane | 0 | 0 |
| 369 Manifestation Journal | Bram Kanstein | 0 | 0 |

**Read:** the direct-competitor named explicitly in `growth-plan-100k.md` as "near feature-parity" (369 Manifestation & Meditation) has **12 total ratings**. Nearly every other dedicated 369 app has zero. Most of the top-10 slots are irrelevant apps (photo/camera tools) that happen to rank on the string "369" — meaning there is essentially no entrenched incumbent to beat.

### `369` alone (13 results) — **noisy, not a clean target**
Dominated by irrelevant giants (365Scores 116K ratings, Life360 2.9M ratings) that happen to contain "36" or number matches — bare "369" is not a clean keyword to chase standalone; must be paired with "method"/"manifestation"/"journal".

### `daily numerology` (15 results) — **BLUE OCEAN, best single find**
| App | Publisher | Rating | # Ratings |
|---|---|---|---|
| Daily Numerology | Manoj . | 4.60 | **5** |
| Numerology Rediscover Yourself | Mirofox | 4.83 | 2,269 |
| Numerology Tarot Card Reading | Touchzing Media | 4.43 | 4,910 |
| Tarot Numerology: Card Reading | Exomind LTD | 4.30 | 1,720 |
| Daily Horoscope & Numerology | NBApps | 4.83 | 35 |

**Read:** the app that owns the exact phrase "Daily Numerology" as its name has **5 total ratings**. This is the single weakest incumbent found across all 21 keywords tested, directly on a term ManifestAI's actual daily-numerology feature already matches.

### `numerology` (broad, 25 results) — moderate
| App | Publisher | Rating | # Ratings |
|---|---|---|---|
| Nebula: Spiritual Guidance | Spiritual Nebula Limited | 4.57 | 170,411 |
| Tarot & Numerology | Phuture Me Limited | 4.78 | 6,135 |
| CUE Astrology | Cue | 4.76 | 6,274 |
| Numerology Rediscover Yourself | Mirofox | 4.83 | 2,269 |
| Numerology Tarot Card Reading | Touchzing Media | 4.43 | 4,910 |

**Read:** one giant (Nebula, broad astrology app) dominates, but everything below it is winnable-tier (2K–6K ratings), much softer than "gratitude journal."

### `angel numbers` (24 results) — moderate-weak
| App | Publisher | Rating | # Ratings |
|---|---|---|---|
| Angel Numbers Numerology | Pro Media Now Inc | 4.75 | 1,482 |
| Angel Number Signs | Frederic Calendini | 4.86 | 817 |
| Numerology & Astrology | Hanh Nguyen | 4.64 | 3,639 |
| Angel Numbers & Meanings | Free Apps LLC (CA) | 4.91 | 80 |
| Angel no.27 | Swapnil Singh | 4.69 | 16 |

### `manifestation journal` (23 results) — moderate
| App | Publisher | Rating | # Ratings |
|---|---|---|---|
| Manifest & Affirmations - Soul | Matthew Leong | 4.85 | 3,558 |
| Manifest: Daily Journal | Transcend Labs Inc. | 4.75 | 2,410 |
| Manifest•Manifestation Journal | David Manso | 4.65 | 85 |
| Manifestation Journal | The Dream Company UG | 4.39 | 33 |
| Lumina Manifestation Journal | Nathan Mueller | 5.0 | 1 |

### `manifestation app` / `manifest` (broad, 25 results each) — moderate-hard
Top real competitors: Manifest & Affirmations - Soul (3,558), Stella - Manifest Anything (3,733), Manifest: Daily Journal (2,410). But "I am - Daily Affirmations" (719,853) and "CHANI" (55,225) also surface here as tangential giants — broad "manifest" is contestable in the mid-tier but not for the #1 slot overall.

### `vision board` (24 results) — moderate
Real competitors cluster 300–4,600 ratings (Vision Board & Goal Tracker 3,734; Vision Board ++ Maker Manifest 2,957; Vision Board Perfectly Happy 4,594). Canva dominates the raw result set but is functionally irrelevant (photo/video editor, not a manifestation app) — doesn't block a real #1 shot among *relevant* apps.

### `law of attraction` (25 results) — moderate
Law of Attraction Toolbox leads real competitors at 2,949 ratings; most others under 1,100.

### `lucky girl` (22 results) — near-zero competition, but **low relevance signal**
Top dedicated app "Lucky Girl: Manifest Gratitude" has **6 ratings**; most of the result set is irrelevant (makeup/dress-up games, pool-party games) — suggests the App Store search index doesn't yet strongly associate "lucky girl" with manifestation apps, i.e., low proven *search* volume even though competition is trivially weak. Cheap keyword-field addition, not a title/subtitle anchor.

### `affirmations` / `daily affirmations` / `self care journal` (23-24 results each) — **SATURATED**
"I am - Daily Affirmations" (719,853 ratings), "Motivation - Daily quotes" (1,057,774), "Finch: Self-Care Pet" (722,394), "Day One" (117,082). Avoid as title anchors; fine as low-priority keyword-field long-tail only.

### `scripting manifestation` (24 results) — very low volume, mostly irrelevant results (Scriptation PDF app, Saged meditation) bleeding in. Not a reliable standalone target.

---

## 3. International spot-check (GB, DE, BR, FR) — does the blue ocean hold globally?

| Keyword | US top real incumbent (ratings) | GB | DE | BR | FR |
|---|---|---|---|---|---|
| **369 method** | 12 | 1 (369 Manifestation & Meditation) | 2 | 0 | 0 |
| gratitude journal | 292,242 (Apple Journal) | 35,878 (Apple Journal) | 8,181 (Day One DE) | 1,847 (Day One) | 26,202 (Apple Journal) |
| numerology | 170,411 (Nebula) | 1,821 (Daily Horoscope) | 439 (Numerologie Mirofox) | 928 (Numerologia Touchzing) | 471 (Mirofox) |
| manifestation | 719,853 (I am, tangential) | 44,413 (I am, tangential) | 17,907 (I am DE) | 43,976 (I am BR) | 24,800 (I am FR) |
| vision board | 3,734 | 1,092 (Moodboard) | 1,051 (Hero21) | 1,860 (Maryna Aliakseichyk) | 319 (Moodboard) |
| law of attraction | 2,949 | 2,529 (Mantra, tangential) | 287 (Human Design) | 141 | 137 |

**Confirmed:** "369"-anchored terms are weak-competition in **every** storefront tested — this is not a US-only artifact. Direct 369-named apps sit at 0-2 ratings in GB/DE/BR/FR versus 12 in the US. "Gratitude journal" is saturated everywhere (Apple's own Journal app alone: 292K US / 35.9K GB / 26.2K FR ratings). Numerology is moderate everywhere, never a single-app-dominated field the way gratitude journal is (except Nebula in US specifically, which is a broad astrology app, not a numerology-specific one).

---

## 4. ASO best-practice findings (2026, via WebSearch)

- **Weighting is strict hierarchy: Title > Subtitle > hidden Keyword field.** A keyword placed in the 30-char title outranks the same word placed anywhere else. ([AppFollow](https://appfollow.io/blog/app-store-optimization-title), [AppRadar](https://appradar.com/academy/app-store-ranking-factors))
- **160 total indexed characters**: 30 (title) + 30 (subtitle) + 100 (hidden keyword field). Apple's algorithm **combines words across fields** for multi-word query matching — a word in the title and a different word in the subtitle can still jointly match a two-word search query, even without being adjacent in the same field. ([AppScreenshotStudio](https://appscreenshotstudio.com/blog/app-store-metadata-for-indie-devs-title-subtitle-keywords-2026), [Udonis](https://www.blog.udonis.co/mobile-marketing/mobile-apps/complete-guide-to-app-store-optimization))
- **Never repeat a word across title/subtitle/keyword-field** — Apple counts it once; a repeat is wasted character budget. All candidates below were checked programmatically for zero word overlap.
- Apple Review Guideline 2.3.7 disallows unverifiable superlative claims ("#1", "best") in metadata — flagged above as an existing issue in the live description, unrelated to name/subtitle but worth fixing in the same pass.

Sources: [AppFollow 2026 Title Playbook](https://appfollow.io/blog/app-store-optimization-title), [AppRadar ASO Ranking Factors 2026](https://appradar.com/academy/app-store-ranking-factors), [ASOMobile 2026 Guide](https://asomobile.net/en/blog/aso-in-2026-the-complete-guide-to-app-optimization/), [AppScreenshotStudio Metadata Guide](https://appscreenshotstudio.com/blog/app-store-metadata-for-indie-devs-title-subtitle-keywords-2026), [Phiture ASO Trends 2026](https://phiture.com/asostack/aso-trends-in-2026/)

---

## 5. Candidate name + subtitle pairs

All checked programmatically: ≤30 chars/field, zero word-overlap between title and subtitle, no competitor trademarks, no superlative claims.

| # | Name (chars) | Subtitle (chars) | Keywords targeted | Difficulty (from §2-3 data) | Opportunity |
|---|---|---|---|---|---|
| **A — Baseline** | Gratitude Journal: Manifest (27) | 369 Method & Daily Numerology (29) | gratitude journal, manifest / 369, method, daily, numerology | "Gratitude journal" saturated (100K+ incumbents); 369/numerology blue-ocean but only in subtitle (weaker ranking slot) | Safe, minimal-change, but under-weights the one real opportunity by putting it in the weaker field |
| **B — Runner-up** | Manifest: 369 & Numerology (26) | Gratitude Journal + Vision (26) | manifest, 369, numerology (title) / gratitude, journal, vision (subtitle) | Both blue-ocean terms (12 & 5 rating incumbents) now in the highest-weighted field; "gratitude journal" phrase preserved intact in subtitle for legibility/brand recognition | Best "minimal keyword-salad, still data-driven" option — very legible on the product page |
| **C — WINNER** | 369 Manifestation Journal (25) | Gratitude & Daily Numerology (28) | 369, manifestation, journal (title) / gratitude, daily, numerology (subtitle) | 369 = 12/5/0/0/0/2 ratings across 5 storefronts (blue ocean); "manifestation journal" = 2,410-3,558 (winnable-tier, not saturated); "daily numerology" = 5 ratings (blue ocean, exact match to a real shipped feature) | Highest expected value: puts the *strongest* blue-ocean term (369) in the title, and via Apple's cross-field combining, "journal"(title)+"gratitude"(subtitle) still jointly catch "gratitude journal" queries — gets 5 winnable keyword slots for the price of 2 fields |
| D | Manifest & Daily Numerology (27) | Gratitude Journal + 369 Method (30) | manifest, daily, numerology / gratitude, journal, 369, method | Similar to A but with manifest+numerology promoted to title | Good, but "369 Method" full phrase only in subtitle again |
| E | Manifest: AI Gratitude Journal (30, at limit) | 369 Method & Daily Numerology (29) | manifest, ai, gratitude, journal / 369, method, daily, numerology | Keeps "gratitude journal" in the title (max weight) despite it being unwinnable for #1 — trades a guaranteed-loss keyword for one impression-volume keyword | Only worth it if you value raw impression volume over #1 ranking odds; contradicts the task's #1 goal |
| F | AI Manifestation Journal (24) | 369 Method & Daily Numerology (29) | ai, manifestation, journal / 369, method, daily, numerology | Drops "gratitude" and "manifest" (exact form) entirely from the title | Riskiest — abandons the app's category-defining word ("gratitude") with no data showing "AI journal" alone is a meaningfully searched term |
| G | Manifest: Angel Numbers & 369 (29) | Daily Numerology & Gratitude (28) | manifest, angel, numbers, 369 / daily, numerology, gratitude | "angel numbers" is moderate-weak (817-1,482 top real incumbent) — a notch harder than 369/daily-numerology but still soft | Good alternate if angel-numbers demand (TikTok trend) proves stronger than App-Store-search demand suggests |
| H | Manifest: Vision Board & 369 (28) | Gratitude Journal + Numerology (30) | manifest, vision, board, 369 / gratitude, journal, numerology | Vision board = moderate (318-4,594) | Solid if vision-board is judged the stronger differentiator vs numerology |

---

## 6. Recommendation

### Winner: **Candidate C**
- **Name:** `369 Manifestation Journal` (25 chars)
- **Subtitle:** `Gratitude & Daily Numerology` (28 chars)

**Why this wins over keeping the current name outright:** the current app has zero ratings and zero reviews — there is no existing ASO equity to protect, so the standard "don't rename a live indexed app" caution doesn't bind here. The data shows exactly one genuinely wide-open opportunity across 21 keywords and 5 storefronts: **"369"** and **"daily numerology"**, where the top *real* competitor sits at 12 and 5 total ratings respectively (vs. 44,875-292,242 for "gratitude journal"). Title placement carries the strongest ranking weight per 2026 ASO research, so the highest-expected-value move is putting the strongest blue-ocean term (369) directly in the title rather than the subtitle, while "manifestation journal" (2,410-3,558 ratings top incumbent — still meaningfully winnable, not saturated) rides along for free in the same 25 characters. The subtitle then recovers "daily numerology" as an exact phrase (the single weakest incumbent found in the entire study) and keeps "gratitude" present — which, combined with "journal" in the title, still catches "gratitude journal" queries via Apple's documented cross-field keyword combining, without pretending #1 on that saturated term is realistic.

### Runner-up: **Candidate B**
- **Name:** `Manifest: 369 & Numerology` (26 chars)
- **Subtitle:** `Gratitude Journal + Vision` (26 chars)

Nearly as strong on the data, but reads more cleanly on the App Store product page (keeps "Gratitude Journal" as an intact, recognizable phrase in the subtitle rather than split across fields) and adds "vision board" exposure instead of a second numerology mention. Pick this if legibility/brand-recognition on the storefront page matters more than squeezing one extra keyword slot.

### US Keywords field (100/100 chars, deduped against Candidate C's title+subtitle words: `369, manifestation, journal, gratitude, daily, numerology`)

```
angelnumber,visionboard,lawofattraction,luckygirl,tarot,widget,subconscious,affirmation,spiritual,ai
```

Verified: 100 characters exactly, 10 unique terms, zero overlap with title/subtitle words, all genuinely relevant to real shipped features (angel numbers ↔ numerology, vision board ↔ vision-board editor, law of attraction ↔ core theme, tarot ↔ adjacent-audience overlap confirmed in the numerology data, widget ↔ Home Screen widget, subconscious ↔ current app description's own framing, affirmation ↔ real feature, spiritual ↔ category fit, ai ↔ Gemini differentiator). "Lucky girl" is included cheaply despite low proven App-Store search relevance (near-zero real competitors, but mostly irrelevant results bled in) since it costs little and rides a live TikTok trend cited in `growth-plan-100k.md`. *Always re-verify the live character count in App Store Connect before saving.*

### Locale guidance (which storefronts translate vs. reuse English)

| Locale | Approach | Notes |
|---|---|---|
| en-US (base), en-GB, en-CA, en-AU | Use Candidate C as-is | Confirmed blue-ocean for "369"/numerology holds in GB data too (§3); zero incremental cost, same English build |
| fr-FR | Near-verbatim reuse | French "manifestation" and "journal" are true cognates (identical spelling) — `369 Manifestation Journal` reads naturally in French with no translation cost; subtitle: `Gratitude & Numérologie Quotidienne` |
| de-DE | Translate | `369-Manifestation-Tagebuch` (or A/B test keeping "Journal" English if trend data favors it); subtitle: `Dankbarkeit & Numerologie` — German 369-anchored terms also confirmed blue-ocean (§3) |
| pt-BR | Translate | `369 Diário de Manifestação` / `Gratidão e Numerologia Diária` — Brazilian data (§3) shows 369-anchored apps at 0 ratings, the widest-open storefront of the five tested |
| es-ES | Translate | `Diario de Manifestación 369` / `Gratitud y Numerología Diaria` |
| he-IL | Full translation, RTL-verified | Per existing `growth-plan-100k.md` §3.6 guidance — unchanged by this research |
| ja-JP / ko-KR | Deprioritized, watch-only | Per existing growth-plan guidance — different monetization norms there, out of scope for this naming pass |

---

## 7. Compliance check on the winner

- Title/subtitle contain no competitor trademarks (no "Nebula," "CHANI," "Day One," "Co-Star," etc.)
- No superlative/unverifiable claims ("#1," "best," "top") in either field
- No emoji, no keyword-stuffing beyond genuinely relevant feature terms (369 method, manifestation, journal, gratitude, daily numerology are all real, shipped features per `docs/growth-plan-100k.md` product facts section)
- Both fields at or under the 30-character Apple limit (verified programmatically, not by eye)

*All raw data in this document was pulled live via the free, unauthenticated `itunes.apple.com/search` and `itunes.apple.com/lookup` endpoints on the date of this research — re-run the same `curl` commands periodically, as competitor rating counts will shift as they gain installs.*
