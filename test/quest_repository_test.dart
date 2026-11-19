// Regresi audit-fix PR #2: QuestRepository dulu membangun ulang QuestModel
// manual dan diam-diam menghapus field (finalPrice, paidAt, isUrgent,
// nego, revisi, file) — dan requestNego/acceptNego dulu no-op kosong.
// Tes ini mengunci perilaku benar: update apa pun mempertahankan field
// lain (copyWith), nego benar-benar tersimpan.
import 'package:flutter_test/flutter_test.dart';
import 'package:cariquest/core/constants/app_enums.dart';
import 'package:cariquest/core/mock/mock_data.dart';
import 'package:cariquest/features/quest/services/quest_repository.dart';
import 'package:cariquest/shared/models/quest_model.dart';

void main() {
  late MockData mock;
  late QuestRepository repo;

  QuestModel questLengkap(String id) => QuestModel(
        questId: id,
        seekerUid: 'demo_seeker_1',
        expertUid: 'demo_expert_1',
        title: 'Quest uji',
        description: 'Deskripsi uji',
        jobdeskDetail: 'Jobdesk uji',
        deadline: DateTime(2026, 12, 1),
        minBudget: 100000,
        maxBudget: 200000,
        finalPrice: 150000,
        isUrgent: true,
        urgentMarkupPct: 0.3,
        status: QuestStatus.working,
        expertAccepted: true,
        negoPrice: 150000,
        negoStatus: 'accepted',
        revisionCount: 1,
        revisionNotes: const ['revisi 1'],
        previewFileUrl: 'https://contoh.id/preview',
        finalFileUrl: 'https://contoh.id/hasil-lama',
        createdAt: DateTime(2026, 11, 1),
        paidAt: DateTime(2026, 11, 2),
      );

  setUp(() {
    mock = MockData.instance;
    mock.initDemoData();
    repo = QuestRepository();
  });

  QuestModel ambil(String id) =>
      mock.quests.firstWhere((q) => q.questId == id);

  group('submitWork mempertahankan data quest', () {
    test('finalPrice, paidAt, isUrgent, revisi tidak hilang', () async {
      mock.addQuest(questLengkap('q-submit'));
      await repo.submitWork('q-submit', 'https://contoh.id/hasil-baru');
      final q = ambil('q-submit');
      expect(q.status, QuestStatus.review);
      expect(q.finalFileUrl, 'https://contoh.id/hasil-baru');
      expect(q.submittedAt, isNotNull);
      expect(q.finalPrice, 150000);
      expect(q.paidAt, DateTime(2026, 11, 2));
      expect(q.isUrgent, isTrue);
      expect(q.urgentMarkupPct, 0.3);
      expect(q.revisionCount, 1);
      expect(q.revisionNotes, ['revisi 1']);
      expect(q.negoStatus, 'accepted');
      expect(q.previewFileUrl, 'https://contoh.id/preview');
    });
  });

  group('updateQuestStatus mempertahankan data quest', () {
    test('cancel tidak menghapus finalPrice/file/paidAt/revisi', () async {
      mock.addQuest(questLengkap('q-cancel'));
      await repo.cancelQuest('q-cancel');
      final q = ambil('q-cancel');
      expect(q.status, QuestStatus.cancelled);
      expect(q.finalPrice, 150000);
      expect(q.finalFileUrl, 'https://contoh.id/hasil-lama');
      expect(q.paidAt, DateTime(2026, 11, 2));
      expect(q.revisionCount, 1);
      expect(q.isUrgent, isTrue);
    });

    test('requestRevision (working lagi) tidak menghapus file/finalPrice',
        () async {
      mock.addQuest(questLengkap('q-revisi'));
      await repo.requestRevision('q-revisi');
      final q = ambil('q-revisi');
      expect(q.status, QuestStatus.working);
      expect(q.finalPrice, 150000);
      expect(q.finalFileUrl, 'https://contoh.id/hasil-lama');
    });
  });

  group('nego benar-benar tersimpan (dulu no-op)', () {
    test('requestNego menulis negoPrice + status waiting', () async {
      mock.addQuest(questLengkap('q-nego')
          .copyWith(negoPrice: null, negoStatus: null));
      await repo.requestNego('q-nego', 'demo_seeker_1', 120000);
      final q = ambil('q-nego');
      expect(q.negoPrice, 120000);
      expect(q.negoStatus, 'waiting');
      expect(q.finalPrice, 150000);
      expect(q.status, QuestStatus.working);
    });

    test('acceptNego menulis accepted + finalPrice = harga nego', () async {
      mock.addQuest(questLengkap('q-acc')
          .copyWith(negoPrice: 120000, negoStatus: 'waiting'));
      await repo.acceptNego('q-acc', 120000);
      final q = ambil('q-acc');
      expect(q.negoStatus, 'accepted');
      expect(q.finalPrice, 120000);
      expect(q.expertAccepted, isTrue);
      expect(q.paidAt, DateTime(2026, 11, 2));
    });
  });

  group('acceptDirectQuest mempertahankan data quest', () {
    test('isUrgent + markup + nego tidak hilang', () async {
      mock.addQuest(questLengkap('q-direct')
          .copyWith(status: QuestStatus.pending, expertAccepted: false));
      await repo.acceptDirectQuest('q-direct', 'demo_seeker_1',
          finalPrice: 150000);
      final q = ambil('q-direct');
      expect(q.status, QuestStatus.working);
      expect(q.expertAccepted, isTrue);
      expect(q.finalPrice, 150000);
      expect(q.isUrgent, isTrue);
      expect(q.urgentMarkupPct, 0.3);
      expect(q.negoStatus, 'accepted');
    });
  });
}
