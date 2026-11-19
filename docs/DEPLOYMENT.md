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
dengan akun demo (bukan mengklaim app web sudah live). Landing
**sengaja dipertahankan** sampai app menggantikannya — CI (`smoke`,
`playwright-e2e`, `static-checks`) menguji `landing/`, jadi jangan
hapus folder itu sebelum deploy app.

### Follow-up deploy (dari browser / mesin lain)

Percobaan unduh artifact dari VM: **GAGAL** — `GET
/actions/artifacts/14525255007/zip` timeout saat membaca redirect
blob storage (19 Nov 2026, pr rework #49). Jangan diulang dari VM.

1. Di browser/mesin lain, buka run CI main
   `44513825297` (commit `f4c18c70`) → Artifacts → unduh
   **`flutter-web`** (14,7 MB, `sha256:4bc28bad…2ec`, kedaluwarsa
   17 Feb 2027) → unzip ke satu folder, mis. `~/flutter-web/`.
2. Deploy folder itu ke Pages project **`cariquest`**:
   ```bash
   python3 ~/workspace/github-actions/cf_pages.py deploy cariquest ~/flutter-web
   ```
3. Verifikasi (pakai `python urllib` + User-Agent browser — UA
   default Python kena 403 Cloudflare):
   - root `200` + marker `Tugas kampusmu` dan
     `Buat Desain UI Mobile App` (halaman app, bukan landing),
   - `og-image.png` `200` `image/png` (ikut `build/web` karena
     `web/og-image.png` sudah ada di repo sejak PR #2),
   - login demo `expert@demo.com` / `demo123` masuk ke dashboard,
     dan tombol **Kirim Hasil Kerja** membuka layar submit
     (bukan langsung submit URL palsu).
4. Setelah app live, `landing/` boleh dihapus dari repo (dan
   `smoke`/`playwright-e2e` dialihkan ke app) — **bukan sebelum itu**.

## 4. CI

`.github/workflows/ci.yml` — 8 job (lihat header file): flutter-analyze,
flutter-test, flutter-build-web, advisory-sweep (OSV Pub),
gitleaks, static-checks, playwright-e2e, smoke. Semua harus hijau
sebelum merge.

## 5. Homepage repo

Setelah Pages live, set `homepage` repo ke
`https://cariquest.pages.dev/` (PATCH via `gh_set_homepage.py`).
