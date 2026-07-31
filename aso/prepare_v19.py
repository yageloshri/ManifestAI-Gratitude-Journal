#!/usr/bin/env python3
"""Prep App Store version 1.9 (metadata release):
1. Creates draft version 1.9 (or reuses it if it already exists)
2. Sets whatsNew in all 25 locales
3. Applies the 2026-07-31 cloud ASO recommendations:
   - keyword fields for en-US/GB/AU/CA, de-DE, fr-FR, it, nl-NL, pl, tr
   - subtitle en-US: "Gratitude & Angel Numbers" (exact-phrase play, pop 14 / diff 15)
   - subtitle de-DE: "Dankbarkeitstagebuch & Engel" (DE regression fix)
Run:  python3 aso/prepare_v19.py
"""
import sys
import time

from asc_client import req, APP_ID

WHATS_NEW = {
    "en-US": "Stability improvements and bug fixes.",
    "en-GB": "Stability improvements and bug fixes.",
    "en-CA": "Stability improvements and bug fixes.",
    "en-AU": "Stability improvements and bug fixes.",
    "de-DE": "Stabilitätsverbesserungen und Fehlerbehebungen.",
    "fr-FR": "Améliorations de stabilité et corrections de bugs.",
    "es-ES": "Mejoras de estabilidad y corrección de errores.",
    "es-MX": "Mejoras de estabilidad y corrección de errores.",
    "pt-BR": "Melhorias de estabilidade e correções de bugs.",
    "it": "Miglioramenti di stabilità e correzioni di bug.",
    "nl-NL": "Stabiliteitsverbeteringen en bugfixes.",
    "sv": "Stabilitetsförbättringar och buggfixar.",
    "no": "Stabilitetsforbedringer og feilrettinger.",
    "da": "Stabilitetsforbedringer og fejlrettelser.",
    "fi": "Vakausparannuksia ja virheenkorjauksia.",
    "pl": "Poprawki stabilności i błędów.",
    "ru": "Улучшения стабильности и исправления ошибок.",
    "tr": "Kararlılık iyileştirmeleri ve hata düzeltmeleri.",
    "ar-SA": "تحسينات في الاستقرار وإصلاح الأخطاء.",
    "he": "שיפורי יציבות ותיקוני באגים.",
    "id": "Peningkatan stabilitas dan perbaikan bug.",
    "vi": "Cải thiện độ ổn định và sửa lỗi.",
    "ja": "安定性の向上とバグ修正。",
    "ko": "안정성 개선 및 버그 수정.",
    "zh-Hans": "稳定性改进和错误修复。",
}

# 2026-07-31 cloud scan recommendations (aso/reports/2026-07-31-cloud.md).
# en-US: angel/numbers/555's job moves to the subtitle; journal restores the
# gratitude-journal combo the old subtitle carried; keeps every producing token.
KEYWORDS = {
    "en-US": "manifestation,affirmations,law,attraction,method,scripting,daily,jar,journal,555,abundance,dream",
    "en-GB": "manifestation,affirmations,angel,numbers,law,attraction,method,scripting,daily,jar,abundance,dream",
    "en-AU": "manifestation,affirmations,angel,numbers,law,attraction,method,scripting,daily,jar,abundance,dream",
    "en-CA": "manifestation,affirmations,angel,numbers,law,attraction,method,scripting,daily,jar,abundance,dream",
    "de-DE": "manifestieren,gesetz,anziehung,engelszahlen,affirmationen,tagebuch,dankbarkeitstagebuch,wünsche",
    "fr-FR": "manifestation,affirmations,positives,loi,attraction,nombres,angeliques,methode,journal,tableau",
    "it": "manifestazione,legge,attrazione,numeri,angelici,affermazioni,positive,metodo,diario,risveglio",
    "nl-NL": "manifesteren,manifestatie,wet,aantrekking,engelengetallen,dagboek,dankbaarheidsdagboek,visiebord",
    "pl": "manifestacja,prawo,przyciagania,anielskie,liczby,afirmacje,tablica,wizji,dziennik,przebudzenie",
    "tr": "tezahür,çekim,yasası,melek,sayıları,olumlamalar,vizyon,panosu,şükür,günlüğü,ruhsal,bolluk,niyet",
}

