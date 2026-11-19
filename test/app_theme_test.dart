// Unit test tema — palet kontrak (docs/DESIGN.md) benar-benar terpasang.
// Tidak memompa widget: GoogleFonts hanya menyetel fontFamily saat
// konstruksi TextStyle, tanpa unduh font.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cariquest/core/constants/app_colors.dart';
import 'package:cariquest/core/theme/app_theme.dart';
import 'package:cariquest/core/theme/app_typography.dart';

void main() {
  group('AppColors — palet Rimba/Emas', () {
    test('primer = Rimba #1B4332, bukan ungu lama #6C2BD9', () {
      expect(AppColors.primary, const Color(0xFF1B4332));
      expect(AppColors.rimba, const Color(0xFF1B4332));
      expect(AppColors.primary, isNot(const Color(0xFF6C2BD9)));
    });

    test('emas = #E9C46A; emas gelap untuk teks harga', () {
      expect(AppColors.gold, const Color(0xFFE9C46A));
      expect(AppColors.goldDark, const Color(0xFF9A7B1E));
    });

    test('latar = Kertas #FDFBF5; teks = Tinta #1C2B21', () {
      expect(AppColors.background, const Color(0xFFFDFBF5));
      expect(AppColors.grey900, const Color(0xFF1C2B21));
    });

    test('status lifecycle memakai palet, bukan rona Material acak', () {
      expect(AppColors.statusWorking, AppColors.rimba);
      expect(AppColors.statusFinished, AppColors.daun);
      expect(AppColors.statusDisputed, AppColors.bata);
    });
  });

  group('AppTypography — 2 keluarga font', () {
    test('display/headline = Fraunces, body = Plus Jakarta Sans', () {
      final theme = AppTypography.textTheme;
      expect(theme.displayLarge?.fontFamily, contains('Fraunces'));
      expect(theme.headlineMedium?.fontFamily, contains('Fraunces'));
      expect(theme.bodyMedium?.fontFamily, contains('Plus Jakarta Sans'));
      expect(theme.titleMedium?.fontFamily, contains('Plus Jakarta Sans'));
    });

    test('priceTag memakai emas gelap', () {
      expect(AppTypography.priceTag.color, AppColors.goldDark);
    });
  });

  group('AppTheme — terang', () {
    test('colorScheme primer = Rimba, latar = Kertas, terang', () {
      final theme = AppTheme.light;
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.colorScheme.surface, AppColors.surface);
    });

    test('radius kartu/dialog = 14 (kontrak), bukan 16/20', () {
      final cardShape =
          AppTheme.light.cardTheme.shape as RoundedRectangleBorder;
      expect(cardShape.borderRadius, BorderRadius.circular(14));
      final dialogShape =
          AppTheme.light.dialogTheme.shape as RoundedRectangleBorder;
      expect(dialogShape.borderRadius, BorderRadius.circular(14));
    });

    test('tema gelap memakai permukaan rimba gelap', () {
      final theme = AppTheme.dark;
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.surface, AppColors.darkSurface);
    });
  });
}
