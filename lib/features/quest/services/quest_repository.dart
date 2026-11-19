// lib/features/quest/services/quest_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/mock/mock_data.dart';
import '../../../shared/models/models.dart';

final questRepositoryProvider = Provider<QuestRepository>((ref) {
  return QuestRepository();
});

class QuestRepository {
  final MockData _db = MockData.instance;

  static const int maxRevisions = 2;

  QuestRepository();

  Future<void> postQuest(QuestModel quest) async {
    _db.addQuest(quest);
  }

  Stream<List<QuestModel>> streamAvailableQuests() {
    return _db.questsStream.map((quests) => 
        quests.where((q) => q.status == QuestStatus.pending).toList());
  }

  Stream<List<QuestModel>> streamSeekerQuests(String seekerUid) {
    return _db.questsStream.map((quests) => 
        quests.where((q) => q.seekerUid == seekerUid).toList());
  }

  Stream<List<QuestModel>> streamExpertQuests(String expertUid) {
    return _db.questsStream.map((quests) => 
        quests.where((q) => q.expertUid == expertUid).toList());
  }

  Stream<QuestModel?> streamQuest(String questId) {
    return _db.questsStream.map((quests) {
      try {
        return quests.firstWhere((q) => q.questId == questId);
      } catch (_) {
        return null;
      }
    });
  }

  Future<void> finishQuest(String questId) async {
    final quest = _db.quests.firstWhere((q) => q.questId == questId);

    // Update Quest status (copyWith: semua field lain dipertahankan).
    _db.updateQuest(quest.copyWith(
      status: QuestStatus.finished,
      completedAt: DateTime.now(),
    ));

    // Update Expert EXP & Saldo
    if (quest.expertUid != null) {
      final expert = _db.getUser(quest.expertUid!);
      if (expert != null) {
        final newExp = expert.expPoints + 150;
        final updatedExpert = expert.copyWith(
          expPoints: newExp,
          saldoActive: expert.saldoActive + (quest.finalPrice ?? quest.maxBudget),
          totalQuestsDone: expert.totalQuestsDone + 1,
        );
        _db.updateUser(updatedExpert);
      }
    }
  }

  Future<void> updateQuestStatus(String questId, QuestStatus status) async {
    final quest = _db.quests.firstWhere((q) => q.questId == questId);
    // copyWith: dulu rebuild manual hanya menyalin 12 dari 24 field —
    // cancel/revisi diam-diam menghapus finalPrice, paidAt, finalFileUrl,
    // nego, revisi, dan urgent. Sekarang semua field dipertahankan.
    _db.updateQuest(quest.copyWith(status: status));
  }

  Future<void> cancelQuest(String questId) async {
    await updateQuestStatus(questId, QuestStatus.cancelled);
  }

  Future<void> submitWork(String questId, String fileUrl) async {
    final quest = _db.quests.firstWhere((q) => q.questId == questId);
    // copyWith: dulu rebuild manual menghapus finalPrice/paidAt/isUrgent/
    // nego/revisi — payout finishQuest lalu jatuh ke maxBudget (salah).
    _db.updateQuest(quest.copyWith(
      status: QuestStatus.review,
      finalFileUrl: fileUrl,
      submittedAt: DateTime.now(),
    ));
  }

  Future<void> requestRevision(String questId) async {
    await updateQuestStatus(questId, QuestStatus.working);
  }

  Future<void> acceptDirectQuest(String questId, String seekerUid, {int? finalPrice}) async {
    final quest = _db.quests.firstWhere((q) => q.questId == questId);
    _db.updateQuest(quest.copyWith(
      status: QuestStatus.working, // jump to working in mock
      expertAccepted: true,
      finalPrice: finalPrice ?? quest.minBudget,
    ));
  }

  Future<void> requestNego(String questId, String seekerUid, int negoPrice) async {
    // Dulu no-op kosong: expert kirim nego tapi harga tak pernah tersimpan,
    // seeker tidak pernah melihat tawaran itu.
    final quest = _db.quests.firstWhere((q) => q.questId == questId);
    _db.updateQuest(quest.copyWith(
      negoPrice: negoPrice,
      negoStatus: 'waiting',
    ));
  }

  Future<void> acceptNego(String questId, int negoPrice) async {
    // Dulu no-op kosong: seeker "Setuju & Bayar" tapi negoStatus tetap
    // 'waiting' sehingga kartu nego terus muncul, dan finalPrice tak
    // pernah ditulis (payout/finish memakai harga lama).
    final quest = _db.quests.firstWhere((q) => q.questId == questId);
    _db.updateQuest(quest.copyWith(
      negoPrice: negoPrice,
      negoStatus: 'accepted',
      finalPrice: negoPrice,
      expertAccepted: true,
    ));
  }
}
