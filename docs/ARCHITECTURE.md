# CariQuest — Arsitektur

> Lihat juga `architecture.html` (diagram visual: lapisan + lifecycle).
> Stack: Flutter 3.x · Riverpod 2.x · go_router 13.x · mock in-memory.

## 1. Peta lapisan

```
┌─────────────────────────────────────────────────────────────┐
│ Layar (features/*/screens)                                   │
│  auth · quest · expert · seeker · wallet · admin · chat ·    │
│  rating · notification · dispute · payment · profile         │
├─────────────────────────────────────────────────────────────┤
│ Widget bersama (shared/widgets)                              │
│  QuestCard · StatusChip · CustomButton · RankBadge ·          │
│  UserAvatar · ReportDialog                                    │
├─────────────────────────────────────────────────────────────┤
│ Provider / Controller (Riverpod StateNotifier)               │
│  auth_controller · quest_controller · bid_controller ·        │
│  wallet_controller · payment_controller · chat_controller ·   │
│  dispute_controller · profile_controller                      │
├─────────────────────────────────────────────────────────────┤
│ Repository (kontrak data — hari ini semuanya mock)           │
│  auth_repository · quest_repository · bid_repository ·        │
│  wallet_repository · payment_repository · chat_repository ·   │
│  rating_repository · notification_repository ·                │
│  dispute_repository · profile_repository                      │
├─────────────────────────────────────────────────────────────┤
│ Mesin data (core/mock/mock_data.dart) — MockData singleton    │
│  List<UserModel> · List<ProfileModel> · List<QuestModel> ·    │
│  List<BidModel> · List<NotificationModel> · List<Withdrawal>  │
│  + StreamController.broadcast per koleksi (usersStream,       │
│  questsStream, profilesStream, notificationsStream)           │
├─────────────────────────────────────────────────────────────┤
│ Model (shared/models, Equatable)                             │
│  UserModel · ProfileModel · QuestModel · BidModel ·           │
│  ChatModel · TransactionModel · ReviewModel · DisputeModel ·  │
│  NotificationModel · WithdrawalModel · BoostModel             │
└─────────────────────────────────────────────────────────────┘
  Fondasi (core/): constants (warna, string, enum) ·
  theme (AppTheme, AppTypography) · errors (Failure) ·
  l10n (app_strings, language_provider) · utils
```

## 2. Alur data (satu contoh: Seeker memasang quest)

1. `SeekerPostQuestScreen` memanggil `questControllerProvider.notifier`.
2. Controller memanggil `QuestRepository.addQuest(...)`.
3. Repository memanggil `MockData.instance.addQuest(q)` — quest masuk
   ke `List<QuestModel>` paling depan, lalu `emitQuests()` mengirim
   daftar baru lewat `questsStream`.
4. Semua layar yang menonton `questsStream` (feed Expert, dashboard
   Seeker, dashboard Admin) me-rebuild otomatis.
5. `AuthRepository` menyimpan sesi login di `shared_preferences`
   (satu-satunya penyimpanan yang bertahan antar restart).

Tidak ada HTTP, tidak ada database. "Real-time" di sini = stream
in-memory.

## 3. Routing (go_router)

`lib/shared/routes/app_router.dart` — satu `GoRouter` lewat
`appRouterProvider`. Rute: splash → onboarding → login / register
(role, expert, seeker) → pending-verification / suspended / OTP →
shell per peran:

- `/admin/*` — dashboard, users, verification, transactions, mediation,
  disputes.
- `/expert/*` — dashboard, quest-feed, orders, notifications, profile.
- `/seeker/*` — dashboard, post-quest, find-expert, applicants, orders,
  history (quest + transaksi), settings, ganti password.

`main.dart` memakai `usePathUrlStrategy()` (URL web bersih) dan
mengunci orientasi portrait + membatasi skala teks 0.8–1.2.

## 4. Lifecycle quest (state machine)

Satu-satunya state machine yang penting. Status adalah `QuestStatus`
(`app_enums.dart`): `pending, paid, working, review, finished,
disputed, cancelled`. Transisi legal:

