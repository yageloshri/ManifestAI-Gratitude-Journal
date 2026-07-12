#!/usr/bin/env python3
"""Harvest per-country highest-popularity niche terms via Apple Search Hints.

For each of the 25 storefronts, probes localized niche seed prefixes
(manifestation / vision board / gratitude / 369 / angel numbers /
affirmations / law of attraction roots) and aggregates ordered suggestions
into aso/targets/<country>.json. Position within a seed's suggestion list is
the local-popularity proxy (1 = most popular completion for that prefix).

Relevance is pre-marked with per-country niche root vocab + a manual
blocklist (game names / unrelated brands), then reviewed by hand.

Usage: python3 aso/harvest_targets.py [country ...]
"""
import json, os, sys, time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from hints_harvester import fetch_hints, STOREFRONT_ID, THROTTLE_SECONDS

HERE = os.path.dirname(os.path.abspath(__file__))
OUT_DIR = os.path.join(HERE, "targets")

SEEDS = {
    "us": ["manif", "vision", "gratit", "369", "angel nu", "affirm", "law of at"],
    "gb": ["manif", "vision", "gratit", "369", "angel nu", "affirm", "law of at"],
    "au": ["manif", "vision", "gratit", "369", "angel nu", "affirm", "law of at"],
    "ca": ["manif", "vision", "gratit", "369", "angel nu", "affirm", "law of at"],
    "il": ["מניפ", "לוח חז", "הכרת תו", "369", "מספרי מל", "אפירמצ", "חוק המש", "תודה"],
    "de": ["manif", "vision", "dankbar", "369", "engelszah", "affirm", "gesetz der"],
    "fr": ["manif", "tableau de v", "gratitude", "369", "nombres ang", "affirm", "loi de l"],
    "it": ["manifest", "vision", "gratitud", "369", "numeri ang", "affermaz", "legge d"],
    "es": ["manifes", "tablero de v", "gratitud", "369", "numeros ang", "afirmac", "ley de"],
    "mx": ["manifes", "tablero de v", "gratitud", "369", "numeros ang", "afirmac", "ley de"],
    "br": ["manifest", "quadro de", "gratid", "369", "anjo", "afirmac", "lei da atra"],
    "nl": ["manifest", "vision", "dankbaar", "369", "engelenget", "affirmat", "wet van"],
    "pl": ["manifest", "tablica w", "wdzięcz", "369", "liczby ani", "afirmac", "prawo przy"],
    "tr": ["manifest", "vizyon", "şükür", "369", "melek say", "olumlama", "çekim yas"],
    "ru": ["манифест", "доска в", "благодарн", "369", "ангельск", "аффирмац", "закон при"],
    "se": ["manifest", "vision", "tacksam", "369", "änglanum", "affirmation", "lagen om"],
    "no": ["manifest", "visjon", "takknem", "369", "englenum", "bekreftels", "tiltrekning"],
    "dk": ["manifest", "vision", "taknem", "369", "englenum", "bekræftels", "tiltrækning"],
    "fi": ["manifest", "visio", "kiitollisuus", "369", "enkelinum", "affirmaat", "vetovoima"],
    "jp": ["引き寄せ", "ビジョンボ", "感謝", "369", "エンジェルナ", "アファ", "潜在意識"],
    "kr": ["끌어당", "비전보", "감사일", "369", "엔젤넘", "확언", "시크릿"],
    "cn": ["显化", "愿景", "感恩", "369", "天使数", "肯定", "吸引力"],
    "sa": ["قانون الج", "لوحة ال", "امتنان", "369", "ارقام المل", "توكيد", "تجلي"],
    "id": ["manifest", "vision", "syukur", "369", "malaikat", "afirmas", "hukum tar"],
    "vn": ["luật hấp", "bảng tầm", "biết ơn", "369", "số thiên th", "khẳng định", "manifest"],
}

