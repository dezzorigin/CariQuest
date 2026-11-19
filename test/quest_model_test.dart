// Unit test QuestModel — lifecycle, copyWith, dan round-trip Map.
import 'package:flutter_test/flutter_test.dart';
import 'package:cariquest/core/constants/app_enums.dart';
import 'package:cariquest/shared/models/quest_model.dart';

QuestModel sampleQuest({QuestStatus status = QuestStatus.pending}) {
  return QuestModel(
    questId: 'q-test-1',
    seekerUid: 'demo_seeker_1',
    title: 'Buat Desain UI Mobile App',
    description: 'Butuh 5 screen design untuk aplikasi e-commerce.',
    jobdeskDetail: '- Login\n- Home\n- Cart\n- Checkout\n- Profile',
    deadline: DateTime(2026, 11, 22),
    minBudget: 150000,
    maxBudget: 300000,
    status: status,
    createdAt: DateTime(2026, 11, 19),
  );
}

void main() {
  group('QuestModel defaults', () {
    test('quest baru berstatus pending, bukan urgent, tanpa revisi', () {
      final q = sampleQuest();
      expect(q.status, QuestStatus.pending);
      expect(q.isUrgent, isFalse);
      expect(q.urgentMarkupPct, 0.0);
      expect(q.expertAccepted, isFalse);
      expect(q.revisionCount, 0);
      expect(q.finalPrice, isNull);
      expect(q.expertUid, isNull);
    });

    test('anggaran min tidak boleh melebihi max (data demo valid)', () {
      final q = sampleQuest();
      expect(q.minBudget, lessThanOrEqualTo(q.maxBudget));
    });
  });

  group('QuestModel lifecycle (copyWith)', () {
    test('pending → paid → working → review → finished', () {
      var q = sampleQuest();
      q = q.copyWith(status: QuestStatus.paid, paidAt: DateTime(2026, 11, 19));
      expect(q.status, QuestStatus.paid);
      expect(q.paidAt, isNotNull);

      q = q.copyWith(
        status: QuestStatus.working,
        expertUid: 'demo_expert_1',
        expertAccepted: true,
        finalPrice: 200000,
      );
      expect(q.status, QuestStatus.working);
      expect(q.expertAccepted, isTrue);
      expect(q.finalPrice, 200000);

      q = q.copyWith(
        status: QuestStatus.review,
        submittedAt: DateTime(2026, 11, 20),
      );
      expect(q.status, QuestStatus.review);

      q = q.copyWith(
        status: QuestStatus.finished,
        completedAt: DateTime(2026, 11, 21),
      );
      expect(q.status, QuestStatus.finished);
      expect(q.completedAt, isNotNull);
    });

    test('copyWith tanpa argumen = quest yang sama (Equatable)', () {
      final q = sampleQuest();
      expect(q.copyWith(), equals(q));
    });

    test('copyWith hanya mengubah field yang disebut', () {
      final q = sampleQuest();
      final changed = q.copyWith(isUrgent: true, urgentMarkupPct: 0.25);
      expect(changed.isUrgent, isTrue);
      expect(changed.urgentMarkupPct, 0.25);
      expect(changed.title, q.title);
      expect(changed.status, q.status);
      expect(changed, isNot(equals(q)));
    });
  });

  group('QuestModel toMap / fromMap', () {
    test('round-trip mempertahankan semua field', () {
      final q = sampleQuest(status: QuestStatus.working).copyWith(
        expertUid: 'demo_expert_1',
        finalPrice: 200000,
        isUrgent: true,
        urgentMarkupPct: 0.25,
      );
      final restored = QuestModel.fromMap(q.toMap(), q.questId);
      expect(restored, equals(q));
      expect(restored.status, QuestStatus.working);
    });

    test('fromMap status tak dikenal jatuh ke pending', () {
      final map = sampleQuest().toMap()..['status'] = 'tidak_ada';
      final restored = QuestModel.fromMap(map, 'q-test-1');
      expect(restored.status, QuestStatus.pending);
    });
  });
}
