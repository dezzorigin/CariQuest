# CariQuest — Cara Pakai

## 1. Prasyarat

- Flutter SDK 3.x (channel stable) + Dart ≥3.3.4.
- Untuk Android: Android SDK. Untuk web: Chrome.
- **Tidak butuh** Firebase, API key, server, atau akun apa pun.

## 2. Jalankan

```bash
git clone https://github.com/dezzorigin/cariquest.git
cd cariquest
flutter pub get

flutter run            # pilih perangkat (Android / Chrome web)
flutter run -d chrome  # langsung ke web
```

Build rilis:

```bash
flutter build apk --release   # Android
flutter build web --release   # web → build/web (lihat docs/DEPLOYMENT.md)
flutter analyze               # linter
flutter test                  # 47 tes
```

## 3. Masuk (akun demo)

Semua akun memakai kata sandi **`demo123`**. Di layar login ada kartu
"Demo Credentials" — ketuk salah satu baris untuk isi otomatis.

| Peran | Email | Yang bisa dicoba |
|---|---|---|
| Expert | `expert@demo.com` | Lihat feed quest → bid "Buat Desain UI Mobile App" → cek dompet (saldo Rp250.000) → lihat peringkat Skilled Worker |
| Seeker | `seeker@demo.com` | Pasang quest baru → lihat pelamar → lacak quest "Bantu Kerjain Laporan Penelitian" (Working, urgent) |
| Admin | `admin@demo.com` | Dashboard → verifikasi pengguna → transaksi → mediasi sengketa |

## 4. Tur singkat (5 menit, sebagai Seeker)

1. Login sebagai Seeker (`seeker@demo.com` / `demo123`).
2. Dashboard menampilkan quest-mu: 1 pending, 1 working, 1 review,
   1 finished, 1 pending lagi.
3. Buka quest "Bantu Kerjain Laporan Penelitian" — status Working,
   harga final Rp75.000, tenggat 1 hari (urgent).
4. Buka quest "Edit Video Presentasi Tugas Akhir" — status Review
   (hasil sudah dikirim 1 jam lalu).
5. Buka quest "Coding Tugas OOP Java" — status Finished (selesai
   1 hari lalu, Rp100.000).
6. Pasang quest baru dari tombol pasang — quest muncul paling atas
   feed Expert (masuk akal: `MockData.addQuest` menyisipkan di depan).

Sebagai Expert, feed menampilkan quest pending ("Buat Desain UI Mobile
App" Rp150–300 rb dan "Translasi Jurnal Bahasa Inggris" Rp30–60 rb)
yang bisa di-bid.

## 5. Reset data demo

Tutup aplikasi dan jalankan lagi — `MockData.initDemoData()` mengisi
ulang 3 pengguna + 5 quest dari nol. Tidak ada yang tersimpan kecuali
sesi login (di `shared_preferences`; logout untuk membersihkannya).

## 6. Landing etalase

Tidak mau menjalankan Flutter? Buka https://cariquest.pages.dev/ —
papan quest, alur, peran, dan akun demo yang sama, sebagai halaman
statis. Sumbernya di `landing/` (HTML+CSS+JS, tanpa framework).
