#!/usr/bin/env python3
"""Rebuild the US test as a Discovery campaign (Nikita Olijniks playbook).

Why: the Exact campaign (2144404347) served 0 impressions / $0 over 44h with
everything green — campaign RUNNING, keywords ACTIVE at $2.50-3.50, US eligible,
billing confirmed OK by Yagel 2026-08-07. Five EXACT terms at Apple popularity
7-17 on a brand-new app produce too few auctions to fill even one impression.

Discovery cannot return zero: Search Match lets Apple pick the queries from our
metadata instead of us guessing them.

Budget is UNCHANGED from the approved $20/day — the Exact campaign is paused so
the org never exceeds it (Nikita: fund one campaign fully rather than underfund two).

Run:  <scratchpad-venv>/bin/python3 aso/asa_discovery_campaign.py
"""
import json
import time
from datetime import datetime, timedelta, timezone

import jwt
import requests

ORG = "8939860"
ADAM_ID = 6757018484
OLD_CAMPAIGN = 2144404347
DAILY_BUDGET = "20"          # same cap Yagel approved on 2026-08-05
SEARCH_MATCH_BID = "2.00"
BROAD_BID = "2.00"

creds = json.load(open("/Users/yageloshri/.apple-ads/credentials.json"))
key = open(creds["privateKeyPath"]).read()
now = int(time.time())
secret = jwt.encode({"iss": creds["teamId"], "iat": now, "exp": now + 3600,
                     "aud": "https://appleid.apple.com", "sub": creds["clientId"]},
                    key, algorithm="ES256", headers={"kid": creds["keyId"]})
tok = requests.post("https://appleid.apple.com/auth/oauth2/token", data={
    "grant_type": "client_credentials", "client_id": creds["clientId"],
    "client_secret": secret, "scope": "searchadsorg"}, timeout=30).json()["access_token"]
H = {"Authorization": f"Bearer {tok}", "X-AP-Context": f"orgId={ORG}",
     "Content-Type": "application/json"}
B = "https://api.searchads.apple.com/api/v5"

start = (datetime.now(timezone.utc) + timedelta(minutes=10)).strftime("%Y-%m-%dT%H:%M:%S.000")
end = (datetime.now(timezone.utc) + timedelta(days=7)).strftime("%Y-%m-%dT%H:%M:%S.000")


def call(method, path, body=None):
    r = requests.request(method, f"{B}{path}", headers=H, json=body, timeout=40)
    d = r.json()
    if r.status_code >= 400 or (d.get("error") and d.get("data") is None):
        print(f"!! {method} {path}: {r.status_code} {json.dumps(d.get('error'))[:400]}")
        return None
    return d.get("data")


# 1. Pause the Exact campaign so total daily spend stays at the approved $20.
if call("PUT", f"/campaigns/{OLD_CAMPAIGN}",
        {"campaign": {"status": "PAUSED"}}) is not None:
    print(f"paused exact campaign {OLD_CAMPAIGN}")

# 2. Discovery campaign.
camp = call("POST", "/campaigns", {
    "name": "manifest us — discovery (search match)",
    "adamId": ADAM_ID,
    "countriesOrRegions": ["US"],
    "adChannelType": "SEARCH",
    "supplySources": ["APPSTORE_SEARCH_RESULTS"],
    "billingEvent": "TAPS",
    "dailyBudgetAmount": {"amount": DAILY_BUDGET, "currency": "USD"},
    "status": "ENABLED",
})
if not camp:
    raise SystemExit("campaign creation failed")
CID = camp["id"]
print(f"campaign: {CID} — {camp['name']}")

# 3. Campaign-level negatives, mandatory from day one (Nikita).
#    "manifest" is a huge ambiguous head term: a Netflix series, US history, cargo
#    documents, and an Android/Chrome build file. Search Match would happily spend
#    the whole budget on those. Block them before the first impression, not after.
NEGATIVES = [
    "manifest tv show", "manifest season", "manifest season 4", "manifest netflix",
    "manifest series", "manifest destiny", "cargo manifest", "flight manifest",
    "shipping manifest", "manifest file", "android manifest", "manifest json",
    "manifest v3", "web manifest",
]
neg = call("POST", f"/campaigns/{CID}/negativekeywords/bulk",
           [{"text": t, "matchType": "EXACT"} for t in NEGATIVES])
print(f"negatives: {len(neg) if neg else 0}/{len(NEGATIVES)} added")

# 4. Ad group A — Search Match ON, no keywords. Apple picks the queries.
ag_sm = call("POST", f"/campaigns/{CID}/adgroups", {
    "name": "search match — apple picks",
    "campaignId": CID,
    "startTime": start, "endTime": end,
    "automatedKeywordsOptIn": True,
    "pricingModel": "CPC",
    "defaultBidAmount": {"amount": SEARCH_MATCH_BID, "currency": "USD"},
})
print("adgroup search-match:", ag_sm["id"] if ag_sm else "FAILED")

# 5. Ad group B — BROAD match on the same intent terms that produced nothing on
#    EXACT. Broad expands to plurals, misspellings and related phrases, so it is a
#    genuine second shot at the same intent rather than a repeat of the experiment.
BROAD = ["gratitude app", "gratitude journal", "gratitude jar", "angel numbers",
         "manifestation journal", "manifestation app", "vision board", "369 method",
         "law of attraction", "affirmations"]
ag_broad = call("POST", f"/campaigns/{CID}/adgroups", {
    "name": "broad — intent terms",
    "campaignId": CID,
    "startTime": start, "endTime": end,
    "automatedKeywordsOptIn": False,
    "pricingModel": "CPC",
    "defaultBidAmount": {"amount": BROAD_BID, "currency": "USD"},
})
if ag_broad:
    print("adgroup broad:", ag_broad["id"])
    kws = call("POST", f"/campaigns/{CID}/adgroups/{ag_broad['id']}/targetingkeywords/bulk",
               [{"text": t, "matchType": "BROAD",
                 "bidAmount": {"amount": BROAD_BID, "currency": "USD"}} for t in BROAD])
    print(f"broad keywords: {len(kws) if kws else 0}/{len(BROAD)}")

c = call("GET", f"/campaigns/{CID}")
print(f"\nfinal: {c['status']} | serving {c.get('servingStatus')} | "
      f"reasons {c.get('servingStateReasons')} | budget {c['dailyBudgetAmount']['amount']}/day")
