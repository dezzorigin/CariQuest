#!/usr/bin/env python3
"""Gate statis CariQuest (P0 anti-slop + tag OG/Twitter + data asli repo).

Dijalankan di CI (job static-checks) dan lokal. Tanpa jaringan.
Cek:
  1. landing/index.html + landing/styles.css + landing/app.js bebas
     larangan P0 (gradient ungu/biru, headline gradient, font Inter/
     Roboto, emoji fungsi, copy generik, statistik vanity).
  2. Tag og:* + twitter:* lengkap di landing/index.html dan
     web/index.html, og:image URL absolut ke og-image.png lokal.
  3. landing/og-image.png ada, 1200x630, >= 10 KB.
  4. Data asli repo tampil di landing: 5 judul quest demo + 3 akun demo
     + rating 4.8 + saldo Rp250.000 (bukan angka karangan).
  5. web/manifest.json + ikon 192/512 ada (syarat build web).

Exit 0 = lolos, 1 = ada pelanggaran (disebut satu-satu).
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LANDING = os.path.join(ROOT, "landing")
FAILURES = []


def fail(msg):
    FAILURES.append(msg)
    print(f"FAIL: {msg}")


def read(rel):
    with open(os.path.join(ROOT, rel), encoding="utf-8") as f:
        return f.read()


def check_p0():
    """Larangan P0 (ui-anti-slop.md §2) + orde-kedua yang relevan."""
    html = read("landing/index.html")
    css = read("landing/styles.css")
    js = read("landing/app.js") if os.path.exists(
        os.path.join(ROOT, "landing", "app.js")) else ""
    blob = html + css + js
    banned = [
        (r"linear-gradient\(\s*135deg,\s*#7C3AED", "gradient ungu hero"),
        (r"#7C3AED|#4F46E5|#06B6D4", "hex ungu/biru landing lama"),
        (r"bg-clip-text|background-clip:\s*text", "headline gradient"),
        (r"font-family:[^;]*\bInter\b", "font Inter"),
        (r"font-family:[^;]*\bRoboto\b", "font Roboto"),
        (r"Elevate your workflow|Unlock the power", "copy generik"),
        (r"10x faster|99\.9% uptime|50k\+ users", "statistik vanity"),
        (r"rounded-2xl shadow-lg|border-radius:\s*16px;\s*\n\s*box-shadow",
         "rounded-2xl shadow-lg di semua permukaan"),
    ]
    for pat, label in banned:
        if re.search(pat, blob):
            fail(f"P0: {label} masih ada di landing/")
    # Emoji mentah sebagai ikon fungsi (bukan di dalam teks biasa).
    for emoji in ("🚀", "🔥", "💡", "📊", "🎯", "🛠️", "🔍", "🛡️"):
        if emoji in blob:
            fail(f"P0: emoji {emoji} dipakai di landing/ (pakai SVG)")
    # Footer 4 kolom default.
    if html.count("<footer") and len(re.findall(r"footer-col", html)) >= 4:
        fail("P0: footer 4 kolom default")


def check_og(path, base_url):
    html = read(path)
    required = [
        "og:title", "og:description", "og:type", "og:url", "og:image",
        "twitter:card", "twitter:title", "twitter:description",
        "twitter:image",
    ]
    for tag in required:
        pat = (r'property="%s"\s+content="([^"]+)"' % tag
               if tag.startswith("og:")
               else r'name="%s"\s+content="([^"]+)"' % tag)
        m = re.search(pat, html)
        if not m:
            fail(f"OG: {tag} hilang di {path}")
            continue
        val = m.group(1)
        if tag == "og:url" and val != base_url:
            fail(f"OG: og:url {path} = {val}, harus {base_url}")
        if tag == "og:image" and val != base_url + "og-image.png":
            fail(f"OG: og:image {path} = {val}, harus {base_url}og-image.png")
        if tag == "twitter:card" and val != "summary_large_image":
            fail(f"OG: twitter:card {path} = {val}")
        if tag == "twitter:image" and val != base_url + "og-image.png":
            fail(f"OG: twitter:image {path} = {val}")
    if 'content="1200"' not in html or 'content="630"' not in html:
        fail(f"OG: dimensi og:image 1200x630 tidak dinyatakan di {path}")


def check_og_image():
    from PIL import Image
    p = os.path.join(LANDING, "og-image.png")
    if not os.path.exists(p):
        fail("OG: landing/og-image.png hilang")
        return
    size = os.path.getsize(p)
    if size < 10240:
        fail(f"OG: og-image.png {size} byte < 10 KB")
    with Image.open(p) as im:
        if im.size != (1200, 630):
            fail(f"OG: og-image.png {im.size}, harus (1200, 630)")
    print(f"OK: og-image.png {size} byte, 1200x630")


def check_real_data():
    html = read("landing/index.html")
    quests = [
        "Buat Desain UI Mobile App",
        "Bantu Kerjain Laporan Penelitian",
        "Edit Video Presentasi Tugas Akhir",
        "Coding Tugas OOP Java",
        "Translasi Jurnal Bahasa Inggris",
    ]
    for q in quests:
        if q not in html:
            fail(f"DATA: judul quest demo {q!r} tidak tampil di landing")
    for acc in ("expert@demo.com", "seeker@demo.com", "admin@demo.com"):
        if acc not in html:
            fail(f"DATA: akun demo {acc} tidak tampil di landing")
    for token in ("4.8", "250.000", "Rp30.000", "Rp300.000"):
        if token not in html:
            fail(f"DATA: angka asli {token} tidak tampil di landing")


def check_web_manifest():
    for rel in ("web/manifest.json", "web/favicon.png",
                "web/icons/Icon-192.png", "web/icons/Icon-512.png",
                "web/icons/Icon-maskable-512.png", "web/index.html"):
        if not os.path.exists(os.path.join(ROOT, rel)):
            fail(f"WEB: {rel} hilang (syarat flutter build web)")


def main():
    check_p0()
    check_og("landing/index.html", "https://cariquest.pages.dev/")
    check_og("web/index.html", "https://cariquest.pages.dev/")
    check_og_image()
    check_real_data()
    check_web_manifest()
    if FAILURES:
        print(f"\n{len(FAILURES)} pelanggaran — gate GAGAL.")
        return 1
    print("\nOK: gate statis lolos (P0 + OG + data asli + web scaffold).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
