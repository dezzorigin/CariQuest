#!/usr/bin/env python3
"""Generate og-image.png + ikon web CariQuest (PIL, lokal, tanpa jaringan).

Palet mengikuti kontrak docs/DESIGN.md (Rimba/Daun/Emas/Kertas/Tinta/Bata).
Bukan screenshot asli — kartu desain editorial dari data demo repo:
5 quest demo, anggaran Rp30rb–300rb, rating expert 4.8.

Output:
  landing/og-image.png        1200x630 (>= 10 KB, dipakai tag og:image)
  web/og-image.png            salinan yang sama — WAJIB ada: build/web
                              Flutter hanya menyertakan isi web/, jadi
                              tanpa salinan ini og:image 404 saat app
                              di-deploy (tag menunjuk /og-image.png).
  web/favicon.png             64x64
  web/icons/Icon-192.png      192x192
  web/icons/Icon-512.png      512x512
  web/icons/Icon-maskable-512.png  512x512 (padding aman maskable)

Usage: python3 scripts/make-og-image.py   (dari root repo)
"""
import math
import os
import sys

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

RIMBA = (27, 67, 50)       # #1B4332
DAUN = (45, 106, 79)       # #2D6A4F
EMAS = (233, 196, 106)     # #E9C46A
EMAS_GELAP = (154, 123, 30)  # #9A7B1E
KERTAS = (253, 251, 245)   # #FDFBF5
TINTA = (28, 43, 33)       # #1C2B21
BATA = (188, 71, 73)       # #BC4749
KABUT = (91, 107, 94)      # #5B6B5E
GARIS = (231, 234, 229)    # #E7EAE5

SERIF_B = "/usr/share/fonts/truetype/dejavu/DejaVuSerif-Bold.ttf"
SERIF = "/usr/share/fonts/truetype/dejavu/DejaVuSerif.ttf"
SANS = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
SANS_B = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
MONO = "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf"
MONO_B = "/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf"


def compass(d, cx, cy, r, color, width=4):
    """Mawar kompas 8 arah garis tipis (detail khas DESIGN.md)."""
    d.ellipse([cx - r, cy - r, cx + r, cy + r], outline=color, width=width)
    for i in range(8):
        ang = math.radians(i * 45 - 90)
        length = r if i % 2 == 0 else r * 0.55
        x2 = cx + length * math.cos(ang)
        y2 = cy + length * math.sin(ang)
        d.line([cx, cy, x2, y2], fill=color, width=width)
    d.ellipse([cx - 5, cy - 5, cx + 5, cy + 5], fill=color)


def perforation(d, x0, x1, y, color, step=18, r=4):
    """Garis perforasi tiket: deret titik (detail khas DESIGN.md)."""
    x = x0
    while x <= x1:
        d.ellipse([x - r, y - r, x + r, y + r], fill=color)
        x += step


