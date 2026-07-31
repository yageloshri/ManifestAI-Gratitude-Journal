#!/usr/bin/env python3
"""Ship App Store version 1.9 end-to-end (run AFTER prepare_v19.py + build upload):
1. Waits for build 14 (train 1.9) to finish Apple processing
2. Attaches the build to version 1.9
3. Declares export compliance (no non-exempt encryption)
4. Submits for App Review

Run:  python3 aso/ship_v19.py
"""
import sys
import time

from asc_client import req, APP_ID

VERSION = "1.9"
BUILD_NO = "14"


def find_version():
    code, d = req("GET", f"/v1/apps/{APP_ID}/appStoreVersions?limit=5"
                         "&fields[appStoreVersions]=versionString,appStoreState")
    for v in d["data"]:
        if v["attributes"]["versionString"] == VERSION:
            return v["id"]
    sys.exit(f"version {VERSION} not found — run prepare_v19.py first")


def wait_for_build(timeout_min=30):
    print(f"waiting for build {BUILD_NO} ({VERSION}) to process", end="", flush=True)
    deadline = time.time() + timeout_min * 60
    while time.time() < deadline:
        code, d = req("GET", f"/v1/builds?filter[app]={APP_ID}&filter[version]={BUILD_NO}"
                             f"&filter[preReleaseVersion.version]={VERSION}"
                             "&sort=-uploadedDate&limit=3")
        for b in d.get("data", []):
            state = b["attributes"]["processingState"]
            if state == "VALID":
                print(f"\nbuild ready: {b['id']}")
                return b["id"]
            if state in ("FAILED", "INVALID"):
                sys.exit(f"\nbuild processing {state} — check App Store Connect")
        print(".", end="", flush=True)
        time.sleep(60)
    sys.exit("\ntimed out waiting for build processing")


def attach(vid, build_id):
    code, d = req("PATCH", f"/v1/appStoreVersions/{vid}/relationships/build",
                  {"data": {"type": "builds", "id": build_id}})
    if code >= 400:
        sys.exit(f"attach failed: {code} {d['errors'][0].get('detail')}")
    print(f"build attached to version {VERSION}")


def declare_encryption(build_id):
    code, d = req("GET", f"/v1/builds/{build_id}?fields[builds]=usesNonExemptEncryption")
    if d["data"]["attributes"].get("usesNonExemptEncryption") is not None:
        print("export compliance already declared")
        return
    code, d = req("PATCH", f"/v1/builds/{build_id}",
                  {"data": {"type": "builds", "id": build_id,
                            "attributes": {"usesNonExemptEncryption": False}}})
    if code >= 400:
        sys.exit(f"encryption declaration failed: {code} {d['errors'][0].get('detail')}")
    print("export compliance declared (no non-exempt encryption)")


def _open_submission():
    code, d = req("GET", f"/v1/reviewSubmissions?filter[app]={APP_ID}&filter[state]="
                         "READY_FOR_REVIEW,WAITING_FOR_REVIEW,IN_REVIEW,UNRESOLVED_ISSUES&limit=5")
    for s in d.get("data", []):
        if s["attributes"].get("state") == "READY_FOR_REVIEW":
            return s["id"]
    return None


def submit(vid):
    sub_id = _open_submission()
    if sub_id:
        print("reusing existing draft submission", sub_id)
    else:
        code, d = req("POST", "/v1/reviewSubmissions",
                      {"data": {"type": "reviewSubmissions",
                                "attributes": {"platform": "IOS"},
                                "relationships": {"app": {"data": {"type": "apps", "id": APP_ID}}}}})
        if code >= 400:
            sys.exit(f"create submission failed: {code} {d['errors'][0].get('detail')}")
        sub_id = d["data"]["id"]
    code, d = req("POST", "/v1/reviewSubmissionItems",
                  {"data": {"type": "reviewSubmissionItems",
                            "relationships": {
                                "reviewSubmission": {"data": {"type": "reviewSubmissions", "id": sub_id}},
                                "appStoreVersion": {"data": {"type": "appStoreVersions", "id": vid}}}}})
    if code >= 400:
        detail = d["errors"][0].get("detail", "")
        if "already" not in detail.lower():
            sys.exit(f"add item failed: {code} {detail}")
        print("version already in submission")
    code, d = req("PATCH", f"/v1/reviewSubmissions/{sub_id}",
                  {"data": {"type": "reviewSubmissions", "id": sub_id,
                            "attributes": {"submitted": True}}})
    if code >= 400:
        sys.exit(f"submit failed: {code} {d['errors'][0].get('detail')}")
    print("submitted for App Review 🎉  state:", d["data"]["attributes"].get("state"))


if __name__ == "__main__":
    vid = find_version()
    build_id = wait_for_build()
    attach(vid, build_id)
    declare_encryption(build_id)
    submit(vid)
