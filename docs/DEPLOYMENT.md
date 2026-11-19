# CariQuest — Deployment

## 1. Yang live sekarang

| Artefak | URL | Isi |
|---|---|---|
| Landing etalase (statis) | https://cariquest.pages.dev/ | `landing/` — papan quest, alur, peran, akun demo |
| OG image | https://cariquest.pages.dev/og-image.png | Kartu 1200×630 (PIL, bukan screenshot) |
| Repo | https://github.com/dezzorigin/cariquest | Flutter app + docs + CI |

Nama Pages pilihan pertama: **`cariquest`**. Fallback bila dipakai akun
lain: `cari-quest`, lalu `quest-cari`.

## 2. Cara deploy (Cloudflare Pages, direct upload)

Deploy memakai `~/workspace/github-actions/cf_pages.py` (token API
Cloudflare via vault — jangan pernah tempel token di chat/repo):

```bash
python3 ~/workspace/github-actions/cf_pages.py create-project cariquest
python3 ~/workspace/github-actions/cf_pages.py deploy cariquest ~/workspace/cariquest/landing
```

Deploy mengunggah isi `landing/` (index.html, styles.css, app.js,
favicon.svg, og-image.png). Verifikasi sesudah deploy (pakai
`python urllib` + User-Agent browser — UA default Python kena 403
Cloudflare):

- root `200` + marker `Tugas kampusmu` / `CariQuest`,
- semua tag `og:*` + `twitter:*` ada,
- `og-image.png` `200` dengan `Content-Type: image/*` (bukan
  `text/html` — fallback Pages menipu).

## 3. Kenapa yang live baru landing (jujur)

`flutter build web` **hijau di CI** dan artifact `flutter-web`
(`build/web`) terunggah — tapi unduhan artifact dari VM mentok
approval host storage, jadi `build/web` tidak bisa dipindah ke
`cf_pages.py` dari sini. Yang di-deploy adalah landing statis, dan
landing menulis jujur bahwa aplikasi Flutter-nya adalah mock MVP
dengan akun demo (bukan mengklaim app web sudah live).

Langkah lanjut (follow-up, lihat `docs/TESTING.md`): unduh artifact
`flutter-web` dari browser / jalankan deploy dari mesin yang bisa
mengunduh artifact, play-test login demo di web, lalu deploy
`build/web` (dengan `landing/index.html` sebagai halaman pembuka yang
menautkan ke `/app/` — atau ganti root dengan build web).

## 4. CI

`.github/workflows/ci.yml` — 8 job (lihat header file): flutter-analyze,
flutter-test, flutter-build-web, advisory-sweep (OSV Pub),
gitleaks, static-checks, playwright-e2e, smoke. Semua harus hijau
sebelum merge.

## 5. Homepage repo

Setelah Pages live, set `homepage` repo ke
`https://cariquest.pages.dev/` (PATCH via `gh_set_homepage.py`).
