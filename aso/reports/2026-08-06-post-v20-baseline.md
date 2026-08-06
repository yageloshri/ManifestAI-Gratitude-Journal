# Post-v2.0 BASELINE scan — 2026-08-06 ("hour zero")

**Scan:** `2026-08-06T09:12Z` · 56 keyword×storefront pairs · public iTunes Search API
(`entity=software&limit=200`), rank = index of trackId `6757018484` + 1 ·
3.1 s throttle · **0 errors, 0 retries, 0 retried storefronts.**

**Baseline compared against:** `aso/rankings/latest.json` @ `2026-08-05T02:28Z`
(the blue-ocean merge, 707 rows). Merged in place → **716 rows**, date bumped.

**Release context.** v2.0 approved and READY_FOR_SALE ~2026-08-06 (submitted 08-05).
Shipped: new subtitles for **ko** (`감사일기 & 비전보드`), **ja** (`引き寄せ & 感謝日記`),
**he** (`הכרת תודה • נומרולוגיה`); rebuilt keyword fields for ko, ja, tr, ar-SA, he, ru,
de-DE, nl-NL, es-ES, es-MX, pt-BR; and two brand-new locales **pt-PT** and **zh-Hant**
(HK + TW) that had literally zero presence before.

Apple's index normally needs 24–72 h, so this reading was expected to be flat.
**It is not.** Indexing has already begun — see the verdict.

Legend: `—` unranked (not in top 200) · `n/t` not previously tracked ·
`ENTERED` = was unranked, now ranked · `pool` = live result count for that query.

---

## Rank table by locale

### ko — KR (new subtitle `감사일기 & 비전보드` + rebuilt keyword field)

| term | country | prev (08-05) | now (08-06) | delta | pool |
|---|---|---|---|---|---|
| 369 기법 | kr | — | **#1** | **ENTERED** | 2 |
| 끌어당김 | kr | #14 | #14 | 0 | 53 |
| 확언 | kr | #172 | #174 | -2 | 191 |
| 감사일기 | kr | — | — | — | 184 |
| 비전보드 | kr | — | — | — | 192 |

