// lib/core/constants/app_colors.dart

import 'package:flutter/material.dart';

/// CariQuest Brand Colors — "Rimba Pinus + Papan Pengumuman"
/// (kontrak: docs/DESIGN.md, 19 Nov 2026 — menggantikan ungu #6C2BD9).
///
/// Nama lama dipertahankan (primary, gold, …) supaya 200+ pemakaian lama
/// tetap kompilasi; nilainya dipetakan ke palet baru. Nama baru (rimba,
/// daun, emas, kertas, tinta, bata) adalah nama kanonik desain.
abstract class AppColors {
  // ─── Brand (kanonik) ────────────────────────────────────────────
  static const Color rimba = Color(0xFF1B4332); // primer
  static const Color daun = Color(0xFF2D6A4F); // sekunder
  static const Color emas = Color(0xFFE9C46A); // hadiah / harga
  static const Color kertas = Color(0xFFFDFBF5); // latar
  static const Color tinta = Color(0xFF1C2B21); // teks utama
  static const Color bata = Color(0xFFBC4749); // sengketa / urgent

  // ─── Brand (nama lama → palet baru) ─────────────────────────────
  static const Color primary = rimba;
  static const Color primaryLight = daun;
  static const Color primaryDark = Color(0xFF122E22);
  static const Color primaryContainer = Color(0xFFDCEADF);

  static const Color gold = emas;
  static const Color goldLight = Color(0xFFF4D58D);
  static const Color goldDark = Color(0xFF9A7B1E); // teks harga di kertas (AA)
  static const Color goldContainer = Color(0xFFFBF3D9);

  // ─── Semantic ───────────────────────────────────────────────────
  static const Color success = daun;
  static const Color successLight = Color(0xFFDCEADF);
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = bata;
  static const Color errorLight = Color(0xFFFBEAEA);
  static const Color info = Color(0xFF2A7F62);
  static const Color infoLight = Color(0xFFD8EFE3);

  // ─── Neutral (rumpun hijau, bukan abu netral) ───────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF0A0A0A);
  static const Color grey50 = Color(0xFFF8F8F4);
  static const Color grey100 = Color(0xFFF1F2EE);
  static const Color grey200 = Color(0xFFE7EAE5);
  static const Color grey300 = Color(0xFFD3DAD3);
  static const Color grey400 = Color(0xFF9AA79D);
  static const Color grey500 = Color(0xFF7A8A7D);
  static const Color grey600 = Color(0xFF5B6B5E);
  static const Color grey700 = Color(0xFF3D4A40);
  static const Color grey800 = Color(0xFF243528);
  static const Color grey900 = tinta;

  // ─── Background ─────────────────────────────────────────────────
  static const Color background = kertas;
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1EFE6);
  static const Color cardBg = Color(0xFFFFFFFF);

  // ─── Dark Mode ──────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF101B15);
  static const Color darkSurface = Color(0xFF1A2A21);
  static const Color darkCard = Color(0xFF223528);
  static const Color darkBorder = Color(0xFF2E4636);

  // ─── Rank Colors ────────────────────────────────────────────────
  static const Color rankBronze = Color(0xFFB0793F);
  static const Color rankSilver = Color(0xFFC0C0C0); // Skilled
  static const Color rankGold = emas; // Veteran
  static const Color rankPlatinum = Color(0xFFE5E4E2); // Legend
  static const Color rankMythic = bata; // Mythic

  // ─── Status Colors ──────────────────────────────────────────────
  static const Color statusPending = Color(0xFF9A7B1E);
  static const Color statusPaid = Color(0xFF2A7F62);
  static const Color statusWorking = rimba;
  static const Color statusReview = Color(0xFFA16207);
  static const Color statusFinished = daun;
  static const Color statusDisputed = bata;

  // ─── Gradients ──────────────────────────────────────────────────
  // Didefinisikan untuk kompatibilitas API; UI baru memakai bidang solid
  // (kontrak DESIGN.md: tanpa gradient hero/background).
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2D6A4F), Color(0xFF1B4332), Color(0xFF122E22)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF4D58D), Color(0xFFE9C46A), Color(0xFFC9A227)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B4332), Color(0xFF2D6A4F), Color(0xFFE9C46A)],
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF223528), Color(0xFF1A2A21)],
  );

  static const LinearGradient mythicGradient = LinearGradient(
    colors: [Color(0xFFBC4749), Color(0xFFE9C46A), Color(0xFF1B4332)],
  );
}
