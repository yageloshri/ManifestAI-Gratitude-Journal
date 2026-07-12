#!/usr/bin/env python3
"""Minimal App Store Connect API client (user-authorized for store tasks).
JWT signing via openssl; key lives outside the repo in ~/.appstoreconnect."""
import json, time, base64, subprocess, os, urllib.request

KEY_ID = "7U7SVLSZCP"
ISSUER = "252dc0f4-51c2-4f3a-9546-4905ecdbd9c9"
KEY_PATH = os.path.expanduser("~/.appstoreconnect/AuthKey_7U7SVLSZCP.p8")
BASE = "https://api.appstoreconnect.apple.com"
APP_ID = "6757018484"


def _b64url(b):
    return base64.urlsafe_b64encode(b).rstrip(b"=").decode()


def token():
    header = _b64url(json.dumps({"alg": "ES256", "kid": KEY_ID, "typ": "JWT"}).encode())
    now = int(time.time())
    claims = _b64url(json.dumps({"iss": ISSUER, "iat": now, "exp": now + 900,
                                 "aud": "appstoreconnect-v1"}).encode())
    signing_input = f"{header}.{claims}".encode()
    der = subprocess.run(["openssl", "dgst", "-sha256", "-sign", KEY_PATH],
                         input=signing_input, capture_output=True).stdout

    def der_to_raw(d):
        i = 2
        assert d[i] == 0x02; l = d[i + 1]; r = d[i + 2:i + 2 + l]; i += 2 + l
        assert d[i] == 0x02; l2 = d[i + 1]; s = d[i + 2:i + 2 + l2]
        return (r.lstrip(b"\x00").rjust(32, b"\x00") +
                s.lstrip(b"\x00").rjust(32, b"\x00"))

    return f"{header}.{claims}.{_b64url(der_to_raw(der))}"


def req(method, path, body=None):
    r = urllib.request.Request(BASE + path, method=method,
        headers={"Authorization": f"Bearer {token()}",
                 "Content-Type": "application/json"},
        data=json.dumps(body).encode() if body else None)
    try:
        with urllib.request.urlopen(r) as resp:
            data = resp.read()
            return resp.status, (json.loads(data) if data else {})
    except urllib.error.HTTPError as e:
        return e.code, json.load(e)


def get_version_localizations():
    """locale -> {id, keywords} for the newest editable (or latest) version."""
    code, data = req("GET", f"/v1/apps/{APP_ID}/appStoreVersions?limit=5")
    versions = data["data"]
    editable = [v for v in versions if v["attributes"]["appStoreState"] in
                ("PREPARE_FOR_SUBMISSION", "METADATA_REJECTED", "REJECTED",
                 "DEVELOPER_REJECTED", "WAITING_FOR_REVIEW")]
    vid = (editable or versions)[0]["id"]
    code, data = req("GET",
        f"/v1/appStoreVersions/{vid}/appStoreVersionLocalizations"
        f"?limit=50&fields[appStoreVersionLocalizations]=locale,keywords")
    return {l["attributes"]["locale"]:
            {"id": l["id"], "keywords": l["attributes"].get("keywords") or ""}
            for l in data["data"]}
