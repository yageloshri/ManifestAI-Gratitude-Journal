#!/usr/bin/env python3
"""Launch the user-approved Apple Ads test campaign (approved 2026-08-05 in chat):
one US Exact-Match campaign, $20/day, $140 lifetime hard cap, ad group auto-ends
after 7 days. 5 high-intent keywords (verified Astro popularity/difficulty).

Run:  <scratchpad-venv>/bin/python3 aso/asa_launch_campaign.py
"""
import json, time, jwt, requests
from datetime import datetime, timedelta, timezone

creds = json.load(open('/Users/yageloshri/.apple-ads/credentials.json'))
key = open(creds['privateKeyPath']).read()
now = int(time.time())
secret = jwt.encode({"iss": creds["teamId"], "iat": now, "exp": now + 86400,
                     "aud": "https://appleid.apple.com", "sub": creds["clientId"]},
                    key, algorithm="ES256", headers={"kid": creds["keyId"]})
tok = requests.post("https://appleid.apple.com/auth/oauth2/token", data={
    "grant_type": "client_credentials", "client_id": creds["clientId"],
    "client_secret": secret, "scope": "searchadsorg"}, timeout=30).json()["access_token"]
H = {"Authorization": f"Bearer {tok}", "X-AP-Context": "orgId=8939860",
     "Content-Type": "application/json"}
B = "https://api.searchads.apple.com/api/v5"

start_time = (datetime.now(timezone.utc) + timedelta(minutes=10)).strftime("%Y-%m-%dT%H:%M:%S.000")
end_time = (datetime.now(timezone.utc) + timedelta(days=7)).strftime("%Y-%m-%dT%H:%M:%S.000")

def post(path, body):
    r = requests.post(f"{B}{path}", headers=H, json=body, timeout=30)
    d = r.json()
    if r.status_code >= 400 or d.get("error"):
        print(f"!! {path}: {r.status_code} {json.dumps(d.get('error'))[:400]}")
        return None
    return d["data"]

c = {"id": 2144404347}
print("campaign: 2144404347 (already created)")

ag = post(f"/campaigns/{c['id']}/adgroups", {
    "name": "exact — high intent", "campaignId": c["id"],
    "startTime": start_time, "endTime": end_time,
    "automatedKeywordsOptIn": False, "pricingModel": "CPC",
    "defaultBidAmount": {"amount": "1.50", "currency": "USD"}})
if not ag: raise SystemExit(1)
print("adgroup:", ag["id"], "ends", end_time)

kws = post(f"/campaigns/{c['id']}/adgroups/{ag['id']}/targetingkeywords/bulk", [
    {"text": "gratitude app",         "matchType": "EXACT", "bidAmount": {"amount": "1.75", "currency": "USD"}},
    {"text": "gratitude jar",         "matchType": "EXACT", "bidAmount": {"amount": "1.50", "currency": "USD"}},
    {"text": "angel numbers",         "matchType": "EXACT", "bidAmount": {"amount": "1.50", "currency": "USD"}},
    {"text": "manifestation journal", "matchType": "EXACT", "bidAmount": {"amount": "1.25", "currency": "USD"}},
    {"text": "555 manifest",          "matchType": "EXACT", "bidAmount": {"amount": "1.25", "currency": "USD"}}])
print("keywords:", [k["text"] for k in kws] if kws else "FAILED")

r = requests.get(f"{B}/campaigns/{c['id']}", headers=H, timeout=30).json()["data"]
print("final state:", r["status"], "| serving:", r.get("servingStatus"), "| reasons:", r.get("servingStateReasons"))
