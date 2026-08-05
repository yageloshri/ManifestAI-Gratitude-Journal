#!/usr/bin/env python3
"""Prep for App Store version 2.0 — the "verified blue ocean + climb" metadata round.
Built 2026-08-06 from Astro-verified popularity/difficulty (see reports/2026-08-06-astro-verified.md
and reports/2026-08-05-blue-ocean.md).

Strategy per locale (pop/diff from Apple via Astro; floor = 5):
  ko    감사일기 pop 53/41 is Korea's real prize -> subtitle + field; keep 끌어당김 (#8), add 비전보드/기법
  ja    引き寄せ 17/42 (we are #27), ビジョンボード 11/41, 感謝日記 8/49, 369 8/11 -> field + subtitle
  tr    manifest 50/35 (we are #114) + yöntemi/tekniği empty pools -> field
  ar-SA قانون الجذب = biggest Arabic term (5 storefronts, hint p1, pool 20) -> add قانون + vision-board tokens
  he    #1 מניפסטציה / #2 חוק המשיכה already; add שיטת/מספרי/נומרולוגיה/יומן/תודה empty pools + subtitle
  ru    манифест #3, 369 #11 climbing; rebuild: метод/притяжения/ангельские числа/визуализации
  de-DE add methode (369 methode #11 -> top-5 play, also lifts AT/CH)
  nl-NL add methode (369 methode pool ~21, also lifts BE)
  es-ES restore ia (lost #6 "ia 369" in v1.9) + metodo (6 storefronts incl. LatAm inherit es-MX)
  es-MX metodo + ia; keeps afirmaciones positivas diarias (42/36)
  pt-BR add gratidao/diario (gratitude journal 7/21, manifestar 9/19 climbing)
  NEW LOCALES: pt-PT + zh-Hant (Portugal/HK/TW: we index NOTHING there today; pools 2-33)

Run:  python3 aso/prepare_v20.py --dry-run   (prints plan, no API calls)
      python3 aso/prepare_v20.py             (creates/patches draft version 2.0)
"""
import sys

from asc_client import req, APP_ID

NEW_VERSION = "2.0"

SUBTITLES = {
    # locale: (new subtitle, rationale)
    "ko": "감사일기 & 비전보드",            # gratitude journal (pop 53) & vision board
    "ja": "引き寄せ & 感謝日記",             # attraction (17, we #27) & gratitude journal
    "he": "הכרת תודה • נומרולוגיה",       # bullet not vav-prefix: ו-prefix kills indexing
}

KEYWORDS = {
    "ko": "감사일기,끌어당김,확언,비전보드,기법,엔젤넘버,시크릿,잠재의식,다이어리,명상,긍정,자기계발,드림보드,운세,타로",
    "ja": "引き寄せ,感謝日記,ビジョンボード,369,アファメーション,エンジェルナンバー,潜在意識,願望実現,ノート,スピリチュアル,開運,自己肯定感,目標達成,自己啓発",
    "tr": "tezahür,çekim,yasası,melek,sayıları,olumlamalar,vizyon,panosu,şükür,günlüğü,manifest,yöntemi,tekniği",
    "ar-SA": "قانون,الجذب,الملائكة,امتنان,لوحة,الرؤية,اللاوعي,الروحانية,تطوير,الذات,تأمل,الطاقة,الكون,تدوين",
    "he": "שיטת,נומרולוגיה,יומן,תודה,לוח,חזון,מספרי,מלאכים,אפירמציות,חוק,המשיכה,רוחניות,שפע,הגשמה",
    "ru": "метод,притяжения,ангельские,числа,визуализации,дневник,аффирмации,ангелы,духовность,саморазвитие",
    "de-DE": "manifestieren,methode,gesetz,anziehung,engelszahlen,affirmationen,tagebuch,dankbarkeitstagebuch",
    "nl-NL": "manifesteren,methode,wet,aantrekking,engelengetallen,dagboek,dankbaarheidsdagboek,visiebord",
    "es-ES": "manifestacion,manifestar,metodo,ia,afirmaciones,positivas,atraccion,numeros,angelicos,numerologia",
    "es-MX": "manifestacion,manifestar,metodo,ia,afirmaciones,positivas,diarias,numeros,angelicos,numerologia",
    "pt-BR": "manifestacao,manifestar,gratidao,diario,atracao,diarias,anjos,numeros,quadro,numerologia,metodo",
}

# New locales cloned from proven siblings (created if the API allows them for this app)
NEW_LOCALES = {
    "pt-PT": {  # clone of pt-BR, Portugal spellings
        "keywords": "manifestacao,manifestar,gratidao,diario,atracao,anjos,numeros,quadro,numerologia,metodo",
        "description_from": "pt-BR", "whatsNew": "Melhorias de estabilidade e correção de erros.",
    },
    "zh-Hant": {  # Traditional Chinese for HK/TW; terms from zh-Hans map + local forms
        "keywords": "顯化,吸引力法則,天使數字,感恩日記,願景板,肯定語,冥想,潛意識,數字命理,369",
        "description_from": "zh-Hans", "whatsNew": "穩定性改進和錯誤修復。",
    },
}

WHATS_NEW_DEFAULT = "Stability improvements and bug fixes."


