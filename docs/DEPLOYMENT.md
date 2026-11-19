# CariQuest — Deployment

## 1. Yang live sekarang

| Artefak | URL | Isi |
|---|---|---|
| **Aplikasi Flutter (web)** | https://cariquest.pages.dev/ | `build/web` dari CI (lihat §3) — login demo, papan quest, submit kerja |
| OG image | https://cariquest.pages.dev/og-image.png | Kartu 1200×630 (PIL, bukan screenshot) — ikut `build/web` via `web/og-image.png` |
| Repo | https://github.com/dezzorigin/cariquest | Flutter app + docs + CI |
| Etalase statis (cadangan, tidak di-deploy) | — | `landing/` di repo — papan quest, alur, peran, akun demo |

Nama Pages pilihan pertama: **`cariquest`**. Fallback bila dipakai akun
lain: `cari-quest`, lalu `quest-cari`.

## 2. Cara deploy (Cloudflare Pages, direct upload)

Deploy memakai `~/workspace/github-actions/cf_pages.py` (token API
Cloudflare via vault — jangan pernah tempel token di chat/repo):

```bash
python3 ~/workspace/github-actions/cf_pages.py create-project cariquest
python3 ~/workspace/github-actions/cf_pages.py deploy cariquest <dir-build-web-hasil-unzip>
```

Deploy mengunggah isi `build/web` (index.html, main.dart.js,
flutter_bootstrap.js, canvaskit/, og-image.png, …). Verifikasi
sesudah deploy (pakai `python urllib` + User-Agent browser — UA
default Python kena 403 Cloudflare):

- root `200` + shell Flutter (`flutter_bootstrap.js`,
  `Memuat papan quest`),
- semua tag `og:*` + `twitter:*` ada,
- `og-image.png` `200` dengan `Content-Type: image/*` (bukan
  `text/html` — fallback Pages menipu),
- string app di `main.dart.js`: `Buat Desain UI Mobile App`,
  `Kirim Hasil Kerja`.

## 3. Deploy app Flutter (SELESAI 19 Nov 2026)

Dulu unduhan artifact dari VM dianggap mentok (redirect blob storage
ditolak) — ternyata **ada jalannya** (temuan worker #50 dez-download,
terverifikasi di PR #2): ambil URL redirect 302 ke Azure Blob dari API
GitHub, lalu fetch URL SAS itu dengan request **polos tanpa header auth
surrogate** (header itulah yang ditolak Azure dengan 401). Jangan
pernah fetch URL SAS dengan header auth.

Deploy yang live sekarang:

- Run CI PR #2: **44520631712** (head `aca165fb`, CI 8/8 hijau).
- Artifact **`flutter-web`** id `14527877686`, 14.757.463 byte,
  `sha256:7dcf9fcd14b53e2ca805be022dca809eec6e8c775ee41a9dd08ef3869cd7d8e0`
  (dicocokkan persis sebelum deploy).
- Perintah: `cf_pages.py deploy cariquest <dir-hasil-unzip>` → 46 file,
  deployment **`04dd6127-fecc-482b-8ab1-c234aee51b6b`**, status success.
- Verifikasi live: root `200` + shell Flutter (`flutter_bootstrap.js`,
  `Memuat papan quest`); `og-image.png` `200 image/png` 69.750 byte;
  string app di `main.dart.js`: `Buat Desain UI Mobile App`,
  `expert@demo.com`, `Kirim Hasil Kerja`. Catatan: `Tugas kampusmu`
  HANYA ada di landing lama, bukan di app — jangan dipakai sebagai
  marker app.

Deploy ulang (setelah ada PR baru yang mengubah app): unduh artifact
`flutter-web` dari run CI main terbaru dengan pola 302→SAS polos di
atas, cocokkan sha256 dengan `digest` artifact, unzip, deploy dengan
perintah yang sama, lalu verifikasi seperti di atas. `landing/` tetap
di repo (CI `smoke`/`playwright-e2e`/`static-checks` mengujinya) tapi
tidak di-deploy; hapus hanya bila e2e dialihkan ke app.

## 4. CI

`.github/workflows/ci.yml` — 8 job (lihat header file): flutter-analyze,
flutter-test, flutter-build-web, advisory-sweep (OSV Pub),
gitleaks, static-checks, playwright-e2e, smoke. Semua harus hijau
sebelum merge.

## 5. Homepage repo

Setelah Pages live, set `homepage` repo ke
`https://cariquest.pages.dev/` (PATCH via `gh_set_homepage.py`).
