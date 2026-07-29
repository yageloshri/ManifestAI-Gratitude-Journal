#!/usr/bin/env python3
"""One-shot prep for App Store version 1.7 submission:
sets whatsNew in all 25 locales + upgrades en-US keywords.
Run:  python3 aso/prepare_v17.py
"""
from asc_client import req

VID = "97b7562b-593e-42fb-af93-223001450dca"  # v1.7 PREPARE_FOR_SUBMISSION

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

# Swap low-value "subconscious" for trending niche terms (tesla/lucky/555); 99 chars.
NEW_US_KEYWORDS = "manifestation,affirmations,angel,numbers,law,attraction,method,scripting,daily,jar,tesla,lucky,555"


def main():
    code, d = req("GET", f"/v1/appStoreVersions/{VID}/appStoreVersionLocalizations"
                         "?limit=50&fields[appStoreVersionLocalizations]=locale")
    ok = fail = 0
    for loc_obj in d["data"]:
        loc, lid = loc_obj["attributes"]["locale"], loc_obj["id"]
        attrs = {"whatsNew": WHATS_NEW.get(loc, WHATS_NEW["en-US"])}
        if loc == "en-US":
            attrs["keywords"] = NEW_US_KEYWORDS
        c, r = req("PATCH", f"/v1/appStoreVersionLocalizations/{lid}",
                   {"data": {"type": "appStoreVersionLocalizations", "id": lid,
                             "attributes": attrs}})
        if c < 400:
            ok += 1
        else:
            fail += 1
            print("FAIL", loc, c, r.get("errors", [{}])[0].get("detail", "")[:100])
    print(f"done: {ok} locales updated, {fail} failed")
    assert len(NEW_US_KEYWORDS) <= 100


if __name__ == "__main__":
    main()
