#!/usr/bin/env python3
"""Apple Search Hints harvester for Manifest: Vision Board & 369.

Calls the MZSearchHints endpoint per storefront — the ORDER of returned
suggestions is the local-popularity proxy for that prefix (standing strategy).

  https://search.itunes.apple.com/WebObjects/MZSearchHints.woa/wa/hints
      ?clientApplication=Software&term=<prefix>
  header: X-Apple-Store-Front: <storefrontID>-1,29

Response is a plist; parsed with plistlib.

Usage:
  python3 aso/hints_harvester.py us manif        # print ordered hints
  python3 aso/hints_harvester.py il "לוח חז"
As a library:
  from hints_harvester import fetch_hints, STOREFRONT_ID
"""
import sys, time, plistlib, urllib.request, urllib.parse

# country code -> numeric Apple storefront ID (X-Apple-Store-Front)
# source: canonical iTunes storefront table, verified 2026-07 (gist BrychanOdlum)
STOREFRONT_ID = {
    "us": 143441, "gb": 143444, "au": 143460, "ca": 143455, "il": 143491,
    "de": 143443, "fr": 143442, "it": 143450, "es": 143454, "mx": 143468,
    "br": 143503, "nl": 143452, "pl": 143478, "tr": 143480, "ru": 143469,
    "se": 143456, "no": 143457, "dk": 143458, "fi": 143447, "jp": 143462,
    "kr": 143466, "cn": 143465, "sa": 143479, "id": 143476, "vn": 143471,
}

ENDPOINT = "https://search.itunes.apple.com/WebObjects/MZSearchHints.woa/wa/hints"
THROTTLE_SECONDS = 1.5


def _extract_terms(obj):
    """Recursively pull ordered 'term' strings out of the parsed plist."""
    out = []
    if isinstance(obj, dict):
        if "term" in obj and isinstance(obj["term"], str):
            out.append(obj["term"])
        for v in obj.values():
            out.extend(_extract_terms(v))
    elif isinstance(obj, list):
        for v in obj:
            out.extend(_extract_terms(v))
    return out


def fetch_hints(country, prefix, retries=1):
    """Ordered suggestion list for prefix in country's storefront (position = popularity)."""
    sf = STOREFRONT_ID[country]
    q = urllib.parse.urlencode({"clientApplication": "Software", "term": prefix})
    req = urllib.request.Request(
        f"{ENDPOINT}?{q}",
        headers={"X-Apple-Store-Front": f"{sf}-1,29",
                 "User-Agent": "iTunes/12.12 (Macintosh; OS X 10.15)"})
    for attempt in range(retries + 1):
        try:
            with urllib.request.urlopen(req, timeout=20) as r:
                data = r.read()
            terms, seen = [], set()
            for t in _extract_terms(plistlib.loads(data)):
                tl = t.strip()
                if tl and tl.lower() not in seen:
                    seen.add(tl.lower())
                    terms.append(tl)
            return terms
        except Exception as e:
            if attempt < retries:
                time.sleep(4)
            else:
                print(f"  !! hints failed [{country}] '{prefix}': {e}",
                      file=sys.stderr)
                return None
    return None


if __name__ == "__main__":
    if len(sys.argv) < 3:
        sys.exit("usage: hints_harvester.py <country> <seed prefix>")
    country, prefix = sys.argv[1], " ".join(sys.argv[2:])
    hints = fetch_hints(country, prefix)
    if hints is None:
        sys.exit(1)
    for i, t in enumerate(hints, 1):
        print(f"{i:>2}. {t}")