# niche root substrings per country (lowercased) — term relevant if any matches
ROOTS = {
    "_common": ["369", "3-6-9", "manifest", "vision board", "law of attraction",
                "affirmation", "gratitude", "angel number", "subconscious",
                "lucky girl", "scripting"],
    "il": ["מניפסטציה", "לוח חזון", "הכרת תודה", "יומן תודה", "תודה", "אפירמצ",
           "מספרי מלאכים", "חוק המשיכה", "משיכה", "הגשמה"],
    "de": ["manifestier", "dankbar", "engelszahl", "gesetz der anziehung",
           "anziehung", "affirmation", "visionboard", "vision board", "unterbewusst"],
    "fr": ["manifestation", "tableau de visualisation", "tableau de vision",
           "gratitude", "nombres angeliques", "nombre angelique",
           "loi de l'attraction", "loi d'attraction", "affirmation",
           "subconscient"],
    "it": ["manifestazione", "manifestare", "gratitudine", "numeri angelici",
           "affermazioni", "legge dell'attrazione", "legge di attrazione"],
    "es": ["manifestar", "manifestacion", "tablero de vision", "gratitud",
           "numeros angelic", "numero angelic", "angelicos", "afirmac",
           "ley de atraccion", "ley de la atraccion", "subconsciente"],
    "br": ["manifestacao", "manifestar", "quadro de visualiza", "quadro dos sonhos",
           "quadro de visao", "gratidao", "numero de anjo", "numeros dos anjos",
           "anjo numero", "afirmac", "lei da atracao", "subconsciente"],
    "nl": ["manifesteren", "manifestatie", "dankbaar", "engelengetal",
           "affirmatie", "wet van aantrekking", "onderbewust"],
    "pl": ["manifestacja", "manifestowanie", "tablica wizji", "wdzięczno",
           "liczby aniel", "anielskie", "afirmacj", "prawo przyciągania",
           "podświadomo"],
    "tr": ["manifest", "vizyon panosu", "şükür", "sukur", "melek say",
           "olumlama", "çekim yasası", "cekim yasasi", "bilinçaltı",
           "mucize teknik", "tezahür", "tezahur"],
    "ru": ["манифест", "доска визуализации", "доска желаний", "благодарност",
           "ангельск", "аффирмаци", "закон притяжения", "закон привлечения",
           "подсознани", "визуализ"],
    "se": ["manifestera", "manifestation", "visionstavla", "tacksamhet",
           "änglanummer", "affirmation", "lagen om attraktion"],
    "no": ["manifestere", "manifestering", "visjonstavle", "takknemlighet",
           "englenumre", "englenummer", "bekreftelser", "tiltrekningsloven"],
    "dk": ["manifestere", "manifestering", "visionstavle", "taknemmelighed",
           "englenumre", "englenummer", "bekræftelser", "tiltrækningsloven"],
    "fi": ["manifestointi", "manifestoi", "visiotaulu", "kiitollisuus",
           "enkelinumero", "affirmaatio", "vetovoiman laki"],
    "jp": ["引き寄せ", "ビジョンボード", "感謝", "エンジェルナンバー",
           "アファメーション", "潜在意識", "願望実現", "感謝日記"],
    "kr": ["끌어당김", "비전보드", "감사일기", "감사", "엔젤넘버", "확언",
           "잠재의식", "드림보드"],
    "cn": ["显化", "愿景板", "感恩", "天使数字", "肯定语", "吸引力法则", "潜意识"],
    "sa": ["قانون الجذب", "الجذب", "لوحة الرؤية", "امتنان", "الامتنان",
           "ارقام الملائكة", "أرقام الملائكة", "توكيد", "تجلي", "العقل الباطن"],
    "id": ["manifestasi", "manifesting", "vision board", "papan visi", "syukur",
           "malaikat", "angka malaikat", "afirmasi", "hukum tarik", "alam bawah sadar"],
    "vn": ["luật hấp dẫn", "bảng tầm nhìn", "biết ơn", "số thiên thần",
           "khẳng định", "hiển hóa", "tiềm thức", "manifest"],
}

# hand-reviewed irrelevant hits (games, unrelated brands) — substring match,
# checked on the accent/apostrophe-normalized lowercase term
BLOCKLIST = ["manifold", "manif emu", "מניפיק", "visionary", "vision pro",
             "vision test", "vision insurance", "369床", "369 chinese",
             "gratitude turkey trot",
             # reviewed 2026-07-12: transit/games/utility brands riding niche prefixes
             "369出行", "证件照", "369 grand", "369sonic", "avoid 369",
             "breathez 369", "conga", "life 360", "life360",
             "ley de ohm", "legge di ohm", "lei de ohm", "loi d'ohm",
             "manifesto", "manifiesto", "369 spiele", "369 games",
             "manifestival", "oyunu", "ангельская мова", "insta 360",
             "quadro de fotos", "quadro de desenho", "quadro de escrever",
             "quadro de futsal", "anjos da guarda", "della pizza",
             "anjos telecom", "pet anjo", "filmes gratis",
             "369借条", "시크릿오더", "시크릿쥬쥬", "시크릿산타", "시크릿카메라",
             "دار امتنان", "تجليخ", "لوحة المفاتيح", "369 cinemas", "369 reels",
             "369 wallet", "tv 369", "puji syukur", "visjon norge"]

