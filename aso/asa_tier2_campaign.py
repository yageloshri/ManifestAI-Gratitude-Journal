#!/usr/bin/env python3
"""Move the test from the US to English tier-2 (GB/CA/AU) — Yagel-approved 2026-08-07.

Why. US day 1: 657 impressions, 9 taps, 0 installs, $15.35 at $1.71/tap. The open
question is whether our product page converts at all, and the US is the most
expensive place on earth to buy that answer.

GB/CA/AU are invisible for us organically on the exact terms we were bidding
(`vision board`, `manifestation journal`, `gratitude app` all unranked; `gratitude
journal` #91/#174/#70), so every install there is incremental rather than bought
back from our own organic listing.

They also share our English product page, so the ad creative is IDENTICAL to the
US one. That makes this a controlled experiment with price as the only variable:

  TTR ~5% here  -> the creative is fine, the US is just brutal
  TTR ~1.4% here -> the creative is the problem, and no budget fixes that

Keywords are the three that showed life in the US, plus the two the US never gave
enough impressions to judge. Bid: launched at $1.20 on the assumption that tier-2 auctions clear lower than the
US. That was wrong — 4 impressions in 10 hours on $0.00 spend, i.e. we lost
essentially every auction. Raised to $2.00 (the US level) on 2026-08-08. Note this
does not make us more expensive: the bid is a ceiling, not a price. If GB/CA/AU
really are cheaper — the whole thesis — the realised CPT settles below the US
$1.71 on its own. The low bid saved nothing; it only kept us out of the auction.

No pip deps (openssl + urllib), same as asa_guard.py.
"""
import json
import os
import sys
from datetime import datetime, timedelta, timezone

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from asa_guard import call, CAMPAIGN as US_CAMPAIGN, ORG  # noqa: E402

ADAM_ID = 6757018484
DAILY = "20"
BID = "2.00"  # was 1.20 at launch: 4 impressions in 10h, we lost every auction
COUNTRIES = ["GB", "CA", "AU"]

# Carried over from the US run. `gratitude journal` was the only proven winner
# (6.12% TTR); `vision board` was second (3.03%). The rest are unresolved, not
# dead — they never got enough US impressions to judge.
KEYWORDS = ["gratitude journal", "vision board", "manifestation journal",
            "gratitude app", "manifestation app", "369 method", "affirmations",
            "law of attraction", "gratitude jar", "angel numbers"]

# Same day-one negatives as the US campaign: "manifest" is a Netflix series, a
# chapter of US history, a cargo document and an Android build file. Plus
# `scentiment`, which the waste guard caught burning US impressions on day 1.
NEGATIVES = ["manifest tv show", "manifest season", "manifest season 4",
             "manifest netflix", "manifest series", "manifest destiny",
             "cargo manifest", "flight manifest", "shipping manifest",
             "manifest file", "android manifest", "manifest json",
             "manifest v3", "web manifest", "scentiment"]


def main():
    start = (datetime.now(timezone.utc) + timedelta(minutes=10)).strftime("%Y-%m-%dT%H:%M:%S.000")
    end = (datetime.now(timezone.utc) + timedelta(days=7)).strftime("%Y-%m-%dT%H:%M:%S.000")

    # 1. Stop the US spend first, so the two never overlap on budget.
    r = call("PUT", f"/campaigns/{US_CAMPAIGN}", {"campaign": {"status": "PAUSED"}})
    print(f"US campaign {US_CAMPAIGN} ->", (r.get("data") or {}).get("status", "FAILED"))

    # 2. New tier-2 campaign.
    camp = call("POST", "/campaigns", {
        "name": "manifest gb/ca/au — english tier 2",
        "adamId": ADAM_ID,
        "countriesOrRegions": COUNTRIES,
        "adChannelType": "SEARCH",
        "supplySources": ["APPSTORE_SEARCH_RESULTS"],
        "billingEvent": "TAPS",
        "dailyBudgetAmount": {"amount": DAILY, "currency": "USD"},
        "status": "ENABLED",
    }).get("data")
    if not camp:
        sys.exit("campaign creation failed")
    cid = camp["id"]
    print(f"campaign: {cid} — {camp['name']} ({', '.join(COUNTRIES)})")

    neg = call("POST", f"/campaigns/{cid}/negativekeywords/bulk",
               [{"text": t, "matchType": "EXACT"} for t in NEGATIVES]).get("data")
    print(f"negatives: {len(neg) if neg else 0}/{len(NEGATIVES)}")

    ag = call("POST", f"/campaigns/{cid}/adgroups", {
        "name": "broad — intent terms",
        "campaignId": cid,
        "startTime": start, "endTime": end,
        "automatedKeywordsOptIn": False,
        "pricingModel": "CPC",
        "defaultBidAmount": {"amount": BID, "currency": "USD"},
    }).get("data")
    if not ag:
        sys.exit("ad group creation failed")
    print(f"ad group: {ag['id']} (ends {end})")

    kws = call("POST", f"/campaigns/{cid}/adgroups/{ag['id']}/targetingkeywords/bulk",
               [{"text": t, "matchType": "BROAD",
                 "bidAmount": {"amount": BID, "currency": "USD"}} for t in KEYWORDS]).get("data")
    print(f"keywords: {len(kws) if kws else 0}/{len(KEYWORDS)} at ${BID}")

    c = (call("GET", f"/campaigns/{cid}") or {}).get("data") or {}
    print(f"\nfinal: {c.get('status')} | serving {c.get('servingStatus')} | "
          f"reasons {c.get('servingStateReasons')} | ${(c.get('dailyBudgetAmount') or {}).get('amount')}/day")
    print(f"\nPoint the waste guard at this campaign: set CAMPAIGN = {cid} in aso/asa_guard.py")


if __name__ == "__main__":
    main()
