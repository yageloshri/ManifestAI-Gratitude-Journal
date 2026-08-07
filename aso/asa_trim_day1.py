#!/usr/bin/env python3
"""Day-1 trim of the Discovery campaign (Yagel-approved 2026-08-07).

Day 1 delivered 657 impressions / 9 taps / 0 installs / $15.35. The internal
spread is the finding: `gratitude journal` pulled 6.12% TTR while the Search
Match ad group pulled 0.84% across 359 impressions — same app, same creative,
same day, so the difference is query relevance, not the ad.

Actions: pause the Search Match ad group and the three keywords that proved dead,
halve the daily budget, and concentrate what's left on the terms showing life.

No pip deps (openssl + urllib) — same reason as asa_guard.py.
"""
import json
import sys

sys.path.insert(0, __import__("os").path.dirname(__file__))
from asa_guard import call, CAMPAIGN  # noqa: E402

SEARCH_MATCH_AG = 2150185027
BROAD_AG = 2150183350
KILL = {"gratitude app", "gratitude jar", "manifestation app"}
NEW_DAILY = "10"


def main():
    # 1. Search Match: half the impressions, worst TTR, and Apple withholds the
    #    search terms at this volume — so we cannot even mine it for negatives.
    # Ad groups take the object flat (no wrapper) and require name+startTime echoed back.
    ag = (call("GET", f"/campaigns/{CAMPAIGN}/adgroups/{SEARCH_MATCH_AG}") or {}).get("data") or {}
    r = call("PUT", f"/campaigns/{CAMPAIGN}/adgroups/{SEARCH_MATCH_AG}",
             {"name": ag.get("name"), "startTime": ag.get("startTime"),
              "endTime": ag.get("endTime"), "status": "PAUSED",
              "defaultBidAmount": ag.get("defaultBidAmount"),
              "automatedKeywordsOptIn": ag.get("automatedKeywordsOptIn")})
    print("search-match ad group ->",
          (r.get("data") or {}).get("status", f"FAILED {json.dumps(r.get('error'))[:250]}"))

    # 2. Dead keywords: 146 impressions between them, 1 tap total. Bulk endpoint.
    kws = call("GET", f"/campaigns/{CAMPAIGN}/adgroups/{BROAD_AG}/targetingkeywords?limit=100")
    doomed = [k for k in (kws.get("data") or []) if k["text"] in KILL and k["status"] == "ACTIVE"]
    if doomed:
        r = call("PUT", f"/campaigns/{CAMPAIGN}/adgroups/{BROAD_AG}/targetingkeywords/bulk",
                 [{"id": k["id"], "adGroupId": BROAD_AG, "status": "PAUSED"} for k in doomed])
        if r.get("data"):
            for k in r["data"]:
                print(f"  keyword {k['text']:<22} -> {k['status']}")
        else:
            print(f"  keyword bulk pause FAILED: {json.dumps(r.get('error'))[:250]}")

    # 3. Budget: fewer impressions against better terms beats more against worse ones.
    r = call("PUT", f"/campaigns/{CAMPAIGN}",
             {"campaign": {"dailyBudgetAmount": {"amount": NEW_DAILY, "currency": "USD"}}})
    d = r.get("data") or {}
    print("daily budget ->", (d.get("dailyBudgetAmount") or {}).get("amount",
          f"FAILED {json.dumps(r.get('error'))[:200]}"))

    c = call("GET", f"/campaigns/{CAMPAIGN}") or {}
    c = c.get("data") or {}
    print(f"\ncampaign: {c.get('status')} | serving {c.get('servingStatus')} | "
          f"${(c.get('dailyBudgetAmount') or {}).get('amount')}/day")
    for ag in (call("GET", f"/campaigns/{CAMPAIGN}/adgroups?limit=20").get("data") or []):
        print(f"  ad group {ag['name']:<26} {ag['status']}")


if __name__ == "__main__":
    main()
