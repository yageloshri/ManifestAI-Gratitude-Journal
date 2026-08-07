#!/usr/bin/env python3
"""Apple Ads waste guard — read the Search Terms report, add negative keywords.

Runs BOTH locally and in a cloud routine, so it deliberately has **zero pip
dependencies**: ES256 JWT is signed with openssl (same trick as asc_client.py)
and HTTP goes through urllib. Do not add `requests`/`pyjwt` here — the cloud
sandbox does not have them.

Credentials, in priority order:
  1. env  ASA_CLIENT_ID / ASA_TEAM_ID / ASA_KEY_ID / ASA_PRIVATE_KEY (PEM text)
  2. file ~/.apple-ads/credentials.json + the private key it points at (local Mac)

Usage:
  python3 aso/asa_guard.py report                  # everything the guard can see
  python3 aso/asa_guard.py add-negatives "a" "b"   # campaign-level EXACT negatives
"""
import base64
import json
import os
import subprocess
import sys
import tempfile
import time
import urllib.error
import urllib.parse
import urllib.request

ORG = "8939860"
# The live Discovery campaign. The old Exact campaign 2144404347 is paused and
# must stay that way — it proved EXACT match produces no auctions for this app.
CAMPAIGN = 2144414959
API = "https://api.searchads.apple.com/api/v5"


def _b64url(b):
    return base64.urlsafe_b64encode(b).rstrip(b"=").decode()


def _creds():
    pem = os.environ.get("ASA_PRIVATE_KEY")
    if pem:
        return {"clientId": os.environ["ASA_CLIENT_ID"],
                "teamId": os.environ.get("ASA_TEAM_ID", os.environ["ASA_CLIENT_ID"]),
                "keyId": os.environ["ASA_KEY_ID"],
                "pem": pem.replace("\\n", "\n")}
    path = os.path.expanduser("~/.apple-ads/credentials.json")
    if not os.path.exists(path):
        sys.exit("NO_CREDENTIALS: set ASA_CLIENT_ID / ASA_TEAM_ID / ASA_KEY_ID / "
                 "ASA_PRIVATE_KEY in the environment, or provide ~/.apple-ads/credentials.json")
    c = json.load(open(path))
    c["pem"] = open(c["privateKeyPath"]).read()
    return c


def _es256(signing_input, pem):
    """Sign with openssl and convert the DER signature to the raw R||S form JWT wants."""
    with tempfile.NamedTemporaryFile("w", suffix=".pem", delete=False) as f:
        f.write(pem)
        key_path = f.name
    try:
        der = subprocess.run(["openssl", "dgst", "-sha256", "-sign", key_path],
                             input=signing_input, capture_output=True).stdout
    finally:
        os.unlink(key_path)
    if not der:
        sys.exit("openssl failed to sign — is ASA_PRIVATE_KEY a valid EC private key?")
    i = 2
    if der[1] & 0x80:                     # long-form length byte
        i = 2 + (der[1] & 0x7F)
    assert der[i] == 0x02
    ln = der[i + 1]
    r = der[i + 2:i + 2 + ln]
    i += 2 + ln
    assert der[i] == 0x02
    ln2 = der[i + 1]
    s = der[i + 2:i + 2 + ln2]
    return r.lstrip(b"\x00").rjust(32, b"\x00") + s.lstrip(b"\x00").rjust(32, b"\x00")


def token():
    c = _creds()
    now = int(time.time())
    header = _b64url(json.dumps({"alg": "ES256", "kid": c["keyId"], "typ": "JWT"}).encode())
    claims = _b64url(json.dumps({"iss": c["teamId"], "iat": now, "exp": now + 3600,
                                 "aud": "https://appleid.apple.com",
                                 "sub": c["clientId"]}).encode())
    sig = _b64url(_es256(f"{header}.{claims}".encode(), c["pem"]))
    secret = f"{header}.{claims}.{sig}"
    body = urllib.parse.urlencode({"grant_type": "client_credentials",
                                   "client_id": c["clientId"],
                                   "client_secret": secret,
                                   "scope": "searchadsorg"}).encode()
    req = urllib.request.Request("https://appleid.apple.com/auth/oauth2/token", data=body,
                                 headers={"Content-Type": "application/x-www-form-urlencoded"})
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.load(r)["access_token"]


_TOK = None


