# CariQuest — PRD (Product Requirements Document)

> Versi 1.0-proper · 19 Nov 2026 · repo P1 #49.
> Dokumen ini mendeskripsikan aplikasi **sebagaimana adanya di repo** —
> bukan rencana masa depan. Kalau ada yang belum jalan, tertulis di
> §7 (Batasan jujur).

## 1. Masalah

Mahasiswa Universitas Syiah Kuala (USK) punya dua kebutuhan yang tidak
saling menemukan:

- **Seeker** — mahasiswa yang butuh bantuan tugas/proyek (desain UI,
  olah data SPSS, coding, terjemah jurnal) tapi tidak tahu siapa di
  kampus yang bisa mengerjakannya dengan harga yang jelas.
- **Expert** — mahasiswa yang punya skill (Flutter, Figma, SPSS, Java)
  tapi tidak punya etalase dan jalur order yang rapi di dalam kampus.

Akibatnya: order lewat chat personal, harga dinego tanpa patokan,
pembayaran di depan tanpa jaminan, dan tidak ada rekam jejak.

## 2. Produk

**CariQuest** — marketplace talenta kampus berbasis Flutter. Satu papan
quest, tiga peran:

| Peran | Yang bisa dilakukan |
|---|---|
| **Seeker** | Pasang quest (judul, jobdesk, tenggat, rentang anggaran) · pilih Expert dari daftar penawar · lacak progres · review hasil + beri rating · bayar lewat escrow |
| **Expert** | Profil + portofolio + skill tag · bid di feed quest · terima order · kirim hasil · peringkat naik (Newcomer → Legendary) · tarik saldo ke bank/e-wallet |
| **Admin** | Verifikasi pengguna (KTM/KTP) · pantau semua transaksi · mediasi sengketa · pantau pengguna |

## 3. Lifecycle quest (satu-satunya alur yang penting)

```
Pending → Paid → Working → Review → Finished
   │         │        │         │
   └──── Cancelled   └──── Disputed (mediasi Admin) ──→ Finished / Refund
```

- **Pending** — quest dipasang, menunggu penawar ("Mencari Expert").
- **Paid** — Seeker memilih Expert dan membayar; dana **dikunci di escrow**,
  bukan langsung ke Expert.
- **Working** — Expert mengerjakan; Seeker memantau.
- **Review** — hasil dikirim; Seeker memeriksa, bisa minta revisi.
- **Finished** — Seeker menyetujui; dana cair ke dompet Expert; rating diberikan.
- **Disputed** — salah satu pihak membuka banding; Admin memediasi.
- **Cancelled** — dibatalkan sebelum/selama proses.

Aturan uang: Expert hanya dibayar setelah Seeker menyetujui hasil.
Itulah satu janji produk ini.

## 4. Fitur per modul

- **Auth** — login, daftar per peran (Expert/Seeker), verifikasi
  menunggu (pending verification), akun ditangguhkan (suspended),
  OTP (alur tersedia di router).
- **Quest** — feed quest Expert, detail quest, bid + negosiasi harga,
  kirim hasil, lacak progres.
- **Profil Expert** — hero banner, kartu peringkat (rank), portofolio,
  riwayat, "direct quest" (pesan quest langsung ke Expert tertentu).
- **Wallet** — saldo aktif/pending, tarik dana (BRI/BCA/Mandiri/
  GoPay/OVO/DANA/ShopeePay), riwayat transaksi.
- **Chat** — chat Seeker–Expert per quest.
- **Rating** — rating + ulasan setelah quest selesai.
- **Notifikasi** — notifikasi status quest, pembayaran, peringkat naik.
- **Admin** — dashboard, verifikasi pengguna, mediasi sengketa,
  transaksi, daftar pengguna.

## 5. Data demo (satu-satunya data yang ada)

Aplikasi ini **mock MVP offline 100%**: tidak ada Firebase, tidak ada
server. Seluruh data hidup di memori (`MockData`) selama aplikasi jalan
dan direset tiap restart.

| Akun demo | Email | Peran | Fakta demo |
|---|---|---|---|
| Aldi Firmansyah | `expert@demo.com` | Expert | Informatika, MIPA; 12 quest selesai; rating 4.8 (15 ulasan); saldo Rp250.000; skill Flutter, UI/UX, Figma, Dart |
| Bunga Pratiwi | `seeker@demo.com` | Seeker | Mahasiswa Manajemen |
| System Admin | `admin@demo.com` | Admin | — |

Kata sandi semua akun demo: `demo123`. Lima quest demo (anggaran
Rp30.000–Rp300.000): "Buat Desain UI Mobile App" (Rp150–300 rb),
"Bantu Kerjain Laporan Penelitian" (Rp75 rb, urgent), "Edit Video
Presentasi Tugas Akhir" (Rp100 rb), "Coding Tugas OOP Java" (Rp100 rb),
"Translasi Jurnal Bahasa Inggris" (Rp30–60 rb).

## 6. Teknologi

Flutter 3.x (Dart ≥3.3.4) · Riverpod 2.x (`StateNotifier` +
`StreamProvider`) · go_router 13.x · `shared_preferences` (sesi login
lokal) · Material 3 · `google_fonts` (Fraunces + Plus Jakarta Sans) ·
`flutter_animate`, `lottie`, `shimmer` · `intl`, `uuid`, `timeago`,
`equatable`, `image_picker`, `url_launcher`.

## 7. Batasan jujur (yang belum ada)

- **Bukan produksi.** Tidak ada backend, tidak ada pembayaran sungguhan
  (QRIS/bank/VA hanya pilihan di UI), tidak ada data yang bertahan
  setelah aplikasi ditutup.
- **Belum ada screenshot/video demo asli** dari aplikasi berjalan
  (butuh browser live — lihat `docs/TESTING.md` § follow-up).
- **Build web Flutter** (CI) belum di-deploy ke Pages — yang live adalah
  landing etalase statis + tautan ke repo (lihat `docs/DEPLOYMENT.md`).
- Akun demo memakai kata sandi yang sama (`demo123`) — sengaja, karena
  ini demo offline tanpa data sungguhan.

## 8. Kriteria selesai (definisi "proper" repo ini)

README standar + LICENSE MIT + CI hijau (analyze, test, build web,
sweep OSV Pub, gitleaks, gate statis, e2e landing) + docs lengkap +
landing live di Cloudflare Pages + PR merge setelah verifikasi live.
