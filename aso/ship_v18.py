#!/usr/bin/env python3
"""Ship App Store version 1.8 end-to-end (run AFTER build upload):
1. Renames the draft version 1.7 -> 1.8 (keeps all metadata already set)
2. Waits for build 13 (train 1.8) to finish Apple processing
3. Attaches the build to the version
4. Submits the version for App Review

Run:  python3 aso/ship_v18.py
"""
import sys
import time

from asc_client import req, APP_ID

VID = "97b7562b-593e-42fb-af93-223001450dca"  # draft version (was 1.7)


def rename():
    code, d = req("GET", f"/v1/appStoreVersions/{VID}?fields[appStoreVersions]=versionString")
    cur = d["data"]["attributes"]["versionString"]
    if cur == "1.8":
        print("version already 1.8")
        return
    code, d = req("PATCH", f"/v1/appStoreVersions/{VID}",
                  {"data": {"type": "appStoreVersions", "id": VID,
                            "attributes": {"versionString": "1.8"}}})
    if code >= 400:
        sys.exit(f"rename failed: {code} {d['errors'][0].get('detail')}")
    print("version renamed to 1.8")


def wait_for_build(timeout_min=30):
    print("waiting for build 13 (1.8) to process", end="", flush=True)
    deadline = time.time() + timeout_min * 60
    while time.time() < deadline:
        # filter by train version directly — restricting fields[builds] drops
        # the relationships block, which broke the previous detection
        code, d = req("GET", f"/v1/builds?filter[app]={APP_ID}&filter[version]=13"
                             "&filter[preReleaseVersion.version]=1.8"
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
    print("build attached to version 1.8")


def declare_encryption(build_id):
    """Missing export-compliance declaration blocks review (was the 409)."""
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
    """Reuse a dangling draft submission from a previous partial run, if any."""
    code, d = req("GET", f"/v1/reviewSubmissions?filter[app]={APP_ID}&filter[state]="
                         "READY_FOR_REVIEW,WAITING_FOR_REVIEW,IN_REVIEW,UNRESOLVED_ISSUES&limit=5")
    for s in d.get("data", []):
        if s["attributes"].get("state") == "READY_FOR_REVIEW":
            return s["id"]
    return None


def submit():
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
                                "appStoreVersion": {"data": {"type": "appStoreVersions", "id": VID}}}}})
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
    rename()
    build_id = wait_for_build()
    attach(build_id)
    declare_encryption(build_id)
    submit()