`369 기법` is the v2.0 `기법` token landing instantly (3-char token, pool of 2 → #1).
The two subtitle targets `감사일기` / `비전보드` are still unranked: both are big pools
(184 / 192) dominated by established diary apps (Daybloom 6449351571, 클로디, 레모리) —
subtitle-driven ranking there is the 48–72 h test.

### ja — JP (new subtitle `引き寄せ & 感謝日記` + rebuilt keyword field)

| term | country | prev (08-05) | now (08-06) | delta | pool |
|---|---|---|---|---|---|
| 引き寄せ | jp | #46 | **#41** | **+5** | 130 |
| 369 | jp | — | **#24** | **ENTERED** | 169 |
| 感謝日記 | jp | — | — | — | 179 |
| ビジョンボード | jp | — | — | — | 188 |
| アファメーション | jp | — | — | — | 185 |

`引き寄せ` +5 is the subtitle's first token already re-weighting. Bare `369` entering at
#24 in a 169-app pool is notable — that pool is mostly noise (bus apps, card games,
Camera360), so #24 is a real relevance signal, not a thin pool. `感謝日記` still unranked
against a same-named incumbent (`感謝日記 - 感謝の習慣で心を整える` 6747438279 at #5).

### he — IL (new subtitle `הכרת תודה • נומרולוגיה` + rebuilt keyword field)

| term | country | prev (08-05) | now (08-06) | delta | pool |
|---|---|---|---|---|---|
| שיטת 369 | il | — | **#1** | **ENTERED** | 1 |
| מספרי מלאכים | il | — | **#1** | **ENTERED** | 2 |
| נומרולוגיה | il | — | **#12** | **ENTERED** | 20 |
| מניפסטציה | il | #1 | #1 | 0 | 9 |
| חוק המשיכה | il | #2 | #2 | 0 | 5 |
| יומן תודה | il | #19 | #20 | -1 | 66 |

**Cleanest confirmation in the whole scan.** All three blue-ocean picks from
2026-08-05 (`שיטת` token, `מספרי` construct form, and the standalone-word subtitle fix
for `נומרולוגיה`) went from unranked to ranked in one release. `נומרולוגיה` #12/20 is
the subtitle working exactly as theorised — the ו-prefix block is gone.

### tr — TR (rebuilt keyword field, `yöntemi` in / `niyet` out)

| term | country | prev (08-05) | now (08-06) | delta | pool |
|---|---|---|---|---|---|
| 369 yöntemi | tr | — | **#1** | **ENTERED** | 2 |
| melek sayıları | tr | #5 | #5 | 0 | 6 |
| şükür günlüğü | tr | #6 | #6 | 0 | 7 |
| manifest | tr | #45 | #53 | **-8** | 197 |
| çekim yasası | tr | #58 | #65 | **-7** | 87 |

`yöntemi` landed at #1. The two negatives are the cost side of the swap — `manifest`
and `çekim yasası` both slipped mid-pool. Watch these two at 48 h; if they keep sliding
the `niyet` removal cost more head-term weight than expected.

### ar-SA — SA + AE (rebuilt keyword field, `قانون` added)

| term | country | prev (08-05) | now (08-06) | delta | pool |
|---|---|---|---|---|---|
| قانون الجذب | sa | — | **#19** | **ENTERED** | 21 |
| قانون الجذب | ae | — | **#16** | **ENTERED** | 21 |
| ارقام الملائكة | sa | n/t | **#3** | NEW TRACK | 4 |
| ارقام الملائكة | ae | #3 | #3 | 0 | 4 |
| لوحة الرؤية | sa | #7 | #8 | -1 | 38 |

Blue-ocean #1 global free win (`قانون الجذب`, unranked in all 5 Arabic storefronts)
is now ranked in both scanned storefronts — but at the *bottom* of a 21-app pool.
Entry achieved, weight not yet. Re-check eg/kw/qa next round.

### ru — RU (rebuilt keyword field)

| term | country | prev (08-05) | now (08-06) | delta | pool |
|---|---|---|---|---|---|
| ангельские числа | ru | — | **#3** | **ENTERED** | 3 |
| манифест: аффирмации | ru | #3 | #3 | 0 | 9 |
| метод 369 | ru | #1 | #2 | **-1** | 21 |
| закон притяжения | ru | n/t | **—** | NEW TRACK | 18 |

`ангельские числа` entered (pool of 3 — take #1 by strengthening, easy). `метод 369`
lost #1 to a rival. **`закон притяжения` is the one outright miss**: still unranked in
an 18-app pool, and #1 is held by a direct-clone competitor literally titled
**`Manifest: Закон Притяжения` (6761632544)** — the `привлечение`→`притяжения` swap has
not indexed yet, or did not take. Highest-priority re-check at 48 h.

### de-DE — DE (rebuilt keyword field, `methode` added)

| term | country | prev (08-05) | now (08-06) | delta | pool |
|---|---|---|---|---|---|
| 369 methode | de | #9 | **#8** | **+1** | 21 |
| engelszahlen | de | #6 | #6 | 0 | 9 |
| dankbarkeitstagebuch | de | #23 | #23 | 0 | 29 |

Slow but positive. `dankbarkeitstagebuch` has been pinned at #20–23 since v1.9 — it is
the DE structural problem, not a v2.0 regression.

### nl-NL — NL (rebuilt keyword field, `methode` added)

| term | country | prev (08-05) | now (08-06) | delta | pool |
|---|---|---|---|---|---|
| 369 methode | nl | #11 | **#7** | **+4** | 22 |
| visiebord | nl | #5 | #5 | 0 | 5 |

Best non-entry mover of the round. `methode` did in NL what it only half-did in DE.

### es-ES — ES (rebuilt keyword field, `metodo` + `ia` back in)

| term | country | prev (08-05) | now (08-06) | delta | pool |
|---|---|---|---|---|---|
| ia 369 | es | — | **#5** | **ENTERED** | 9 |
| metodo 369 | es | n/t | **#6** | NEW TRACK | 7 |
| numeros angelicos | es | #2 | #3 | -1 | 3 |

`ia 369` recovered — it was lost in v1.9 when the `ia` token was dropped, now back at #5.
Note the accented `método 369` row was `—` on 08-05; the unaccented query now ranks #6.

### es-MX — MX (rebuilt keyword field)

| term | country | prev (08-05) | now (08-06) | delta | pool |
|---|---|---|---|---|---|
| metodo 369 | mx | n/t | **#6** | NEW TRACK | 8 |
| numeros angelicos | mx | #2 | #3 | -1 | 3 |
| numerologia | mx | — | — | — | 160 |

`numerologia` remains the MX gap (pool 160, unranked) — a real head term, still uncaptured.

### pt-BR — BR (rebuilt keyword field)

| term | country | prev (08-05) | now (08-06) | delta | pool |
|---|---|---|---|---|---|
| metodo 369 | br | #4 | #4 | 0 | 5 |
| manifestar | br | #69 | **#66** | **+3** | 197 |
| diario de gratidao | br | n/t | #195 | NEW TRACK | 196 |

`diario de gratidao` at #195/196 is effectively dead last — BR's weakest tracked term.

### pt-PT — PT ⭐ BRAND-NEW LOCALE (zero presence before)

| term | country | prev (08-05) | now (08-06) | delta | pool |
|---|---|---|---|---|---|
| metodo 369 | pt | — | **#3** | **ENTERED** | 3 |
| manifestar | pt | n/t | **#75** | NEW TRACK | 188 |
| diario de gratidao | pt | n/t | **#113** | NEW TRACK | 171 |

**pt-PT is LIVE and INDEXED.** The Portugal storefront returns our listing under its
localized title `Manifest: Vision Board e 369`, ranked in all three queries including
a top-3. Every one of these was `—` or absent on 08-05. Also: PT `metodo 369` (#3/3)
now outranks BR's own `metodo 369` position relative to pool size.

### zh-Hant — HK + TW ⭐ BRAND-NEW LOCALE (zero presence before)

| term | country | prev (08-05) | now (08-06) | delta | pool |
|---|---|---|---|---|---|
| 天使數字 | hk | — | **#8** | **ENTERED** | 11 |
| 天使數字 | tw | — | **#12** | **ENTERED** | 13 |
| 顯化 | hk | — | **#89** | **ENTERED** | 188 |
| 感恩日記 | hk | n/t | **#111** | NEW TRACK | 187 |
| 感恩日記 | tw | n/t | **#153** | NEW TRACK | 189 |
| 顯化 | tw | — | — | — | 181 |

**zh-Hant is LIVE and INDEXED in both storefronts.** 5 of 6 queries now return us where
all six were zero. `天使數字` top-10 in HK on day zero. The one hole is TW `顯化`
(unranked, pool 181) while HK `顯化` ranks #89 — same metadata, different storefront
weighting; HK indexed slightly ahead of TW (also visible in 天使數字 #8 vs #12 and
感恩日記 #111 vs #153). TW is simply lagging HK by a few hours, not broken.

TW `顯化` competitive set is crowded with purpose-built rivals:
`hana 顯化感恩日記` (6753666263), `Lumina 顯化日記` (6758100569),
`Manifestly：顯化與吸引力法則` (6753106552) — this will be a fight, not a free win.

### en-US — US (ASA spillover spot-check; no v2.0 metadata change)

| term | country | prev (08-05) | now (08-06) | delta | pool |
|---|---|---|---|---|---|
| gratitude app | us | #187 | **#107** | **+80** | 187 |
| gratitude jar | us | — | **#127** | **ENTERED** | 172 |
| angel numbers | us | — | — | — | 152 |

US metadata did **not** change in v2.0, so a +80 jump on `gratitude app` and a fresh
entry on `gratitude jar` are most plausibly **paid-traffic velocity feeding organic** —
the ASA launch campaign is starting to move the needle. `angel numbers` is still
unranked despite being in the v1.9 US subtitle (`Gratitude & Angel Numbers`) —
that remains the stubborn US anomaly, now 5 days old.

---

## Scoreboard

| outcome | count |
|---|---|
| ENTERED (unranked → ranked) | **14** |
| improved | 4 (`引き寄せ` +5, `369 methode` nl +4, `manifestar` br +3, `gratitude app` us +80) |
| flat | 10 |
| declined | 7 (worst: `manifest` tr -8, `çekim yasası` tr -7) |
| still unranked | 7 |
| new tracks (no prior baseline) | 10 |

### Flagged: new-locale presence (was ZERO)

| locale | storefront | queries ranked | best |
|---|---|---|---|
| pt-PT | pt | **3 / 3** | #3 `metodo 369` |
| zh-Hant | hk | **3 / 3** | #8 `天使數字` |
| zh-Hant | tw | **2 / 3** | #12 `天使數字` |

### Flagged: ko / ja / he subtitle targets

| subtitle target | locale | status |
|---|---|---|
| נומרולוגיה | he | ✅ **#12** — subtitle fix worked, ו-prefix block cleared |
| הכרת תודה (`יומן תודה`) | he | ~ #20, flat |
| 引き寄せ | ja | ✅ **#41 (+5)** — moving |
| 感謝日記 | ja | ❌ still `—` (pool 179, same-name incumbent) |
| 감사일기 | ko | ❌ still `—` (pool 184) |
| 비전보드 | ko | ❌ still `—` (pool 192) |

Subtitle terms in *small* pools indexed immediately; subtitle terms in *large* pools
(179–192 apps) have not. That is the expected pattern — big-pool subtitle ranking
depends on download velocity, not just token presence, and is the 48–72 h test.

---

## Verify next round (2026-08-07, ~24–48 h)

1. **ru `закон притяжения`** — highest priority. If still `—` in an 18-app pool, the
   `привлечение`→`притяжения` swap did not take; verify the live ru keyword field via
   `asc_client.get_version_localizations()`.
2. **ko `감사일기` / `비전보드` and ja `感謝日記`** — the big-pool subtitle test.
3. **tr `manifest` / `çekim yasası`** — confirm the -8 / -7 slide is scan noise and not
   the cost of dropping `niyet`.
4. **TW catch-up** — expect `顯化` to enter and all TW ranks to converge toward HK.
5. **ar-SA `قانون الجذب`** — should climb from #16–19; also scan eg / kw / qa where it
   was unranked on 08-05.
6. **US `angel numbers`** — 6th day unranked despite subtitle presence; and confirm
   whether `gratitude app` / `gratitude jar` hold (ASA velocity) or fall back.

Not committed, not pushed. `aso/rankings/latest.json` updated in place
(716 rows, date `2026-08-06T09:12Z`); `history.jsonl` intentionally untouched —
this is a targeted 56-pair scan, not a full snapshot (same precedent as the 08-05 merge).
