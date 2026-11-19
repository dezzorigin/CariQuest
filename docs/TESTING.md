# CariQuest — Testing

## 1. Ringkas

| Lapisan | Alat | Jumlah | Perintah |
|---|---|---|---|
| Unit model | `flutter test` | 7 | `QuestModel`: default, lifecycle `copyWith`, round-trip `toMap`/`fromMap` |
| Unit data demo | `flutter test` | 11 | `MockData`: 3 pengguna, 5 quest, status, anggaran, `addQuest`/`updateQuest` |
| Widget | `flutter test` | 9 | `StatusChip`: label tiap `QuestStatus` + label kustom + tanpa status |
| Tema | `flutter test` | 9 | Palet kontrak, 2 font, radius 14, tema gelap |
| Repository | `flutter test` | 6 | `QuestRepository`: submit/status/nego mempertahankan field, nego tersimpan |
| Stream replay | `flutter test` | 5 | `MockData`: subscribe telat langsung dapat snapshot + update live mengalir |
| **Total Flutter** | | **47** | `flutter test` |
| Analisis | `flutter analyze` | — | `flutter analyze` |
| E2E landing | Playwright | 7 | `npm run e2e` (desktop + Pixel 7, hanya CI) |
| Gate statis | Python | — | `python3 scripts/check-static.py` |
| Sweep vuln | OSV | 17 paket | `python3 scripts/advisory-sweep.py` |
| Secret-scan | gitleaks | — | job CI `gitleaks` (riwayat penuh) |

## 2. Yang dites — dan kenapa itu yang dites

- **`QuestModel`** adalah jantung produk: kalau lifecycle
  pending → paid → working → review → finished rusak, escrow tidak
  bisa dipercaya. Tes memastikan `copyWith` hanya mengubah field yang
  disebut, dan `toMap`/`fromMap` round-trip tanpa kehilangan field.
- **`MockData`** adalah satu-satunya "backend": kalau data demo kosong
  atau salah, seluruh aplikasi kosong. Tes mengunci angka demo
  (3 pengguna, 5 quest, rating 4.8, saldo Rp250.000, anggaran
  Rp30.000–Rp300.000) supaya perubahan data demo yang tidak sengaja
  langsung ketahuan.
- **`StatusChip`** adalah satu-satunya widget yang menampilkan status
  ke pengguna — labelnya adalah kontrak UX ("Mencari Expert", bukan
  "pending").
- **Tema** mengunci kontrak desain (palet Rimba/Emas, Fraunces +
  Plus Jakarta Sans, radius 14) supaya refactor warna tidak diam-diam
  mengembalikan ungu lama.
- **`QuestRepository`** mengunci perbaikan audit-fix PR #2: update
  status/submit/nego tidak boleh menghapus field lain (`copyWith`),
  dan `requestNego`/`acceptNego` benar-benar menulis ke quest
  (dulu keduanya no-op kosong).
- **Stream replay** mengunci perbaikan PR #4: keempat stream
  `MockData` snapshot-first — layar yang subscribe sesudah
  `initDemoData()` langsung dapat data (dulu terjebak loading
  selamanya; ketahuan live dari spinner "Quest Aktif").

Yang **tidak** dites: alur login end-to-end di dalam aplikasi (butuh
`ProviderScope` + router + `shared_preferences` — rapuh di tes unit;
ditutup oleh e2e landing untuk etalase dan play-test manual untuk app),
dan build Android (plugin `google-services` di `build.gradle` belum
dicabut — lihat `docs/ARCHITECTURE.md` §7).

## 3. Font di tes (google_fonts — jebakan yang sudah dilewati)

Tes tema memanggil `AppTypography` yang memakai `GoogleFonts.*`.
Di tes, `HttpClient` TestWidgetsFlutterBinding mengembalikan 400
untuk semua request jaringan, jadi fetch font runtime selalu gagal
*sesudah* tes selesai (`failed after test completion`).

Solusi (pola dokumen google_fonts):

- `test/app_theme_test.dart` mematikan fetch runtime:
  `GoogleFonts.config.allowRuntimeFetching = false;` di `main()`.
- Dengan fetching mati, google_fonts memuat font dari **asset app** —
  jadi `assets/fonts/` WAJIB dideklarasi di `pubspec.yaml` dan berisi
  file TTF asli dengan nama yang diharapkan google_fonts
  (`PlusJakartaSans-Regular.ttf`, `Fraunces-Bold.ttf`, dst).
- Nama family di assertion adalah nama internal google_fonts tanpa
  spasi: `contains('PlusJakartaSans')`, bukan `'Plus Jakarta Sans'`.

Temuan saat PR ini: kelima file `PlusJakartaSans-*.ttf` di repo
ternyata **halaman HTML error 1.636 byte** (bukan font) — hasil
unduhan gagal yang ter-commit. Diganti file TTF statis asli dari
Google Fonts (URL `fonts.gstatic.com/s/a/<sha256>.ttf` dari tabel
google_fonts 6.2.1; SHA256 + ukuran + name table diverifikasi), dan
ditambah 3 file Fraunces statis (Regular/SemiBold/Bold — repo
sebelumnya tidak punya file Fraunces sama sekali; display font
hanya jalan saat online). Di aplikasi, fetch runtime tetap aktif,
jadi file asset ini tidak mengubah rendering saat online — hanya
menjamin tes + mode offline.

## 4. E2E landing (Playwright, hanya CI)

`e2e/landing.spec.ts` (7 tes): judul + hero + fakta demo, tag OG/Twitter,
5 kartu quest + saring status (Selesai = 1 kartu), tabel 3 akun demo,
alur 4 langkah + peran, `og-image.png` 200 + `image/png` + ≥10 KB,
tanpa scroll horizontal. Berjalan di `http://127.0.0.1:8491`
(Python `http.server` di `landing/`), proyek desktop + **Pixel 7**
(Chromium — JANGAN iPhone, butuh WebKit).

Lokal (VM dev): Chromium tidak bisa start (sandbox EPERM) — e2e hanya
di CI. Menjalankan `npm run e2e` lokal akan gagal di langkah browser;
itu keterbatasan VM, bukan kegagalan tes.

## 5. Follow-up (bukan gate merge)

- [ ] **Screenshot isi aplikasi** (desktop + mobile) untuk README —
  butuh browser live / VM pulih; `flutter run -d chrome` + rekam layar.
- [ ] **Video demo** walkthrough HD ala rekam iOS: login demo →
  pasang quest → bid → lacak → review → dana cair (syarat Nabil:
  rapi, tajam, bisa zoom ke detail UI).
- [ ] **Play-test build web Flutter** dari artifact CI
  (`flutter-web`) di browser live — verifikasi login demo benar-benar
  jalan di web, bukan hanya `flutter build` hijau.
- [ ] Deploy build web Flutter ke Pages (ganti landing-only) setelah
  play-test di atas lolos.
