# Metadata proposals — July 2026 (highest-popularity targets round)

Per the standing strategy (2026-07-12): target the HIGHEST-popularity terms per
country. Popularity source: Apple Search Hints order per storefront
(`aso/targets/<cc>.json`, harvested 2026-07-12 via `hints_harvester.py`),
plus Astro real popularity for the US. Current ranks: `aso/targets/ranks.json`
+ baseline scan `aso/rankings/latest.json`.

**PROPOSALS ONLY — nothing applied to ASC.** All changes land with the next
app version. Keyword-field rule reminders: ≤100 chars, single tokens,
comma-separated, no spaces, no words duplicated from that locale's
name/subtitle (Apple indexes those separately; combinations across
title+subtitle+keywords match multi-word phrases).

**Core structural fix in every market:** the current keyword fields use
concatenated phrases (`angelnumbers`, `lawofattraction`, `gesetzanziehung`,
`leydeatraccion`, …). Apple treats each as ONE token that only matches itself
(that's why we're #1 in 1-result pools — vanity ranks). Splitting them into
single words unlocks the real phrases ("angel numbers", "law of attraction",
"gesetz der anziehung") at their true popularity.

---

## en-US (United States)

**Current**
- Title (28/30): `Manifest: Vision Board & 369`
- Subtitle (30/30): `Gratitude Journal & Numerology`
- Keywords (99/100): `manifestation,spiritualawakening,angelnumbers,lawofattraction,luckygirl,tarot,affirmation,widget,ai`

**Proposed**
- Title (28/30): `Manifest: Vision Board & 369` — KEEP. Already carries the two
  biggest US terms: vision board (pop 58), manifest (pop 44), plus 369.
- Subtitle (30/30): `Gratitude Journal & Numerology` — KEEP (gratitude journal
  pop 32; currently #111 — this is a velocity fight, not an indexing gap).
- Keywords (95/100): `manifestation,affirmations,angel,numbers,law,attraction,method,scripting,daily,jar,subconscious`

**Expected effect**
- `angel,numbers` → "angel numbers" (pop 14, diff 15, hints p1) — currently NOT
  indexed (concatenated token). Also "angel numbers & meanings" (p2).
- `law,attraction` → "law of attraction" (hints p2; stop word "of" is ignored
  by Apple's matcher). Replaces the #32-in-47-results vanity token.
- `method` + title 369 → "369 method" (pop 5, diff 23, 32-result pool — very
  winnable).
- `manifestation` + subtitle `journal` → "manifestation journal" (pop 10,
  hints p3).
- `daily` + `affirmations` → "daily affirmations" (pop 6).
- `scripting` → "scripting manifestation" (pop 5, diff 15).
- `jar` + subtitle `gratitude` → "gratitude jar" (pop 17, diff 21 — best
  pop/difficulty ratio in the US niche set).
- Dropped: `tarot` (unranked in 191-pool, off-positioning), `luckygirl`,
  `spiritualawakening`, `ai`, `widget` (unranked, low relevance).

---

## en-GB (United Kingdom)

**Current** — identical to en-US (title 28, subtitle 30, keywords 99).

**Proposed**
- Title / Subtitle: KEEP (same rationale; "gratitude journal" is hints p1 in
  GB and we're #72 — strengthen via velocity, indexing is fine).
- Keywords (95/100): `manifestation,affirmations,angel,numbers,law,attraction,method,scripting,daily,jar,subconscious`

**Expected effect**
- "angel numbers" (hints p1 GB), "law of attraction" (p2, currently #44 via
  concatenated token in a 62-pool — real pool is ~200), "manifest: daily
  affirmation"-type phrases (title `manifest` + `daily` + `affirmations`),
  "369 method" (28-result pool, unranked today → indexed).

---

## de-DE (Germany)

**Current**
- Title (28/30): `Manifest: Vision Board & 369`
- Subtitle (25/30): `Dankbarkeit & Numerologie`
- Keywords (91/100): `manifestation,engelszahlen,gesetzanziehung,luckygirl,tarot,affirmationen,widget,ki,täglich`

**Proposed**
- Title (28/30): `Manifest: Vision Board & 369` — KEEP (vision board is hints
  p1 in DE; manifest p2).
- Subtitle (28/30): `Dankbarkeitstagebuch & Engel`
- Keywords (93/100): `manifestieren,gesetz,anziehung,engelszahlen,affirmationen,numerologie,dankbarkeit,tagebuch,ki`

**Expected effect**
- Subtitle compound `Dankbarkeitstagebuch` → the #1 "dankbar" completion.
  Today we are UNINDEXED for it (0/24 results — a 24-app pool!). This is the
  single cheapest big win in this round.
- `dankbarkeit` + `tagebuch` tokens → "dankbarkeit tagebuch" (hints p3) and
  bare "dankbarkeit" (p2).
- `manifestieren` → the #1 "manif" completion in DE (currently only "manifest"
  via title; "manifestieren app" bonus phrase unranked in 83-pool).
- `gesetz,anziehung` → "gesetz der anziehung" (hints p1 for its seed) —
  replaces the #1-of-1 vanity token `gesetzanziehung`.
- `numerologie` preserved from old subtitle (differentiator + search term).
- `Engel` (subtitle) supports "engel"-family searches alongside kw
  `engelszahlen` (already #7).
- Dropped: `manifestation` (DE users type manifestieren/manifest),
  `luckygirl`, `tarot`, `widget`, `täglich`.

---

## fr-FR (France)

**Current**
- Title (29/30): `Manifest : Vision Board & 369`
- Subtitle (23/30): `Gratitude & Numérologie`
- Keywords (98/100): `manifestation,eveilspirituel,nombresangeliques,loidattraction,luckygirl,tarot,affirmations,widget,ia`

**Proposed**
- Title (29/30): `Manifest : Vision Board & 369` — KEEP.
- Subtitle (30/30): `Journal de gratitude & tableau`
- Keywords (93/100): `manifestation,affirmations,positives,loi,attraction,nombres,angeliques,methode,numerologie,ia`

**Expected effect**
- Subtitle `tableau` + title `vision` → **"tableau de vision"** — the actual
  French term (hints p1/p2 for its seed; we assumed "tableau de
  visualisation", which barely autocompletes). Key discovery of this harvest.
- Subtitle → "journal de gratitude" (hints p7, bonus scan: unranked in
  191-pool today).
- `manifestation` (hints p1 FR, unranked in 187-pool — the big fight, now
  reinforced by exact token + phrase combos like "manifestation gratuit"…
  note: "gratuit" intentionally not added; low integrity, we're freemium).
- `affirmations,positives` → "affirmation positive" (p1) & "affirmations
  positives gratuite"-family.
- `loi,attraction` → "loi de l'attraction" (p1; elisions/stop words ignored)
  — replaces `loidattraction` (#1-of-1 vanity).
- `nombres,angeliques` → "nombres angéliques" (replaces concatenated token).
- `methode` + title 369 → "méthode 369" (15-result pool, unranked today).
- `numerologie` moved from subtitle to keywords (no net loss).

---

## es-ES (Spain) + es-MX (Mexico) — same proposal, two locales

**Current (both)**
- Title (28/30): `Manifest: Vision Board y 369`
- Subtitle (22/30): `Gratitud y Numerología`
- Keywords (97/100): `manifestacion,despertarespiritual,numeroangelical,leydeatraccion,luckygirl,tarot,afirmaciones,ia`

**Proposed (both)**
- Title (28/30): `Manifest: Vision Board y 369` — KEEP.
- Subtitle (28/30): `Diario de gratitud y tablero`
- Keywords (99/100): `manifestacion,manifestar,afirmaciones,positivas,diarias,ley,atraccion,numeros,angelicos,numerologia`

**Expected effect**
- Subtitle → "diario de gratitud" (hints p1 ES / p2 MX; unranked in ~185-pool
  today) and `tablero` + title `vision` → "tablero de visión" (hints p1 in
  both — unranked in ~185-pool today).
- `manifestacion` (hints p1 both; we're ES #48 / MX #71 — keep the exact token
  AND free up title+subtitle synergies).
- `manifestar` (hints p2-3; bonus scan unranked in ~192-pool).
- `afirmaciones,positivas,diarias` → "afirmaciones positivas diarias" (p1 in
  both markets) + subsets.
- `ley,atraccion` → "ley de atracción" (replaces `leydeatraccion`, currently
  #1-of-1 / #2-of-2 vanity).
- `numeros,angelicos` → "números angélicos" (hints p1 ES — note: angélicos,
  not the "angelicales" form we had concatenated).
- `numerologia` preserved from old subtitle.
- "Gratitud" remains matched (contained in "gratitud" token of subtitle).

---

## pt-BR (Brazil)

**Current**
- Title (28/30): `Manifest: Vision Board e 369`
- Subtitle (22/30): `Gratidão e Numerologia`
- Keywords (99/100): `manifestacao,despertarespiritual,numeroangelical,leidaatracao,luckygirl,tarot,afirmacoes,widget,ia`

**Proposed**
- Title (28/30): `Manifest: Vision Board e 369` — KEEP.
- Subtitle (30/30): `Diário de gratidão, afirmações`
- Keywords (96/100): `manifestacao,manifestar,lei,atracao,diarias,anjos,numeros,quadro,visualizacao,numerologia,metodo`

**Expected effect**
- Subtitle → "diário de gratidão" (hints p2; unranked in 195-pool today),
  "gratidão" (hints p1 — contained), "afirmações" (currently #185!) and
  `afirmações` + `diarias` → "afirmações diárias" (hints p1).
- `lei,atracao` → "lei da atração" (hints p1; replaces `leidaatracao` #24-of-24
  vanity).
- `manifestacao` (#52 unaccented / #41 accented — reinforce; hints p2).
- `numeros,anjos` → "números dos anjos" family (replaces `numeroangelical`).
- `quadro,visualizacao` → "quadro de visualização" (bonus scan: 6-result pool,
  unranked → indexing = instant top-6).
- `metodo` + title 369 → "método 369" (2-result pool!).
- `numerologia` preserved from old subtitle.

---

## ja (Japan)

**Current**
- Title (21/30): `引き寄せ手帳:ビジョンボード&369の法則`
- Subtitle (13/30): `感謝日記×毎日の数秘術占い`
- Keywords (66/100): `スピリチュアル,タロット,アファメーション,開運,エンジェルナンバー,潜在意識,願望実現,目標達成,自己啓発,瞑想,星座,ヴィジョン`

**Proposed**
- Title (21/30): KEEP — 引き寄せ (p1-p3 hints family), ビジョンボード (p1/p2),
  369, 法則 (→引き寄せの法則 p2) all covered.
- Subtitle (13/30): KEEP — 感謝日記 is the p1 "感謝" completion.
- Keywords (64/100): `アファメーション,エンジェルナンバー,潜在意識,願望実現,ノート,スピリチュアル,開運,タロット,自己肯定感,目標達成,自己啓発`

**Expected effect**
- `ノート` + title `引き寄せ` → **引き寄せノート** — the #1 "引き寄せ"
  completion in Japan, currently uncovered. Also 感謝ノート (p3) via subtitle
  感謝 + ノート.
- Keeps エンジェルナンバー (#80 → push), 潜在意識 (#115), アファメーション
  (p1 hint, unranked in 184-pool — long fight), 願望実現 (#26).
- `自己肯定感` new (huge JP wellness term, adjacent to 確言/アファ audience).
- Dropped: `星座` (unranked, astrology-only), `瞑想` (unranked in 168-pool),
  `ヴィジョン` (katakana variant, #7 in a 7-app pool — vanity).

---

## he (Israel)

**Current**
- Title (25/30): `מניפסטציה: לוח חזון ו-369`
- Subtitle (21/30): `הכרת תודה ונומרולוגיה`
- Keywords (77/100): `יומן,אפירמציות,חוק,משיכה,רוחניות,טארוט,מלאכים,מספרים,התעוררות,מודעות,ריטואל,תת,מודע`

**Proposed**
- Title (25/30): KEEP — #1 on מניפסטציה, #9 on לוח חזון.
- Subtitle (26/30): `יומן הכרת תודה ונומרולוגיה`
- Keywords (88/100): `אפירמציות,חוק,המשיכה,משיכה,רוחניות,מלאכים,מספרים,התעוררות,ריטואל,שפע,הגשמה,טארוט,מדיטציה`

**Expected effect**
- Subtitle adds `יומן` adjacent to `תודה` → strengthens "יומן תודה" (#52
  today) and "יומן הכרת תודה" phrases; תודה itself is the p1 Hebrew hint.
  (`יומן` removed from keywords — would now be a duplicate.)
- `המשיכה` new token → exact "חוק המשיכה" match (unranked in 176-pool today;
  currently only stemless חוק+משיכה, #41 on משיכה).
- `שפע` (abundance) and `הגשמה` (attainment/manifesting) — native-Hebrew niche
  terms the store hints can't surface (Hebrew autocomplete is thin — only the
  369/תודה seeds returned data).
- `מדיטציה` new; keeps working ranks: אפירמציות #8, מלאכים #3, ריטואל #1,
  רוחניות #23, התעוררות #24, טארוט #43.
- Dropped: `מודעות`, `תת`, `מודע` (all unranked; תת+מודע split never matched
  "תת מודע" visibly).

---

## Rollout notes

- All 9 localization edits (en-US, en-GB, de-DE, fr-FR, es-ES, es-MX, pt-BR,
  ja, he) ship with the next app version — batch them into the next editable
  version in ASC. No changes proposed for the other 16 locales this round
  (their harvests are in `aso/targets/` for the next iteration).
- After release: re-run `python3 aso/rank_tracker.py` weekly and
  `python3 aso/rank_targets.py` to watch the new targets; expect indexing
  effects (unranked→ranked in small pools) within days, velocity effects
  (big-pool climbs) over weeks.
- Update `aso/bonus_keywords.json` with the newly-targeted phrases so the
  weekly tracker follows them: "angel numbers", "tableau de vision",
  "diario de gratitud", "tablero de visión", "diário de gratidão",
  "afirmações diárias", "dankbarkeitstagebuch" (already), "dankbarkeit
  tagebuch", "引き寄せノート", "יומן הכרת תודה", "חוק המשיכה".
