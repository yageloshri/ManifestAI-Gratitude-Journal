# BLUE OCEAN MAP — 2026-08-05

Mission: highest-popularity x lowest-competition terms across ALL viable storefronts
(25 tracked + 25 secondary storefronts of languages we already ship).

**Method.** Competition = live pool size from the iTunes Search API (limit 200).
Popularity = Astro (US) / Apple hints order in the language's primary storefront
(the MZSearchHints endpoint rate-limited us all afternoon — 503 on every storefront —
so secondary-storefront popularity uses the same-language primary harvest as proxy;
re-harvest hints for AR/AE/IN/PT/UA/AT/BE next round). 221 new keyword x storefront
pairs measured live (now merged into `aso/rankings/latest.json`, 707 rows);
491 existing pairs reused, not re-queried.

Classification: **FREE WIN** = small pool, relevant, we're unranked (one metadata
token = instant top-10) · **CHEAP CLIMB** = rank 11-50 in a small pool ·
**FORTRESS** = already top-10, defend.

---

## TOP 20 GLOBAL FREE WINS

| # | keyword | storefronts | popularity proxy | pool | our rank | fix (one action) |
|---|---------|-------------|------------------|------|----------|------------------|
| 1 | قانون الجذب (law of attraction) | sa, ae, eg, kw, qa | hint p1 (sa seed) | 20 | — in all 5 | add `قانون` to ar-SA keywords |
| 2 | método 369 | es, mx, ar, cl, co, pe | "369" hint p1 es/mx | 6–7 | — in all 6 | add `metodo` to es-ES + es-MX (drop `numerologia` — duplicates subtitle) |
| 3 | ia 369 | es | hint p1 (mx p2) | 8 | LOST (#6 in July, `ia` dropped in v1.9) | re-add `ia` to es-ES |
| 4 | закон притяжения | ua (19), kz (0), by (0) | ru seed p1 | 0–19 | — | swap `привлечение`→`притяжения` in ru |
| 5 | метод 369 | ua (2), kz (0), by (0); defends RU #5 | 369 hint p1 ru | 0–2 | — | add `метод` to ru |
| 6 | ангельские числа | ru | hint p1 (ангельск seed) | 2 | — | add `ангельские,числа` to ru |
| 7 | доска визуализации желаний | ru | hint p1 | 12 | — | add `визуализации` to ru (title has доска+желаний) |
| 8 | מספרי מלאכים (angel numbers) | il | hint p1 (angel seed) | 1 | — | add `מספרי` to he (construct form; `מספרים` doesn't stem-match) |
| 9 | שיטת 369 (369 method) | il | 369 hint p1 il | 0 | — | add `שיטת` to he |
| 10 | נומרולוגיה | il | subtitle word, blocked by ו-prefix | 20 | — | he subtitle `הכרת תודה • נומרולוגיה` (standalone word) |
| 11 | 369 yöntemi / 369 tekniği | tr | 369-family hints p1-p5 | 1 / 0 | — | add `yöntemi` to tr (drop `niyet`) |
| 12 | metoda 369 | pl | 369-family | 1 | — | add `metoda` to pl |
| 13 | 369 기법 | kr | 369 hint p1 kr | 1 | — | add `기법` to ko (3 chars) |
| 14 | 369 methode | de (#11/21), at (#8), ch (#8), nl (#11/22) | hint family p1-p4 de | 21–23 | 8–11 | add `methode` to de-DE and nl-NL → top-5 in 4 storefronts |
| 15 | visionstavla / visjonstavle / visionstavle | se (6), no (6), dk (1) | vision-seed compounds | 1–6 | — | add compound token per locale (sv/no/da) |
| 16 | taknemmelighedsdagbog / takknemlighetsdagbok | dk (5), no (5) | hint p1 (taknem seeds) | 5 | — | add compound token to da + no |
| 17 | visiotaulu + kiitollisuuspäiväkirja | fi | hint p1 seeds | 3 / 6 | — | add both compounds to fi (drop widget/tarot/horoskooppi) |
| 18 | phương pháp 369 | vn | 369 hint p2 vn | 0 | — | add `phương,pháp` to vi (drop `mantra`) |
| 19 | papan visi + metode 369 | id | vision/369 seeds | 11 / 1 | — | add `papan,visi,metode` to id (drop zodiak/horoskop/mantra) |
| 20 | Portugal + zh-Hant locale gaps | pt (pools 2–5), hk/tw (pools 10–33) | — | 2–33 | — everywhere | add pt-PT locale (clone pt-BR) + zh-Hant locale (translate zh-Hans) |

Runners-up: no `manifestere` (pool 9, —) — add to no; be `loi de l'attraction`
(pool 23, — despite fr tokens; verify BE indexing next round);
us `369 journal` #12 (pool 179 — velocity climb, bonus-tracked now).

---

## Per-language map

### English — us, gb, au, ca + NEW: ie, nz, in, ph, sg, za, ng
All 11 storefronts serve our identical en metadata; secondaries confirmed live.

| keyword | storefronts | pop | pool | rank | class | action |
|---|---|---|---|---|---|---|
| 369 method | ie/nz/in/sg/za/ng | hint p1-p2 family | 22–30 | #4/#7/#9/#5/#6/#4 | FORTRESS | none — free inheritance from v1.9 `method` token |
| 369 method | ph | same | 22 | #14 | CHEAP CLIMB | velocity only |
| 369 method | us/gb/ca/au | Astro pop 5 | 30–37 | #6/#3/#3/#13 | FORTRESS (au climb) | defend |
| 369 journal | us | — | 179 | #12 | CLIMB | bonus-tracked; `journal` token live |
| gratitude journal | ie/sg/za/ng | hint p1 | ~190 | #80–127 | red ocean | subtitle velocity fight |
| 369 | ie | — | 187 | #29 | CLIMB | watch |
| gratitude jar | us | pop 17 diff 7 | — | — | gap | `jar` token shipped in v1.9 — recheck next scan |

### Spanish — es, mx + NEW: ar, cl, co, pe
es-MX serves all LatAm storefronts (confirmed: identical pools/ranks in ar/cl/co/pe).

| keyword | storefronts | pop | pool | rank | class | action |
|---|---|---|---|---|---|---|
| numeros angelicos | es/mx/ar/cl/co/pe | hint p1 es | 2 | #2 everywhere | FORTRESS | defend |
| método 369 | all 6 | 369 p1 | 6–7 | — everywhere | **FREE WIN** | add `metodo` token |
| ia 369 | es | hint p1 | 8 | LOST | **FREE WIN** | re-add `ia` |
| ley de atraccion | ar/cl/co/pe | hint p1 seed | 66 | #36/#50/#42/#30 | CLIMB | tokens live; velocity |
| manifestacion | ar/cl/co/pe | hint p1 | 107 | #55/#85/#60/#48 | CLIMB | velocity |
| tablero de vision / diario de gratitud | all | hint p1 | ~190 | — | red ocean | v1.9 subtitle carries; wait for velocity |

### Portuguese — br + NEW: pt
**Finding: pt-BR metadata does NOT index in Portugal** (br #4-#6 on the same terms PT shows us unranked).

| keyword | storefront | pool | rank | class | action |
|---|---|---|---|---|---|
| metodo 369 | pt | 2 | — | **FREE WIN** | requires pt-PT locale (clone pt-BR fields) |
| numeros dos anjos | pt | 3 | — | **FREE WIN** | same |
| quadro de visualizacao | pt | 5 | — | **FREE WIN** | same |
| metodo 369 / numeros dos anjos | br | 5–6 | #4 / #5 | FORTRESS | defend |

### Arabic — sa + NEW: ae, eg, kw, qa
ar-SA serves the whole Gulf+Egypt (confirmed: ارقام الملائكة #3 in all four new storefronts).

| keyword | storefronts | pool | rank | class | action |
|---|---|---|---|---|---|
| قانون الجذب | sa/ae/eg/kw/qa | 20 | — all 5 | **FREE WIN** | add `قانون` (field has only `الجذب`) |
| طريقة 369 | sa | 1 | — | **FREE WIN** | add `طريقة` |
| ارقام الملائكة | ae/eg/kw/qa | 4 | #3 | FORTRESS | defend |
| لوحة الرؤية | kw/eg/qa/ae | 35–36 | #5/#9/#9/#13 | FORTRESS/CLIMB | subtitle carries; velocity in ae |

### German — de + NEW: at, ch (confirmed inheritance)
| keyword | storefronts | pool | rank | class | action |
|---|---|---|---|---|---|
| 369 methode | de/at/ch | 21–25 | #11/#8/#8 | CLIMB/FORTRESS | add `methode` token → top-5 all three |
| engelszahlen | at/ch | 9 | #6/#7 | FORTRESS | defend |
| dankbarkeitstagebuch | de/at/ch | 25–28 | #22/#14/#18 | CHEAP CLIMB | subtitle compound shipped v1.9; velocity |
| visionboard (one word) | de | 192 | — | red ocean | skip |

### French — fr + NEW: be, ch, ca(fr)
| keyword | storefronts | pool | rank | class | action |
|---|---|---|---|---|---|
| méthode 369 | fr/be/ch/ca | 20–62 | #7/#7/#8/#6 | FORTRESS | defend |
| nombres angeliques | fr/be/ch | 2 | #1/#2/#2 | FORTRESS | defend |
| loi de l'attraction | be | 23 | — | GAP | fr tokens exist but don't index in BE — verify BE locale routing next round |
| journal de gratitude | fr | 190 | #142 | red ocean | velocity |

### Dutch — nl + NEW: be (confirmed: nl-NL indexes in BE)
| keyword | storefronts | pool | rank | class | action |
|---|---|---|---|---|---|
| visiebord | be | 6 | #6 | FORTRESS | defend |
| engelengetallen | be | 4 | #3 | FORTRESS | defend |
| manifesteren / dankbaarheidsdagboek | be | 19 / 16 | #13 / #14 | CHEAP CLIMB | velocity |
| 369 methode | nl | 22 | #11 | CHEAP CLIMB | add `methode` (drop `manifestatie`) |

### Russian — ru + NEW: ua, kz, by
ru metadata indexes in UA (манифест #7). **KZ/BY: ru localization appears NOT indexed**
(манифест unranked in 4-app pools) — treat as low-priority until verified.

| keyword | storefronts | pool | rank | class | action |
|---|---|---|---|---|---|
| манифест | ua | 16 | #7 | FORTRESS | defend |
| метод 369 | ua (2), kz/by (0) | 0–2 | — | **FREE WIN** | add `метод` to ru |
| закон притяжения | ua (19), kz/by (0) | 0–19 | — | **FREE WIN** | swap `привлечение`→`притяжения` |
| ангельские числа | ru | 2 | — | **FREE WIN** | add `ангельские,числа` |
| доска визуализации желаний | ru | 12 | — | **FREE WIN** | add `визуализации` |
| дневник благодарности | by | 10 | — | gap | rides the same ru edit if BY indexing confirmed |

### Hebrew — il
| keyword | pool | rank | class | action |
|---|---|---|---|---|
| שיטת 369 | 0 | — | **FREE WIN** | add `שיטת` |
| מספרי מלאכים | 1 | — | **FREE WIN** | add `מספרי` |
| נומרולוגיה | 20 | — | **FREE WIN** | subtitle `הכרת תודה • נומרולוגיה` (ו-prefix blocks indexing) |
| יומן תודה | 64 | #20 | CLIMB | v1.9 subtitle carries; velocity |

### Turkish — tr
369 yöntemi (pool 1) / 369 tekniği (pool 0) — **FREE WIN**: add `yöntemi`, drop `niyet`.
melek sayıları #5 (pool 6) FORTRESS. şükran günlüğü #27/44 climb (şükür günlüğü #6 held).

### Polish — pl
metoda 369 (pool 1) — **FREE WIN**: add `metoda`, drop `przebudzenie`. liczby anielskie #2 (pool 3) FORTRESS.

### Scandinavian — se, no, dk, fi
Compound-word free wins (compounds need their own token — cross-field combination can't form them):
- sv: `visionstavla` (pool 6, —), `metoden` → "369 metoden" (pool 2); tacksamhetsdagbok #11/11 → subtitle already carries, velocity.
- no: `visjonstavle` (6, —), `takknemlighetsdagbok` (5, —), `manifestere` (9, —), `metoden` (pool 2).
- da: `taknemmelighedsdagbog` (5, —), `visionstavle` (1, —), `metoden` (1); englenumre #1 FORTRESS.
- fi: `visiotaulu` (3, —), `kiitollisuuspäiväkirja` (6, —); enkelinumerot #2, manifestointi #9 FORTRESS.

### Asian — jp, kr, cn + NEW: hk, tw
- jp `369の法則` **#1** (pool 8) — new fortress, defend. 369メソッド #6.
- kr `369 기법` (pool 1, —) — **FREE WIN**: add `기법` (+3 chars). 엔젤넘버 #20/61 climb.
- cn `369法则` #2 (pool 7) FORTRESS; 显化法则 #9/59 FORTRESS edge.
- hk/tw: `天使數字` pools 10/12, hk `願景板` pool 33 — all unranked; zh-Hans doesn't serve zh-Hant storefronts → add zh-Hant locale in v2.0.

### Vietnamese — vn
`phương pháp 369` (pool 0, —) FREE WIN: add `phương,pháp` (drop `mantra`).
`bảng tầm nhìn` (pool 15, —): native "vision board" — consider subtitle swap later.

### Indonesian — id
`metode 369` (pool 1, —), `papan visi` (pool 11, —) FREE WINs: add `papan,visi,metode`
(drop `zodiak,horoskop,mantra`). angka malaikat #2 (pool 2) FORTRESS.

---

## Proposed keyword-field edits (v2.0 batch) — before/after

| locale | before (chars) | after (chars) |
|---|---|---|
| ar-SA | `تاروت,اللاوعي,الروحانية,تطوير,الذات,تأمل,الطاقة,الكون,الملائكة,الجذب,عرافة,تدوين,تحفيز` (86) | `قانون,الجذب,طريقة,اللاوعي,الروحانية,تطوير,الذات,تأمل,الطاقة,الكون,الملائكة,تدوين,تحفيز` (86) |
| es-ES / es-MX | `manifestacion,manifestar,afirmaciones,positivas,diarias,ley,atraccion,numeros,angelicos,numerologia` (99) | `manifestacion,manifestar,afirmaciones,positivas,diarias,ley,atraccion,numeros,angelicos,metodo,ia` (97) |
| ru | `дневник,аффирмации,ангелы,духовность,таро,саморазвитие,вселенная,ритуал,привлечение,энергия,цели` (96) | `дневник,аффирмации,ангельские,числа,метод,притяжения,визуализации,саморазвитие,ритуал,духовность` (96) |
| he (kw) | `אפירמציות,חוק,המשיכה,משיכה,רוחניות,מלאכים,מספרים,התעוררות,ריטואל,שפע,הגשמה,טארוט,מדיטציה` (88) | `אפירמציות,חוק,המשיכה,משיכה,רוחניות,מלאכים,מספרי,מספרים,התעוררות,ריטואל,שפע,הגשמה,שיטת,מדיטציה` (93) |
| he (subtitle) | `הכרת תודה ונומרולוגיה` | `הכרת תודה • נומרולוגיה` |
| tr | `...,ruhsal,bolluk,niyet` (95) | `tezahür,çekim,yasası,melek,sayıları,olumlamalar,vizyon,panosu,şükür,günlüğü,ruhsal,bolluk,yöntemi` (97) |
| pl | `...,dziennik,przebudzenie` (94) | `manifestacja,prawo,przyciagania,anielskie,liczby,afirmacje,tablica,wizji,dziennik,metoda` (88) |
| de-DE | `...,dankbarkeitstagebuch,wünsche` (95) | `manifestieren,gesetz,anziehung,engelszahlen,affirmationen,tagebuch,dankbarkeitstagebuch,methode` (95) |
| nl-NL | `manifesteren,manifestatie,wet,...` (96) | `manifesteren,wet,aantrekking,engelengetallen,dagboek,dankbaarheidsdagboek,visiebord,methode` (91) |
| sv | `dagbok,änglanummer,affirmationer,attraktionslagen,andlighet,tarot,självutveckling,horoskop,ritual` (97) | `dagbok,änglanummer,affirmationer,attraktionslagen,andlighet,självutveckling,visionstavla,metoden` (96) |
| no | `dagbok,tarot,englenumre,bekreftelser,tiltrekningsloven,åndelighet,selvutvikling,widget,spirituell` (97) | `dagbok,englenumre,bekreftelser,tiltrekningsloven,åndelighet,visjonstavle,manifestere,metoden` (92) |
| da | `dagbog,bekræftelser,englenumre,spiritualitet,tarot,selvudvikling,manifestation,ritual,universet` (95) | `dagbog,bekræftelser,englenumre,manifestation,taknemmelighedsdagbog,visionstavle,metoden,ritual` (94) |
| fi | `manifestointi,päiväkirja,enkelinumerot,affirmaatiot,henkisyys,widget,tarot,itsetuntemus,horoskooppi` (99) | `manifestointi,enkelinumerot,affirmaatiot,henkisyys,itsetuntemus,kiitollisuuspäiväkirja,visiotaulu` (97) |
| vi | `tarot,affirmation,angelnumber,luathapdan,tamlinh,cunghoangdao,tuvi,mayman,chualanh,mantra` (89) | `affirmation,angelnumber,luathapdan,tamlinh,cunghoangdao,tuvi,mayman,chualanh,phương,pháp,tarot` (94) |
| ko | `...차크라` (71) | append `,기법` (74) |
| id | `tarot,afirmasi,spiritual,zodiak,horoskop,angka,malaikat,semesta,energi,rejeki,mantra,meditasi,ritual` (100) | `tarot,afirmasi,spiritual,angka,malaikat,semesta,energi,rejeki,meditasi,ritual,papan,visi,metode` (95) |

New locales for v2.0: **pt-PT** (clone pt-BR metadata) and **zh-Hant** (translate zh-Hans)
— they unlock Portugal, Hong Kong and Taiwan where we currently do not index at all.

All edits are PROPOSALS — nothing PATCHed to ASC. They ship with the next editable version (v2.0).
`aso/bonus_keywords.json` updated (+22 phrases) so the weekly tracker follows every new target.

## Verify next round
1. Re-run `python3 aso/rank_tracker.py` post-v2.0: expect unranked→top-10 flips on rows 1-13 of the Top 20 within days of release.
2. Re-harvest hints for ar/ae/in/pt/ua/at/be once MZSearchHints stops 503ing (use 4-5s throttle; the harvester burned the quota today).
3. Verify KZ/BY ru-indexing and BE fr-indexing anomalies.
4. Watch AU "369 method" #13 (only English storefront where we're outside top 10).
