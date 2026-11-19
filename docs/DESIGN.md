# CariQuest — Kontrak Arah Desain (DESIGN.md)

> Ditulis SEBELUM coding UI (19 Nov 2026, repo P1 #49). Mengikat landing
> statis (`landing/`) DAN tema aplikasi Flutter (`lib/core/theme/` +
> `lib/core/constants/app_colors.dart`).

## Referensi (tour dulu, baru bangun)

| # | Referensi | URL | Yang dipinjam |
|---|---|---|---|
| 1 — PEMENANG | **QuestDex** (Laitent Space) | https://laitentspace.com/work/questdex | Struktur "satu deck, satu tracker, satu petualang": hero = satu quest unggulan di atas, daftar quest di bawah, empat ruangan (deck / tracker / katalog / statistik). Chrome hangat, konten yang membawa nada. |
| 2 | **Quest Board** (Weidengeist) | https://weidengeist.itch.io/questboard | Metafora papan pengumuman: tugas = quest yang ditempel di papan, selesai = dapat XP. |
| 3 | **QuestBoard** — Kids Tasks & Rewards | https://questboard.nikba.app/ | Loop produk yang bisa dipegang anak 6 tahun: pasang quest → kerjakan → setujui → hadiah. CariQuest memakai loop yang sama untuk dewasa: pasang quest → bid → kerjakan → review → bayar. |

Yang diubah dari pemenang: QuestDex adalah katalog tantangan harian untuk
satu pemain; CariQuest adalah **pasar dua sisi** (Seeker memasang quest,
Expert menawar), jadi deck-nya berisi quest **asli dari data demo repo**
(dengan anggaran Rp sungguhan), tracker-nya adalah lifecycle
Pending → Working → Review → Finished, dan "petualang"-nya adalah profil
Expert berperingkat (Newcomer → Legendary).

## Palet — 6 warna bernama (tiap warna punya tugas)

Dunia: **rimba pinus + papan pengumuman kampus**. Quest = masuk rimba,
cari jejak, pulang bawa emas. Bukan ungu/biru, bukan krim-terracotta,
bukan near-black + lime, bukan dark blue/slate.

| Nama | Hex | Peran |
|---|---|---|
| **Rimba** | `#1B4332` | Primer: header, CTA utama, nav aktif, harga lunas. |
| **Daun** | `#2D6A4F` | Sekunder: status jalan/terbayar, aksen daun. |
| **Emas** | `#E9C46A` | Hadiah: anggaran quest, chip harga, peringkat, stempel. |
| **Kertas** | `#FDFBF5` | Latar: kertas papan pengumuman. |
| **Tinta** | `#1C2B21` | Teks utama (hijau-hitam, bukan hitam netral). |
| **Bata** | `#BC4749` | HANYA sengketa / urgent / error. |

Abu-abu pendukung mengikuti rumpun hijau yang sama (bukan abu netral).
Emas gelap `#9A7B1E` dipakai untuk teks harga di atas kertas (kontras AA);
emas terang hanya untuk bidang besar.

## Tipografi — 2 keluarga

- **Display: Fraunces** (serif berkarakter) — judul besar, nama quest
  unggulan, angka hero. Dipakai di landing DAN `AppTypography` Flutter
  (display + headline).
- **Body/data: Plus Jakarta Sans** — semua teks isi, label, dan angka
  tabular (harga Rp, XP, rating). Sudah dibundel di `assets/fonts/`.

## Layout — satu kalimat

> Papan pengumuman kampus dua kolom: kiri narasi + alur loop 4 langkah,
> kanan tumpukan kartu quest demo asli dengan tepi tiket berlubang.

- Desktop: grid 2 kolom (narasi 5 / papan quest 7), header ramping dengan
  marka kompas, footer satu baris (bukan 4 kolom).
- Mobile 390px: satu kolom, papan quest dulu setelah hero singkat,
  target sentuh min 44px, tanpa scroll horizontal.
- Satu aksi utama per viewport: **"Buka Aplikasi"** (ke build web) /
  **"Coba Akun Demo"** (isi kredensial demo). Maks 3 sekunder.

## Detail khas (signature detail)

1. **Tepi tiket berlubang** — tiap kartu quest punya garis perforasi
   (deret titik) + dua coakan setengah lingkaran di sisi kiri/kanan,
   seperti karcis yang bisa disobek. Di Flutter: strip aksen Emas 4px
   + pemisah putus-putus pada `QuestCard`.
2. **Marka kompas** — SVG mawar kompas 8 arah garis tipis (stroke 1.5px)
   sebagai logo, bukan emoji. Arah jarum menunjuk "utara quest".

## Larangan (P0 + orde-kedua) — nol toleransi

- Tanpa gradient ungu/biru di hero/background; tanpa headline gradient.
- Tanpa font Inter/Roboto/system untuk semuanya.
- Tanpa hero tengah + 3 kartu identik; tanpa grid 3 kartu simetris template.
- Tanpa emoji mentah sebagai ikon fungsi — SVG satu bobot, stroke 1.5–2px.
- Tanpa statistik vanity palsu — semua angka di landing adalah data asli
  repo demo (5 quest, 3 akun demo, Rp30rb–300rb, rating 4.8, 12 quest
  selesai) dan dilabeli "data demo".
- Tanpa `rounded-2xl shadow-lg` di semua permukaan; radius kontrak: kartu
  14px, chip 10px, tombol 14px, dialog 14px.
- Tanpa copy generik ("Unlock the power…") — copy berbahasa Indonesia
  kampus USK, konkret.

## Perbedaan dari repo sebelumnya (#47 monitor-kuliah-dezz)

#47: Kertas Arsip `#F2F0E6` + Tinta + Merah Cap + Biru Garis, Special Elite
+ Libre Franklin, satu kolom linimasa, radius 0, detail jilid ledger.
CariQuest beda di **5 dari 5 sumbu**: palet (Rimba/Emas vs arsip
merah-biru), tipografi (Fraunces + Plus Jakarta Sans vs Special Elite +
Libre Franklin), layout (papan dua kolom vs linimasa satu kolom),
radius/spacing (14px vs 0), detail khas (tiket berlubang + kompas vs
jilid ledger).

## Gate 7 sumbu (target, nilai 1–5, minimal 4 tiap sumbu)

1. anti-slop purity — 2. UX speed & 1-to-3 — 3. tipografi — 4. spacing &
   geometri (grid 4/8pt, radius dalam = luar − padding, padding kartu
   ≥16px) — 5. motion (<200ms ease-out, aksi 100x/hari = 0ms, active
   scale 0.97) — 6. a11y (focus ring, aria-label, tag semantik) —
   7. mobile (stack rapi, tanpa scroll horizontal). Skor akhir di laporan PR.
