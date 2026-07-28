#!/usr/bin/env python3
"""Sales & Trends puller for Manifest: Vision Board & 369 (app 6757018484).
Pulls daily SALES + SUBSCRIPTION_EVENT reports from the App Store Connect
Sales Reports API, aggregates downloads/trial events by day + country, and
appends a dated JSON line to aso/analytics/history.jsonl.

Vendor number (required, not obtainable via API): set env ASC_VENDOR_NUMBER
or put it in ~/.appstoreconnect/vendor_number.txt (find it in App Store
Connect > Payments and Financial Reports, top-left gray bar).

Usage: python3 sales_pull.py [days]        (default 14)
Importable: from sales_pull import pull; pull(days=14)
"""
import csv, gzip, io, json, os, sys, urllib.request, urllib.error
from datetime import date, timedelta

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import asc_client

APP_APPLE_ID = "6757018484"
APP_SKU_HINT = "ManifestAI"  # SKU prefix fallback
HISTORY = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                       "analytics", "history.jsonl")
# Product Type Identifiers that count as app download units (new installs)
DOWNLOAD_TYPES = {"1", "1F", "1T", "F1", "1E", "1EP", "1EU"}
UPDATE_TYPES = {"7", "7F", "7T", "F7"}


def vendor_number():
    v = os.environ.get("ASC_VENDOR_NUMBER")
    if v:
        return v.strip()
    p = os.path.expanduser("~/.appstoreconnect/vendor_number.txt")
    if os.path.exists(p):
        return open(p).read().strip()
    raise SystemExit(
        "Missing vendor number. Set ASC_VENDOR_NUMBER or write it to "
        "~/.appstoreconnect/vendor_number.txt (App Store Connect > "
        "Payments and Financial Reports, top-left gray bar).")


def fetch_report(report_type, sub_type, report_date, version=None,
                 frequency="DAILY"):
    """Return list of TSV row dicts, or None if no report for that day (404)."""
    params = {
        "filter[reportType]": report_type,
        "filter[reportSubType]": sub_type,
        "filter[frequency]": frequency,
        "filter[reportDate]": report_date,
        "filter[vendorNumber]": vendor_number(),
    }
    if version:
        params["filter[version]"] = version
    qs = "&".join(f"{k}={v}" for k, v in params.items())
    req = urllib.request.Request(
        f"{asc_client.BASE}/v1/salesReports?{qs}",
        headers={"Authorization": f"Bearer {asc_client.token()}",
                 "Accept": "application/a-gzip"})
    try:
        with urllib.request.urlopen(req) as resp:
            raw = resp.read()
    except urllib.error.HTTPError as e:
        if e.code == 404:  # no data for that day
            return None
        raise SystemExit(f"{report_type} {report_date}: HTTP {e.code} "
                         f"{e.read().decode(errors='replace')[:300]}")
    text = gzip.decompress(raw).decode("utf-8", errors="replace")
    rows = list(csv.DictReader(io.StringIO(text), delimiter="\t"))
    return rows


def is_our_row(row):
    if row.get("Apple Identifier", "").strip() == APP_APPLE_ID:
        return True
    sku = row.get("SKU", "") or ""
    return APP_SKU_HINT in sku


def pull(days=14, end=None, write_history=True):
    """Pull last `days` daily SALES + SUBSCRIPTION_EVENT reports.
    Returns aggregate dict; appends one JSON line to history.jsonl."""
    end = end or (date.today() - timedelta(days=1))
    daily, countries, sub_events = {}, {}, {}
    missing_days, sub_missing = [], []
    for i in range(days):
        d = end - timedelta(days=i)
        ds = d.isoformat()
        rows = fetch_report("SALES", "SUMMARY", ds)
        if rows is None:
            missing_days.append(ds)
        else:
            rec = daily.setdefault(ds, {"downloads": 0, "updates": 0,
                                        "iap_units": 0})
            for r in (r for r in rows if is_our_row(r)):
                units = int(float(r.get("Units", 0) or 0))
                pt = (r.get("Product Type Identifier") or "").strip()
                cc = (r.get("Country Code") or "??").strip()
                if pt in DOWNLOAD_TYPES:
                    rec["downloads"] += units
                    countries[cc] = countries.get(cc, 0) + units
                elif pt in UPDATE_TYPES:
                    rec["updates"] += units
                else:
                    rec["iap_units"] += units
        srows = fetch_report("SUBSCRIPTION_EVENT", "SUMMARY", ds,
                             version="1_4")
        if srows is None:
            sub_missing.append(ds)
        else:
            for r in (r for r in srows if is_our_row(r)):
                ev = (r.get("Event") or "unknown").strip()
                qty = int(float(r.get("Quantity", 0) or 0))
                key = (ds, ev, (r.get("Country") or "??").strip())
                sub_events[key] = sub_events.get(key, 0) + qty
    result = {
        "pulled_at": date.today().isoformat(),
        "range": {"start": (end - timedelta(days=days - 1)).isoformat(),
                  "end": end.isoformat()},
        "total_downloads": sum(v["downloads"] for v in daily.values()),
        "daily": dict(sorted(daily.items())),
        "countries": dict(sorted(countries.items(),
                                 key=lambda kv: -kv[1])),
        "subscription_events": [
            {"date": k[0], "event": k[1], "country": k[2], "qty": v}
            for k, v in sorted(sub_events.items())],
        "sales_days_missing": sorted(missing_days),
        "sub_event_days_missing": sorted(sub_missing),
    }
    if write_history:
        os.makedirs(os.path.dirname(HISTORY), exist_ok=True)
        with open(HISTORY, "a") as f:
            f.write(json.dumps(result) + "\n")
    return result


if __name__ == "__main__":
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 14
    res = pull(days=n)
    print(json.dumps(res, indent=2))
