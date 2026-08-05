#!/usr/bin/env python3
"""Ship App Store version 2.0 end-to-end (run AFTER build upload):
1. Waits for build 15 (train 2.0) to finish Apple processing
2. Attaches the build to the version
3. Submits the version for App Review

Run:  python3 aso/ship_v20.py
"""
import sys
import time

from asc_client import req, APP_ID

VID = "2a49392e-27d0-473b-9b53-f9149e279c53"  # v2.0 PREPARE_FOR_SUBMISSION
BUILD_NO = "15"
TRAIN = "2.0"


def wait_for_build(timeout_min=40):
    print(f"waiting for build {BUILD_NO} ({TRAIN}) to process", end="", flush=True)
    deadline = time.time() + timeout_min * 60
    while time.time() < deadline:
        # filter by train version directly — restricting fields[builds] drops
        # the relationships block, which broke the previous detection
        code, d = req("GET", f"/v1/builds?filter[app]={APP_ID}&filter[version]={BUILD_NO}"
                             f"&filter[preReleaseVersion.version]={TRAIN}"
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


def attach(build_id):
    code, d = req("PATCH", f"/v1/appStoreVersions/{VID}/relationships/build",
                  {"data": {"type": "builds", "id": build_id}})
    if code >= 400:
        sys.exit(f"attach failed: {code} {d['errors'][0].get('detail')}")
    print(f"build attached to version {TRAIN}")


def submit():
    code, d = req("POST", "/v1/reviewSubmissions",
                  {"data": {"type": "reviewSubmissions",
                            "attributes": {"platform": "IOS"},
                            "relationships": {"app": {"data": {"type": "apps", "id": APP_ID}}}}})
    if code >= 400:
        detail = d["errors"][0].get("detail", "")
        if "already" in detail.lower():
            print("review submission already exists, adding item to it")
            c2, d2 = req("GET", f"/v1/apps/{APP_ID}/reviewSubmissions?filter[state]=READY_FOR_REVIEW")
            subs = d2.get("data", [])
            if not subs:
                sys.exit(f"submit failed: {code} {detail}")
            sub_id = subs[0]["id"]
        else:
            sys.exit(f"submit failed: {code} {detail}")
    else:
        sub_id = d["data"]["id"]
    code, d = req("POST", "/v1/reviewSubmissionItems",
                  {"data": {"type": "reviewSubmissionItems",
                            "relationships": {
                                "reviewSubmission": {"data": {"type": "reviewSubmissions", "id": sub_id}},
                                "appStoreVersion": {"data": {"type": "appStoreVersions", "id": VID}}}}})
    if code >= 400:
        sys.exit(f"submission item failed: {code} {d['errors'][0].get('detail')}")
    code, d = req("PATCH", f"/v1/reviewSubmissions/{sub_id}",
                  {"data": {"type": "reviewSubmissions", "id": sub_id,
                            "attributes": {"submitted": True}}})
    if code >= 400:
        sys.exit(f"final submit failed: {code} {d['errors'][0].get('detail')}")
    print("version 2.0 SUBMITTED for App Review")


if __name__ == "__main__":
    build_id = wait_for_build()
    attach(build_id)
    submit()
