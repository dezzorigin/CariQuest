#!/usr/bin/env python3
"""Sweep dependensi Dart/Pub terhadap OSV (Open Source Vulnerabilities).

Pola repo #24-#47: 1 POST ke api.osv.dev/v1/querybatch untuk semua paket
produksi. JANGAN ganti ke `npm audit` (repo ini bukan Node; tidak ada
package-lock.json) atau ke GitHub Advisory DB API + GITHUB_TOKEN
(401 deterministik di CI).

Repo ini (Flutter): paket produksi dibaca dari pubspec.lock — semua paket
`hosted` (pub.dev) kecuali paket dev langsung (`flutter_lints`,
`flutter_test`) dan paket `sdk`/`path`/`git` (tidak ada di OSV Pub).
HIGH/CRITICAL = gagal (exit 1). Tanpa token.

Usage:
    python3 scripts/advisory-sweep.py
Exit 0 = bersih, 1 = temuan HIGH/CRITICAL, 2 = error API.
"""
import json
import os
import re
import sys
import urllib.error
import urllib.request

SEVERITIES = ("HIGH", "CRITICAL")
OSV_BATCH_URL = "https://api.osv.dev/v1/querybatch"
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Paket dev langsung — tidak ikut terkirim ke build web.
DEV_DIRECT = {"flutter_lints", "flutter_test"}


def load_pub_packages(lock_path):
    """name -> version, dari pubspec.lock (parse regex, tanpa PyYAML).

    Format lock stabil:
        packages:
          foo:
            dependency: "direct main"
            source: hosted
            version: "1.2.3"
    """
    pkgs = {}
    if not os.path.exists(lock_path):
        return pkgs
    with open(lock_path, encoding="utf-8") as f:
        text = f.read()
    block_re = re.compile(
        r"^  ([A-Za-z0-9_.-]+):\n((?:    .*\n)+)", re.MULTILINE
    )
    for m in block_re.finditer(text):
        name, body = m.group(1), m.group(2)
        dep = re.search(r'dependency:\s*"([^"]+)"', body)
        src = re.search(r"source:\s*(\w+)", body)
        ver = re.search(r'version:\s*"([^"]+)"', body)
        if not (dep and src and ver):
            continue
        if src.group(1) != "hosted":
            continue  # sdk/path/git tidak ada di OSV Pub
        if dep.group(1) == "direct dev" and name in DEV_DIRECT:
            continue
        if dep.group(1) == "transitive" and name in DEV_DIRECT:
            continue
        pkgs[name] = ver.group(1)
    return dict(sorted(pkgs.items()))


def severity_of(vuln):
    ds = vuln.get("database_specific") or {}
    sev = (ds.get("severity") or "").upper()
    if sev in ("CRITICAL", "HIGH", "MODERATE", "LOW"):
        return sev
    for s in vuln.get("severity", []):
        if s.get("type") == "CVSS_V3":
            score = s.get("score", "")
            m = re.match(r"CVSS:3\.[01]/.*", str(score))
            if m:
                continue
    return "UNKNOWN"


def main():
    lock = os.path.join(ROOT, "pubspec.lock")
    pkgs = load_pub_packages(lock)
    if not pkgs:
        print("FAIL: tidak ada paket hosted terbaca dari pubspec.lock")
        return 2
    print(f"memeriksa {len(pkgs)} paket Pub di OSV ...")
    queries = [
        {"package": {"name": name, "ecosystem": "Pub"}, "version": ver}
        for name, ver in pkgs.items()
    ]
    body = json.dumps({"queries": queries}).encode()
    req = urllib.request.Request(
        OSV_BATCH_URL, data=body,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=120) as r:
            data = json.load(r)
    except urllib.error.HTTPError as e:
        print(f"FAIL: OSV HTTP {e.code}: {e.read()[:300]!r}")
        return 2
    except Exception as e:  # noqa: BLE001 — error jaringan = error API
        print(f"FAIL: OSV tidak terjangkau: {e}")
        return 2

    findings = []
    for (name, _ver), res in zip(pkgs.items(), data.get("results", [])):
        for vuln in res.get("vulns", []):
            sev = severity_of(vuln)
            if sev in SEVERITIES:
                findings.append((name, vuln.get("id"), sev,
                                 (vuln.get("summary") or "")[:100]))
    if findings:
        print(f"FAIL: {len(findings)} temuan HIGH/CRITICAL:")
        for name, vid, sev, summary in findings:
            print(f"  {sev:8} {vid} ({name}): {summary}")
        return 1
    print(f"OK: {len(pkgs)} paket Pub bersih (tanpa HIGH/CRITICAL).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
