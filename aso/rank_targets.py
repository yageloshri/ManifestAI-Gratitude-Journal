#!/usr/bin/env python3
"""Rank-check each country's top harvested targets (from aso/targets/<cc>.json).

Takes the top N RELEVANT terms per country (by hint position), checks our
current rank via the public iTunes Search API (throttle 3.2s), and writes
aso/targets/ranks.json. Also enriches with Astro popularity where available.

Usage: python3 aso/rank_targets.py [N]   (default N=10)
"""
import json, os, sys, time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rank_tracker import itunes_rank, astro_scores, THROTTLE_SECONDS
from hints_harvester import STOREFRONT_ID

HERE = os.path.dirname(os.path.abspath(__file__))
TARGETS = os.path.join(HERE, "targets")
OUT = os.path.join(TARGETS, "ranks.json")

TOP_N = int(sys.argv[1]) if len(sys.argv) > 1 else 10


def main():
    astro = astro_scores()
    results = {}
    countries = [c for c in STOREFRONT_ID
                 if os.path.exists(os.path.join(TARGETS, f"{c}.json"))]
    total = 0
    plans = {}
    for c in countries:
        data = json.load(open(os.path.join(TARGETS, f"{c}.json"), encoding="utf-8"))
        top = [t for t in data["terms"] if t["relevant"]][:TOP_N]
        plans[c] = top
        total += len(top)
    done = 0
    for c, top in plans.items():
        rows = []
        for t in top:
            rank, pool = itunes_rank(t["term"], c)
            meta = astro.get((c, t["term"].lower()), {})
            rows.append({"term": t["term"], "seed": t["seed"],
                         "position": t["position"], "rank": rank,
                         "results": pool,
                         "popularity": meta.get("popularity"),
                         "difficulty": meta.get("difficulty")})
            done += 1
            mark = f"#{rank}" if isinstance(rank, int) else ("—" if rank is None else "ERR")
            print(f"[{done}/{total}] {c} '{t['term']}': {mark}", flush=True)
            time.sleep(THROTTLE_SECONDS)
        results[c] = rows
        # checkpoint after each country
        json.dump({"checked_at": time.strftime("%Y-%m-%dT%H:%M%z"),
                   "top_n": TOP_N, "countries": results},
                  open(OUT, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print("done ->", OUT, flush=True)


if __name__ == "__main__":
    main()