def call(method, path, body=None):
    global _TOK
    if _TOK is None:
        _TOK = token()
    req = urllib.request.Request(
        API + path, method=method,
        data=json.dumps(body).encode() if body is not None else None,
        headers={"Authorization": f"Bearer {_TOK}", "X-AP-Context": f"orgId={ORG}",
                 "Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=45) as r:
            return json.load(r)
    except urllib.error.HTTPError as e:
        return json.loads(e.read() or b"{}")


def _rows(payload):
    return (payload.get("data") or {}).get("reportingDataResponse", {}).get("row", []) or []


def _m(metrics, key, default=0):
    """Apple omits installs/conversionRate entirely when they are zero."""
    v = metrics.get(key, default)
    return default if v is None else v


def report():
    today = time.strftime("%Y-%m-%d", time.gmtime())
    start = time.strftime("%Y-%m-%d", time.gmtime(time.time() - 8 * 86400))

    c = call("GET", f"/campaigns/{CAMPAIGN}").get("data") or {}
    print(f"CAMPAIGN {CAMPAIGN} {c.get('name')}")
    print(f"  status={c.get('status')} serving={c.get('servingStatus')} "
          f"reasons={c.get('servingStateReasons')} "
          f"budget={(c.get('dailyBudgetAmount') or {}).get('amount')}/day")

    sel = {"orderBy": [{"field": "localSpend", "sortOrder": "DESCENDING"}],
           "pagination": {"limit": 500}}
    common = {"startTime": start, "endTime": today, "returnRowTotals": True,
              "returnGrandTotals": True, "selector": sel}

    tot = call("POST", f"/reports/campaigns/{CAMPAIGN}/keywords",
               dict(common, returnRecordsWithNoMetrics=True))
    gt = ((tot.get("data") or {}).get("reportingDataResponse", {})
          .get("grandTotals", {}).get("total", {}))
    print(f"\nTOTALS {start}..{today}: impressions={_m(gt,'impressions')} "
          f"taps={_m(gt,'taps')} installs={_m(gt,'installs')} "
          f"spend={(gt.get('localSpend') or {}).get('amount','0')}")

    print("\nKEYWORDS")
    for r in _rows(tot):
        m, md = r["total"], r["metadata"]
        print(f"  {md.get('keyword',''):<26} {md.get('matchType',''):<6} "
              f"impr={_m(m,'impressions'):<6} taps={_m(m,'taps'):<4} "
              f"inst={_m(m,'installs'):<4} spend={m['localSpend']['amount']:<7} "
              f"CR={_m(m,'conversionRate')*100:.0f}%")

    print("\nSEARCH TERMS (what people actually typed)")
    st = call("POST", f"/reports/campaigns/{CAMPAIGN}/searchterms",
              dict(common, returnRecordsWithNoMetrics=False))
    rows = _rows(st)
    if not rows:
        print("  (none yet — no impressions have been served)")
    for r in rows:
        m, md = r["total"], r["metadata"]
        print(f"  term={md.get('searchTermText','')!r:<40} "
              f"src={md.get('searchTermSource',''):<12} "
              f"kw={md.get('keyword','')!r:<24} "
              f"impr={_m(m,'impressions'):<5} taps={_m(m,'taps'):<4} "
              f"inst={_m(m,'installs'):<4} spend={m['localSpend']['amount']}")

    ex = [n["text"] for n in (call("GET", f"/campaigns/{CAMPAIGN}/negativekeywords?limit=500")
                              .get("data") or [])]
    print(f"\nEXISTING NEGATIVES ({len(ex)}): {', '.join(sorted(ex))}")


def add_negatives(terms):
    have = {n["text"].lower() for n in
            (call("GET", f"/campaigns/{CAMPAIGN}/negativekeywords?limit=500").get("data") or [])}
    fresh = [t for t in terms if t.lower().strip() and t.lower().strip() not in have]
    if not fresh:
        print("nothing to add — all already negated")
        return
    res = call("POST", f"/campaigns/{CAMPAIGN}/negativekeywords/bulk",
               [{"text": t.strip(), "matchType": "EXACT"} for t in fresh])
    if res.get("data"):
        print(f"added {len(res['data'])}: {', '.join(t['text'] for t in res['data'])}")
    else:
        print(f"FAILED: {json.dumps(res.get('error'))[:400]}")


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else "report"
    if cmd == "report":
        report()
    elif cmd == "add-negatives":
        add_negatives(sys.argv[2:])
    else:
        sys.exit(__doc__)
