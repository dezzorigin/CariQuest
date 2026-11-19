// lib/shared/widgets/status_chip.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_enums.dart';

/// Chip status lifecycle quest — warna dari palet kontrak (docs/DESIGN.md),
/// bukan rona Material acak. Latar = warna status 12% di atas kertas.
class StatusChip extends StatelessWidget {
  final QuestStatus? status;
  final Color? color;
  final String? label;

  const StatusChip({
    super.key,
    this.status,
    this.color,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = color?.withValues(alpha: 0.12) ?? AppColors.grey100;
    Color textColor = color ?? AppColors.grey800;
    String text = label ?? 'Unknown';

    if (status != null) {
      switch (status!) {
        case QuestStatus.pending:
          bgColor = AppColors.statusPending.withValues(alpha: 0.12);
          textColor = AppColors.statusPending;
          text = 'Mencari Expert';
          break;
        case QuestStatus.paid:
          bgColor = AppColors.statusPaid.withValues(alpha: 0.12);
          textColor = AppColors.statusPaid;
          text = 'Dana di Escrow';
          break;
        case QuestStatus.working:
          bgColor = AppColors.statusWorking.withValues(alpha: 0.12);
          textColor = AppColors.statusWorking;
          text = 'Sedang Dikerjakan';
          break;
        case QuestStatus.review:
          bgColor = AppColors.statusReview.withValues(alpha: 0.12);
          textColor = AppColors.statusReview;
          text = 'Review Hasil';
          break;
        case QuestStatus.finished:
          bgColor = AppColors.statusFinished.withValues(alpha: 0.12);
          textColor = AppColors.statusFinished;
          text = 'Selesai';
          break;
        case QuestStatus.disputed:
          bgColor = AppColors.statusDisputed.withValues(alpha: 0.12);
          textColor = AppColors.statusDisputed;
          text = 'Banding';
          break;
        case QuestStatus.cancelled:
          bgColor = AppColors.grey200;
          textColor = AppColors.grey700;
          text = 'Dibatalkan';
          break;
      }
    }

    if (color != null) {
      bgColor = color!.withValues(alpha: 0.12);
      textColor = color!;
    }
    if (label != null) {
      text = label!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