def make_og():
    W, H = 1200, 630
    img = Image.new("RGB", (W, H), KERTAS)
    d = ImageDraw.Draw(img)

    # Bidang Rimba kiri (marka) + garis emas
    d.rectangle([0, 0, 300, H], fill=RIMBA)
    d.rectangle([300, 0, 308, H], fill=EMAS)
    compass(d, 150, 150, 72, EMAS, width=5)
    f_mark = ImageFont.truetype(SERIF_B, 44)
    d.text((150, 236), "Q", font=f_mark, fill=EMAS, anchor="mt")

    f_kick = ImageFont.truetype(MONO_B, 22)
    d.text((48, 356), "USK", font=f_kick, fill=EMAS)
    d.text((48, 388), "BANDA ACEH", font=f_kick, fill=EMAS)
    d.text((48, 428), "MARKETPLACE", font=f_kick, fill=(214, 226, 214))
    d.text((48, 460), "TALENTA", font=f_kick, fill=(214, 226, 214))
    d.text((48, 492), "MAHASISWA", font=f_kick, fill=(214, 226, 214))
    d.text((48, 556), "cariquest.", font=ImageFont.truetype(MONO, 22),
           fill=(214, 226, 214))
    d.text((48, 584), "pages.dev", font=ImageFont.truetype(MONO, 22),
           fill=(214, 226, 214))

    # Judul kanan
    f_title = ImageFont.truetype(SERIF_B, 108)
    d.text((352, 84), "CariQuest", font=f_title, fill=TINTA)

    f_sub = ImageFont.truetype(SANS, 34)
    d.text((356, 216), "Seeker memasang quest.", font=f_sub, fill=TINTA)
    d.text((356, 262), "Expert menawar. Dana aman di escrow.", font=f_sub,
           fill=TINTA)

    # Perforasi + 3 kartu quest demo asli
    perforation(d, 352, 1128, 330, GARIS)
    f_chip_t = ImageFont.truetype(SANS_B, 23)
    f_chip_b = ImageFont.truetype(MONO, 20)
    quests = [
        ("Buat Desain UI Mobile App", "Rp 150–300 rb  ·  Dicari"),
        ("Bantu Laporan Penelitian", "Rp 75 rb  ·  Dikerjakan"),
        ("Coding Tugas OOP Java", "Rp 100 rb  ·  Selesai"),
    ]
    y = 356
    for title, meta in quests:
        d.rounded_rectangle([352, y, 1128, y + 58], radius=14,
                            outline=GARIS, width=2, fill=(255, 255, 255))
        d.rectangle([352, y + 8, 360, y + 50], fill=EMAS)
        # meta rata kanan dulu, judul dipotong agar tidak bertabrakan
        meta_w = d.textlength(meta, font=f_chip_b)
        max_title_w = 1104 - meta_w - 24 - 380
        shown = title
        while shown and d.textlength(shown + "…", font=f_chip_t) > max_title_w:
            shown = shown[:-1]
        if shown != title:
            shown += "…"
        d.text((380, y + 15), shown, font=f_chip_t, fill=TINTA)
        d.text((1104 - meta_w, y + 18), meta, font=f_chip_b, fill=KABUT)
        y += 74

    # Kaki: data demo jujur
    f_meta = ImageFont.truetype(MONO, 25)
    d.text((352, 586), "5 QUEST DEMO  ·  3 AKUN DEMO  ·  RATING EXPERT 4.8",
           font=f_meta, fill=KABUT)

    out = os.path.join(ROOT, "landing", "og-image.png")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    img.save(out, "PNG", optimize=True)
    print(f"saved {out} ({os.path.getsize(out)} bytes)")
    # Salinan untuk build web Flutter (lihat docstring): build/web hanya
    # berisi isi web/, jadi og-image harus ada di sana juga.
    web_out = os.path.join(ROOT, "web", "og-image.png")
    img.save(web_out, "PNG", optimize=True)
    print(f"saved {web_out} ({os.path.getsize(web_out)} bytes)")


def make_icon(size, out_path, maskable=False):
    pad = int(size * 0.12) if maskable else 0
    img = Image.new("RGB", (size, size), RIMBA)
    d = ImageDraw.Draw(img)
    if not maskable:
        # sudut membulat 14% (kontrak radius)
        mask = Image.new("L", (size, size), 0)
        md = ImageDraw.Draw(mask)
        md.rounded_rectangle([0, 0, size, size], radius=int(size * 0.14),
                             fill=255)
        img.putalpha(mask)
        img = img.convert("RGBA")
        bg = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        bg.paste(img, (0, 0), img)
        img = bg
        d = ImageDraw.Draw(img)
    cx = cy = size // 2
    r = size // 2 - pad - int(size * 0.10)
    compass(d, cx, cy - int(size * 0.06), r, EMAS,
            width=max(3, size // 64))
    f = ImageFont.truetype(SERIF_B, int(size * 0.34))
    d.text((cx, cy + int(size * 0.16)), "Q", font=f, fill=EMAS, anchor="mt")
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    img.save(out_path, "PNG", optimize=True)
    print(f"saved {out_path} ({os.path.getsize(out_path)} bytes)")


def main():
    make_og()
    make_icon(64, os.path.join(ROOT, "web", "favicon.png"))
    make_icon(192, os.path.join(ROOT, "web", "icons", "Icon-192.png"))
    make_icon(512, os.path.join(ROOT, "web", "icons", "Icon-512.png"))
    make_icon(512, os.path.join(ROOT, "web", "icons", "Icon-maskable-512.png"),
              maskable=True)


if __name__ == "__main__":
    sys.exit(main())
