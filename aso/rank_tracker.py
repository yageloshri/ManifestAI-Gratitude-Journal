#!/usr/bin/env python3
"""App Store keyword rank tracker for Manifest: Vision Board & 369.

For every ASC locale, splits the live keyword field (plus per-locale bonus
keywords from bonus_keywords.json) and asks the public iTunes Search API for
each term in that locale's storefront, recording where app 6757018484 ranks.
Results append to aso/rankings/history.jsonl (one JSON line per snapshot) and
the latest snapshot is written to aso/rankings/latest.json.

Astro enrichment: if the local Astro ASO app database is present, popularity/
difficulty scores are attached to matching (store, keyword) pairs.

Usage:
  python3 aso/rank_tracker.py            # full scan (all locales)
  python3 aso/rank_tracker.py us il de   # only these storefronts
  python3 aso/rank_tracker.py --report   # print movers vs previous snapshot
"""
import json, os, sys, time, sqlite3, datetime, urllib.request, urllib.parse

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from asc_client import get_version_localizations, APP_ID

HERE = os.path.dirname(os.path.abspath(__file__))
RANK_DIR = os.path.join(HERE, "rankings")
HISTORY = os.path.join(RANK_DIR, "history.jsonl")
LATEST = os.path.join(RANK_DIR, "latest.json")
BONUS = os.path.join(HERE, "bonus_keywords.json")

# ASC locale -> App Store storefront country code
STOREFRONT = {
    "en-US": "us", "en-GB": "gb", "en-AU": "au", "en-CA": "ca",
    "he": "il", "de-DE": "de", "fr-FR": "fr", "it": "it",
    "es-ES": "es", "es-MX": "mx", "pt-BR": "br", "nl-NL": "nl",
    "pl": "pl", "tr": "tr", "ru": "ru", "sv": "se", "no": "no",
    "da": "dk", "fi": "fi", "ja": "jp", "ko": "kr", "zh-Hans": "cn",
    "ar-SA": "sa", "id": "id", "vi": "vn",
}

SEARCH_LIMIT = 200          # max results the API returns per query
THROTTLE_SECONDS = 3.2      # stay under ~20 req/min


def itunes_rank(term, country):
    """Return (rank, total_results) of our app for term in country; rank None if unranked."""
    q = urllib.parse.urlencode({"term": term, "country": country,
                                "entity": "software", "limit": SEARCH_LIMIT})
    url = f"https://itunes.apple.com/search?{q}"
    for attempt in range(3):
        try:
            with urllib.request.urlopen(url, timeout=20) as r:
                data = json.load(r)
            results = data.get("results", [])
            for i, app in enumerate(results, start=1):
                if str(app.get("trackId")) == APP_ID:
                    return i, len(results)
            return None, len(results)
        except Exception:
            time.sleep(8 * (attempt + 1))
    return "error", 0


def astro_scores():
    """(store, keyword) -> {popularity, difficulty} from the local Astro app DB."""
    import glob
    paths = glob.glob(os.path.expanduser(
        "~/Library/Containers/matteospada.it.ASO/Data/Library/Application Support/Astro/Model.sqlite"))
    if not paths:
        return {}
    out = {}
    try:
        db = sqlite3.connect(f"file:{paths[0]}?mode=ro", uri=True)
        for store, text, pop, diff in db.execute(
                "SELECT ZSTORE, ZTEXT, ZPOPULARITY, ZDIFFICULTY FROM ZKEYWORD"):
            if text:
                out[((store or "us").lower(), text.strip().lower())] = {
                    "popularity": pop, "difficulty": diff}
        db.close()
    except Exception:
        pass
    return out


def load_bonus():
    if os.path.exists(BONUS):
        return json.load(open(BONUS, encoding="utf-8"))
    return {}


def keyword_plan():
    """locale -> ordered unique keyword list (ASC field terms + bonus terms)."""
    locs = get_version_localizations()
    bonus = load_bonus()
    plan = {}
    for locale, info in sorted(locs.items()):
        if locale not in STOREFRONT:
            continue
        terms = [t.strip() for t in info["keywords"].split(",") if t.strip()]
        for extra in bonus.get(locale, []):
            if extra not in terms:
                terms.append(extra)
        plan[locale] = terms
    return plan


def scan(only_countries=None):
    os.makedirs(RANK_DIR, exist_ok=True)
    plan = keyword_plan()
    astro = astro_scores()
    stamp = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%MZ")
    rows = []
    total = sum(len(v) for k, v in plan.items()
                if not only_countries or STOREFRONT[k] in only_countries)
    done = 0
    for locale, terms in plan.items():
        country = STOREFRONT[locale]
        if only_countries and country not in only_countries:
            continue
        for term in terms:
            rank, pool = itunes_rank(term, country)
            meta = astro.get((country, term.lower()), {})
            rows.append({"locale": locale, "country": country, "keyword": term,
                         "rank": rank, "results": pool,
                         "popularity": meta.get("popularity"),
                         "difficulty": meta.get("difficulty")})
            done += 1
            mark = f"#{rank}" if isinstance(rank, int) else ("—" if rank is None else "ERR")
            print(f"[{done}/{total}] {country} '{term}': {mark}", flush=True)
            time.sleep(THROTTLE_SECONDS)
    snapshot = {"date": stamp, "app_id": APP_ID, "rows": rows}
    with open(HISTORY, "a", encoding="utf-8") as f:
        f.write(json.dumps(snapshot, ensure_ascii=False) + "\n")
    json.dump(snapshot, open(LATEST, "w", encoding="utf-8"),
              ensure_ascii=False, indent=1)
    report(snapshot)


def previous_snapshot():
    if not os.path.exists(HISTORY):
        return None
    lines = open(HISTORY, encoding="utf-8").read().strip().splitlines()
    return json.loads(lines[-2]) if len(lines) >= 2 else None


def report(snapshot=None):
    if snapshot is None:
        snapshot = json.load(open(LATEST, encoding="utf-8"))
    prev = previous_snapshot()
    prev_map = {}
    if prev:
        prev_map = {(r["country"], r["keyword"]): r["rank"] for r in prev["rows"]}
    ranked = [r for r in snapshot["rows"] if isinstance(r["rank"], int)]
    unranked = [r for r in snapshot["rows"] if r["rank"] is None]
    print(f"\n=== Snapshot {snapshot['date']} — ranked for "
          f"{len(ranked)}/{len(snapshot['rows'])} keyword×storefront pairs ===")
    for r in sorted(ranked, key=lambda x: x["rank"]):
        old = prev_map.get((r["country"], r["keyword"]))
        delta = ""
        if isinstance(old, int) and old != r["rank"]:
            delta = f"  ({'+' if old > r['rank'] else ''}{old - r['rank']} vs prev)"
        pop = f" pop={r['popularity']}" if r.get("popularity") else ""
        print(f"  #{r['rank']:>3}  [{r['country']}] {r['keyword']}{pop}{delta}")
    top_unranked = sorted([u for u in unranked if u.get("popularity")],
                          key=lambda x: -(x["popularity"] or 0))[:15]
    if top_unranked:
        print("\n  Unranked high-popularity targets (top 15):")
        for u in top_unranked:
            print(f"   —   [{u['country']}] {u['keyword']} pop={u['popularity']} diff={u.get('difficulty')}")


if __name__ == "__main__":
    args = [a for a in sys.argv[1:]]
    if "--report" in args:
        report()
    else:
        scan(only_countries=[a for a in args if len(a) == 2] or None)