def validate():
    bad = False
    for loc, kw in {**KEYWORDS, **{k: v["keywords"] for k, v in NEW_LOCALES.items()}}.items():
        if len(kw) > 100:
            print(f"  !! {loc} keywords too long: {len(kw)}")
            bad = True
        else:
            print(f"  ok {loc:8} keywords {len(kw):3}/100")
    for loc, st in SUBTITLES.items():
        if len(st) > 30:
            print(f"  !! {loc} subtitle too long: {len(st)}")
            bad = True
        else:
            print(f"  ok {loc:8} subtitle {len(st):2}/30  {st!r}")
    if bad:
        sys.exit("length validation failed")


def get_or_create_version():
    code, d = req("GET", f"/v1/apps/{APP_ID}/appStoreVersions?limit=5"
                         "&fields[appStoreVersions]=versionString,appStoreState")
    for v in d["data"]:
        if v["attributes"]["versionString"] == NEW_VERSION:
            print(f"version {NEW_VERSION} exists ({v['attributes']['appStoreState']})")
            return v["id"]
        if v["attributes"]["appStoreState"] in ("PREPARE_FOR_SUBMISSION", "DEVELOPER_REJECTED"):
            vid = v["id"]
            print(f"renaming draft {v['attributes']['versionString']} -> {NEW_VERSION}")
            req("PATCH", f"/v1/appStoreVersions/{vid}",
                {"data": {"type": "appStoreVersions", "id": vid,
                          "attributes": {"versionString": NEW_VERSION}}})
            return vid
    code, d = req("POST", "/v1/appStoreVersions",
                  {"data": {"type": "appStoreVersions",
                            "attributes": {"platform": "IOS", "versionString": NEW_VERSION,
                                           "releaseType": "AFTER_APPROVAL"},
                            "relationships": {"app": {"data": {"type": "apps", "id": APP_ID}}}}})
    if code >= 400:
        sys.exit(f"version create failed: {code} {d['errors'][0].get('detail')}")
    print(f"created draft version {NEW_VERSION}")
    return d["data"]["id"]


def patch_keywords(vid):
    code, d = req("GET", f"/v1/appStoreVersions/{vid}/appStoreVersionLocalizations"
                         "?limit=50&fields[appStoreVersionLocalizations]=locale")
    have = {l["attributes"]["locale"]: l["id"] for l in d["data"]}
    ok = 0
    for loc, kw in KEYWORDS.items():
        if loc not in have:
            print(f"  -- {loc} localization missing on draft, skipped")
            continue
        c, r = req("PATCH", f"/v1/appStoreVersionLocalizations/{have[loc]}",
                   {"data": {"type": "appStoreVersionLocalizations", "id": have[loc],
                             "attributes": {"keywords": kw, "whatsNew": WHATS_NEW_DEFAULT}}})
        print(("  ok " if c < 400 else "  !! ") + loc)
        ok += c < 400
    for loc, spec in NEW_LOCALES.items():
        if loc in have:
            print(f"  -- {loc} already exists"); continue
        c, r = req("POST", "/v1/appStoreVersionLocalizations",
                   {"data": {"type": "appStoreVersionLocalizations",
                             "attributes": {"locale": loc, "keywords": spec["keywords"],
                                            "whatsNew": spec["whatsNew"]},
                             "relationships": {"appStoreVersion":
                                 {"data": {"type": "appStoreVersions", "id": vid}}}}})
        if c < 400:
            print(f"  ok {loc} CREATED")
        else:
            print(f"  !! {loc} create failed: {r['errors'][0].get('detail', '')[:100]}")
    print(f"keywords patched: {ok}/{len(KEYWORDS)}")


def patch_subtitles():
    code, d = req("GET", f"/v1/apps/{APP_ID}/appInfos")
    target = None
    for ai in d["data"]:
        c, l = req("GET", f"/v1/appInfos/{ai['id']}?fields[appInfos]=appStoreState")
        st = l["data"]["attributes"].get("appStoreState")
        if st in ("PREPARE_FOR_SUBMISSION", "DEVELOPER_REJECTED"):
            target = ai["id"]
    if not target:
        print("NO editable appInfo yet — run again after the 2.0 draft exists; subtitles unchanged")
        return
    c, l = req("GET", f"/v1/appInfos/{target}/appInfoLocalizations"
                      "?limit=50&fields[appInfoLocalizations]=locale,subtitle")
    for loc_obj in l["data"]:
        loc, lid = loc_obj["attributes"]["locale"], loc_obj["id"]
        if loc not in SUBTITLES:
            continue
        if loc_obj["attributes"].get("subtitle") == SUBTITLES[loc]:
            print(f"  ok {loc} subtitle already set"); continue
        c2, r2 = req("PATCH", f"/v1/appInfoLocalizations/{lid}",
                     {"data": {"type": "appInfoLocalizations", "id": lid,
                               "attributes": {"subtitle": SUBTITLES[loc]}}})
        print(("  ok " if c2 < 400 else "  !! ") + f"{loc} -> {SUBTITLES[loc]!r}")


if __name__ == "__main__":
    print("— validation —")
    validate()
    if "--dry-run" in sys.argv:
        print("\n(dry run: no API calls)")
        sys.exit(0)
    print("\n— version —")
    vid = get_or_create_version()
    print("\n— keywords —")
    patch_keywords(vid)
    print("\n— subtitles —")
    patch_subtitles()
    print("\nDone. Review in App Store Connect, then upload build 15 and attach.")
