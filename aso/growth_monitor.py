#!/usr/bin/env python3
"""Weekly compliant growth monitor for Manifest: Vision Board & 369.

Runs entirely on public/authorized APIs — no posting, no reviews, no rule-
breaking. Meant to be driven by launchd once a week. It:
  1. Runs the 25-storefront keyword rank scan (aso/rank_tracker) and diffs
     against the previous snapshot (movers up/down, new keywords ranked).
  2. Pulls Google Search Console: sitemap state, index coverage of every
     sitemap URL, and last-7/28-day search queries (impressions/clicks/pos).
  3. Re-pings IndexNow (Bing/Yandex) with all sitemap URLs so fresh content
     is re-discovered.
  4. Writes a dated markdown report to aso/reports/<date>.md.

GSC auth uses the user's Application Default Credentials (webmasters scope),
same recipe the aso/seo experts use. If the token lacks scope it degrades
gracefully and notes it in the report.
"""
import os, sys, json, urllib.parse, time, subprocess, datetime, urllib.request, re

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
REPORTS = os.path.join(HERE, "reports")
SITE = "sc-domain:ai-manifest.com"
QUOTA_PROJECT = "shmorim-9d315"
INDEXNOW_KEY = "0e14305ee36247bab36482037254b3ff"
SITEMAP_URL = "https://www.ai-manifest.com/sitemap.xml"


def gcloud_token():
    try:
        return subprocess.run(
            ["gcloud", "auth", "application-default", "print-access-token"],
            capture_output=True, text=True, timeout=60).stdout.strip()
    except Exception:
        return ""


def gsc(path, method="GET", body=None, token=None):
    url = f"https://searchconsole.googleapis.com/{path}"
    r = urllib.request.Request(url, method=method,
        headers={"Authorization": f"Bearer {token}",
                 "X-Goog-User-Project": QUOTA_PROJECT,
                 "Content-Type": "application/json"},
        data=json.dumps(body).encode() if body else None)
    try:
        with urllib.request.urlopen(r, timeout=60) as resp:
            return resp.status, json.load(resp)
    except urllib.error.HTTPError as e:
        return e.code, json.load(e)
    except Exception as e:
        return 0, {"error": str(e)}


def sitemap_urls():
    try:
        with urllib.request.urlopen(SITEMAP_URL, timeout=30) as r:
            return re.findall(r"<loc>([^<]+)</loc>", r.read().decode())
    except Exception:
        return []


def indexnow(urls):
    payload = {"host": "www.ai-manifest.com", "key": INDEXNOW_KEY,
               "keyLocation": f"https://www.ai-manifest.com/{INDEXNOW_KEY}.txt",
               "urlList": urls}
    req = urllib.request.Request("https://api.indexnow.org/indexnow",
        data=json.dumps(payload).encode(),
        headers={"Content-Type": "application/json; charset=utf-8"}, method="POST")
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            return r.status
    except urllib.error.HTTPError as e:
        return e.code
    except Exception:
        return 0


def rank_section():
    lines = []
    try:
        import rank_tracker
        rank_tracker.scan()  # appends snapshot, updates latest.json
        latest = json.load(open(os.path.join(HERE, "rankings", "latest.json"), encoding="utf-8"))
        hist = open(os.path.join(HERE, "rankings", "history.jsonl"), encoding="utf-8").read().strip().splitlines()
        prev = json.loads(hist[-2]) if len(hist) >= 2 else None
        prev_map = {(r["country"], r["keyword"]): r["rank"] for r in prev["rows"]} if prev else {}
        ranked = [r for r in latest["rows"] if isinstance(r["rank"], int)]
        top10 = [r for r in ranked if r["rank"] <= 10]
        lines.append(f"- Ranked pairs: **{len(ranked)}/{len(latest['rows'])}** | top-10: **{len(top10)}**")
        movers = []
        for r in ranked:
            old = prev_map.get((r["country"], r["keyword"]))
            if isinstance(old, int) and old != r["rank"]:
                movers.append((old - r["rank"], r, old))
        movers.sort(key=lambda x: -x[0])
        if movers:
            lines.append("\n**Biggest movers vs last week:**")
            for delta, r, old in movers[:12]:
                arrow = "▲" if delta > 0 else "▼"
                lines.append(f"  - {arrow} {abs(delta)}  [{r['country']}] {r['keyword']}: #{old} → #{r['rank']}")
        newly = [r for r in ranked if (r["country"], r["keyword"]) not in prev_map and prev]
        if newly:
            lines.append("\n**Newly ranked keywords:**")
            for r in sorted(newly, key=lambda x: x["rank"])[:12]:
                lines.append(f"  - #{r['rank']} [{r['country']}] {r['keyword']}")
    except Exception as e:
        lines.append(f"- rank scan failed: {e}")
    return "\n".join(lines)


def gsc_section(token):
    if not token:
        return "- (no GSC token — run: gcloud auth application-default login --scopes=.../webmasters)"
    out = []
    site_enc = urllib.parse.quote(SITE, safe="")
    code, data = gsc(f"webmasters/v3/sites/{site_enc}/sitemaps", token=token)
    if code == 200 and data.get("sitemap"):
        s = data["sitemap"][0]
        c = (s.get("contents") or [{}])[0]
        out.append(f"- Sitemap: submitted={c.get('submitted','?')} indexed={c.get('indexed','?')} "
                   f"errors={s.get('errors')} lastDownloaded={s.get('lastDownloaded','?')[:10]}")
    urls = sitemap_urls()
    idx = 0
    for u in urls:
        code, data = gsc("v1/urlInspection/index:inspect", "POST",
                         {"inspectionUrl": u, "siteUrl": SITE}, token)
        st = (data.get("inspectionResult", {}).get("indexStatusResult", {})
              .get("coverageState", "?"))
        if "indexed" in st.lower():
            idx += 1
        time.sleep(1.0)
    out.append(f"- Indexed pages: **{idx}/{len(urls)}**")
    today = datetime.date.today()
    for label, days in [("7d", 7), ("28d", 28)]:
        code, data = gsc(f"webmasters/v3/sites/{site_enc}/searchAnalytics/query", "POST",
            {"startDate": str(today - datetime.timedelta(days=days)),
             "endDate": str(today), "dimensions": ["query"], "rowLimit": 25}, token)
        rows = data.get("rows", []) if code == 200 else []
        tot_imp = sum(r["impressions"] for r in rows)
        tot_clk = sum(r["clicks"] for r in rows)
        out.append(f"- Search {label}: {len(rows)} queries, {tot_imp} impressions, {tot_clk} clicks")
        for r in rows[:8]:
            out.append(f"    · \"{r['keys'][0]}\" — {r['impressions']}imp {r['clicks']}clk pos {r['position']:.1f}")
    return "\n".join(out)


def main():
    os.makedirs(REPORTS, exist_ok=True)
    stamp = datetime.date.today().isoformat()
    token = gcloud_token()
    report = [f"# Growth monitor — {stamp}\n"]
    report.append("## App Store rankings (25 storefronts)\n" + rank_section())
    report.append("\n## Google Search Console\n" + gsc_section(token))
    urls = sitemap_urls()
    report.append(f"\n## IndexNow re-ping\n- {len(urls)} URLs → HTTP {indexnow(urls)}")
    report.append(f"\n_Compliant automation: public/authorized APIs only. "
                  f"No posting, reviews, or metadata changes performed._")
    path = os.path.join(REPORTS, f"{stamp}.md")
    open(path, "w", encoding="utf-8").write("\n".join(report))
    print(f"report written: {path}")


if __name__ == "__main__":
    import urllib.parse
    main()