SUBTITLES = {
    "en-US": "Gratitude & Angel Numbers",
    "de-DE": "Dankbarkeitstagebuch & Engel",
}


def get_or_create_version():
    code, d = req("GET", f"/v1/apps/{APP_ID}/appStoreVersions?limit=5"
                         "&fields[appStoreVersions]=versionString,appStoreState")
    for v in d["data"]:
        if v["attributes"]["versionString"] == "1.9":
            print("version 1.9 already exists:", v["id"],
                  v["attributes"]["appStoreState"])
            return v["id"]
    code, d = req("POST", "/v1/appStoreVersions",
                  {"data": {"type": "appStoreVersions",
                            "attributes": {"versionString": "1.9",
                                           "platform": "IOS",
                                           "releaseType": "AFTER_APPROVAL"},
                            "relationships": {"app": {"data": {"type": "apps",
                                                               "id": APP_ID}}}}})
    if code >= 400:
        sys.exit(f"create 1.9 failed: {code} {d['errors'][0].get('detail')}")
    vid = d["data"]["id"]
    print("created draft version 1.9:", vid)
    return vid


def patch_version_localizations(vid):
    # locales are copied from the previous version; give ASC a moment on a
    # freshly created version
    for attempt in range(6):
        code, d = req("GET", f"/v1/appStoreVersions/{vid}/appStoreVersionLocalizations"
                             "?limit=50&fields[appStoreVersionLocalizations]=locale")
        if len(d.get("data", [])) >= 25:
            break
        time.sleep(5)
    ok = fail = 0
    for loc_obj in d["data"]:
        loc, lid = loc_obj["attributes"]["locale"], loc_obj["id"]
        attrs = {"whatsNew": WHATS_NEW.get(loc, WHATS_NEW["en-US"])}
        if loc in KEYWORDS:
            attrs["keywords"] = KEYWORDS[loc]
        c, r = req("PATCH", f"/v1/appStoreVersionLocalizations/{lid}",
                   {"data": {"type": "appStoreVersionLocalizations", "id": lid,
                             "attributes": attrs}})
        if c < 400:
            ok += 1
        else:
            fail += 1
            print("FAIL", loc, c, r.get("errors", [{}])[0].get("detail", "")[:120])
    print(f"version localizations: {ok} ok, {fail} failed")


def patch_subtitles():
    code, d = req("GET", f"/v1/apps/{APP_ID}/appInfos?limit=5"
                         "&fields[appInfos]=appStoreState")
    editable = [i["id"] for i in d["data"]
                if i["attributes"].get("appStoreState") not in ("READY_FOR_SALE",)]
    if not editable:
        print("NO editable appInfo found — subtitles not changed")
        return
    for iid in editable:
        code, d = req("GET", f"/v1/appInfos/{iid}/appInfoLocalizations?limit=50"
                             "&fields[appInfoLocalizations]=locale,subtitle")
        for l in d.get("data", []):
            loc = l["attributes"]["locale"]
            if loc not in SUBTITLES:
                continue
            if l["attributes"].get("subtitle") == SUBTITLES[loc]:
                print(f"subtitle {loc} already set")
                continue
            c, r = req("PATCH", f"/v1/appInfoLocalizations/{l['id']}",
                       {"data": {"type": "appInfoLocalizations", "id": l["id"],
                                 "attributes": {"subtitle": SUBTITLES[loc]}}})
            if c < 400:
                print(f"subtitle {loc} -> {SUBTITLES[loc]!r}")
            else:
                print("FAIL subtitle", loc, c,
                      r.get("errors", [{}])[0].get("detail", "")[:120])


if __name__ == "__main__":
    for loc, kw in KEYWORDS.items():
        assert len(kw) <= 100, f"{loc} keywords {len(kw)} chars"
    for loc, st in SUBTITLES.items():
        assert len(st) <= 30, f"{loc} subtitle {len(st)} chars"
    vid = get_or_create_version()
    patch_version_localizations(vid)
    patch_subtitles()
    print("done. next: zsh build/upload_v19.sh, then python3 aso/ship_v19.py")