# hand-review overrides applied after heuristics: term.lower() -> bool
OVERRIDES_PATH = os.path.join(OUT_DIR, "relevance_overrides.json")

# es-MX shares the Spanish root vocab
ROOTS["mx"] = ROOTS["es"]


def _norm(s):
    """lowercase + straighten apostrophes + strip accents (for matching only)."""
    import unicodedata
    s = s.lower().replace("’", "'").replace("ʼ", "'")
    return "".join(c for c in unicodedata.normalize("NFKD", s)
                   if not unicodedata.combining(c))


def is_relevant(country, term):
    t = _norm(term)
    for b in BLOCKLIST:
        if _norm(b) in t:
            return False
    for root in ROOTS["_common"] + ROOTS.get(country, []):
        if _norm(root) in t:
            return True
    return False


def harvest(country):
    rows, seen = [], {}
    for seed in SEEDS[country]:
        hints = fetch_hints(country, seed)
        time.sleep(THROTTLE_SECONDS)
        if hints is None:
            rows.append({"seed": seed, "error": True})
            continue
        for pos, term in enumerate(hints, 1):
            key = term.lower()
            if key in seen:                    # keep best (lowest) position
                if pos < seen[key]["position"]:
                    seen[key]["position"] = pos
                    seen[key]["seed"] = seed
                continue
            entry = {"term": term, "seed": seed, "position": pos,
                     "relevant": is_relevant(country, term)}
            seen[key] = entry
            rows.append(entry)
    terms = sorted([r for r in rows if "term" in r],
                   key=lambda r: (r["position"], not r["relevant"]))
    errors = [r["seed"] for r in rows if r.get("error")]
    return terms, errors


def apply_overrides(terms):
    if os.path.exists(OVERRIDES_PATH):
        ov = json.load(open(OVERRIDES_PATH, encoding="utf-8"))
        for t in terms:
            if t["term"].lower() in ov:
                t["relevant"] = ov[t["term"].lower()]
    return terms


def main(countries):
    os.makedirs(OUT_DIR, exist_ok=True)
    for country in countries:
        print(f"=== {country} (storefront {STOREFRONT_ID[country]}) ===", flush=True)
        terms, errors = harvest(country)
        apply_overrides(terms)
        out = {"country": country, "storefront_id": STOREFRONT_ID[country],
               "harvested_at": time.strftime("%Y-%m-%dT%H:%M%z"),
               "seed_errors": errors, "terms": terms}
        path = os.path.join(OUT_DIR, f"{country}.json")
        json.dump(out, open(path, "w", encoding="utf-8"),
                  ensure_ascii=False, indent=1)
        rel = sum(1 for t in terms if t["relevant"])
        print(f"    {len(terms)} terms ({rel} relevant), errors={errors}", flush=True)


def remark(countries):
    """Recompute relevance flags on existing target files (no fetching)."""
    for country in countries:
        path = os.path.join(OUT_DIR, f"{country}.json")
        if not os.path.exists(path):
            continue
        data = json.load(open(path, encoding="utf-8"))
        for t in data["terms"]:
            t["relevant"] = is_relevant(country, t["term"])
        apply_overrides(data["terms"])
        data["terms"].sort(key=lambda r: (r["position"], not r["relevant"]))
        json.dump(data, open(path, "w", encoding="utf-8"),
                  ensure_ascii=False, indent=1)
        rel = sum(1 for t in data["terms"] if t["relevant"])
        print(f"{country}: {len(data['terms'])} terms, {rel} relevant")


if __name__ == "__main__":
    args = sys.argv[1:]
    if args and args[0] == "--remark":
        remark(args[1:] or list(SEEDS))
    else:
        main(args or list(SEEDS))