```
pending ──(bayar)──▶ paid ──(mulai)──▶ working ──(kirim hasil)──▶ review
   │                                                              │
   └─(batal)──▶ cancelled                        (setuju)──▶ finished
                                                  │
                                        (banding)──▶ disputed
                                              (mediasi)──▶ finished / refund
```

`QuestModel.copyWith()` adalah satu-satunya cara berpindah status;
`toMap()`/`fromMap()` menjaga bentuk yang sama dengan dokumen
Firestore lama (field `status` disimpan sebagai `status.name`).

## 5. Tema (kontrak desain)

`AppColors` (Rimba `#1B4332`, Daun `#2D6A4F`, Emas `#E9C46A`, Kertas
`#FDFBF5`, Tinta `#1C2B21`, Bata `#BC4749`) + `AppTypography`
(Fraunces display/headline, Plus Jakarta Sans body) + `AppTheme`
(Material 3, radius kartu/dialog 14px). Nama lama (`primary`, `gold`,
…) dipertahankan sebagai alias supaya 200+ pemakaian lama tetap
kompilasi. Detail kontrak: `docs/DESIGN.md`.

## 6. Struktur folder

```
cariquest/
├── lib/
│   ├── main.dart                 # entry: ProviderScope + router
│   ├── core/                     # constants, theme, mock, errors, l10n
│   ├── features/                 # modul per fitur (auth, quest, …)
│   ├── shared/                   # models, routes, widgets, utils
│   └── auth/                     # (duplikat lama: auth_controller)
├── test/                         # 36 tes (lihat docs/TESTING.md)
├── web/                          # scaffold Flutter web (baru, PR #49)
├── landing/                      # etalase statis (yang di-deploy)
├── docs/                         # PRD → arsitektur → pakai → tes → deploy
├── scripts/                      # make-og-image, advisory-sweep, check-static
├── e2e/                          # Playwright landing (desktop + Pixel 7)
├── android/ ios/                 # platform (tidak diubah PR ini)
└── assets/                       # fonts Plus Jakarta Sans, images, icons
```

Catatan: `lib/auth/` dan `lib/features/auth/` sama-sama berisi
`auth_controller.dart` (duplikat historis); `lib/features/profile/`
juga punya widget duplikat di `screens/widgets/` dan `widgets/`.
Keduanya **tidak** dibersihkan di PR ini — penghapusan massal berisiko
memutus import; dicatat sebagai utang di §7.

## 7. Utang teknis yang dicatat (bukan dikerjakan diam-diam)

- Duplikat `app_CariQuest/` (salinan utuh aplikasi) dan
  `CariQuest-showcase/index.html` (landing ungu-gradient lama) —
  **dihapus di PR ini** via push tree (bukan sekadar dipindah).
- **Flutter 3.50 mendeprekasi `package:flutter/material.dart`**
  (→ `package:material_ui`). Migrasi belum layak (dua pohon Material;
  plugin masih memakai library lama) — `deprecated_member_use: ignore`
  di `analysis_options.yaml` dengan alasan tertulis. Deprekasi lain
  (mis. `withOpacity` → `withValues`) diperbaiki ke API baru.
- `pubspec.lock` belum memuat `flutter_web_plugins` (baru dideklarasi
  di PR ini) — `flutter pub get` berikutnya akan memperbarui lock;
  tidak bisa dibuat dari VM tanpa Flutter SDK.
- Duplikat controller/widget di dalam `lib/` (`lib/auth/` vs
  `lib/features/auth/`, widget profil di dua tempat) — dibiarkan,
  perlu PR susulan; penghapusan massal berisiko memutus import.
- File `flutter` di root (berkas kosong dari bundle lama) ikut terhapus
  di PR ini; bukan direktori.
- `android/app/build.gradle` masih memuat plugin `google-services`
  padahal `google-services.json` tidak ada di repo (sengaja, karena
  mock) — build Android akan gagal sampai plugin itu dicabut atau
  file-nya disediakan; build **web** (target PR ini) tidak terpengaruh.
