// Unit test MockData — data demo yang menggerakkan seluruh aplikasi
// (mock MVP offline 100%: tanpa ini, feed quest dan login demo kosong).
import 'package:flutter_test/flutter_test.dart';
import 'package:cariquest/core/constants/app_enums.dart';
import 'package:cariquest/core/mock/mock_data.dart';

void main() {
  late MockData mock;

  setUp(() {
    mock = MockData.instance;
    mock.initDemoData();
  });

  group('pengguna demo', () {
    test('tepat 3 pengguna: admin, expert, seeker', () {
      expect(mock.users, hasLength(3));
      expect(
        mock.users.map((u) => u.role).toSet(),
        {UserRole.admin, UserRole.expert, UserRole.seeker},
      );
    });

    test('akun demo memakai email @demo.com', () {
      for (final u in mock.users) {
        expect(u.email, endsWith('@demo.com'));
      }
      expect(
        mock.users.map((u) => u.email),
        containsAll([
          'admin@demo.com',
          'expert@demo.com',
          'seeker@demo.com',
        ]),
      );
    });

    test('expert demo: Aldi Firmansyah, Informatika, 12 quest, rating 4.8',
        () {
      final expert =
          mock.users.firstWhere((u) => u.role == UserRole.expert);
      expect(expert.displayName, 'Aldi Firmansyah');
      expect(expert.major, 'Informatika');
      expect(expert.totalQuestsDone, 12);
      expect(expert.ratingAvg, 4.8);
      expect(expert.ratingCount, 15);
      expect(expert.saldoActive, 250000);
      expect(expert.isKtmVerified, isTrue);
    });

    test('getUser mengembalikan null untuk uid tak dikenal', () {
      expect(mock.getUser('uid_tidak_ada'), isNull);
      expect(mock.getUser('demo_expert_1')?.displayName, 'Aldi Firmansyah');
    });
  });

  group('quest demo', () {
    test('tepat 5 quest demo', () {
      expect(mock.quests, hasLength(5));
    });

    test('status demo mencakup pending, working, review, finished', () {
      final statuses = mock.quests.map((q) => q.status).toSet();
      expect(
        statuses,
        containsAll([
          QuestStatus.pending,
          QuestStatus.working,
          QuestStatus.review,
          QuestStatus.finished,
        ]),
      );
    });

    test('semua anggaran demo dalam rentang Rp30.000–Rp300.000', () {
      for (final q in mock.quests) {
        expect(q.minBudget, greaterThanOrEqualTo(30000));
        expect(q.maxBudget, lessThanOrEqualTo(300000));
        expect(q.minBudget, lessThanOrEqualTo(q.maxBudget));
      }
    });

    test('quest working yang urgent punya harga final', () {
      final working =
          mock.quests.firstWhere((q) => q.status == QuestStatus.working);
      expect(working.isUrgent, isTrue);
      expect(working.finalPrice, 75000);
    });

    test('quest finished punya completedAt', () {
      final done =
          mock.quests.firstWhere((q) => q.status == QuestStatus.finished);
      expect(done.completedAt, isNotNull);
      expect(done.finalPrice, 100000);
    });

    test('addQuest menaruh quest baru paling depan', () {
      final before = mock.quests.length;
      mock.addQuest(
        mock.quests.first.copyWith(
          questId: 'q-baru',
          title: 'Quest Baru',
          status: QuestStatus.pending,
        ),
      );
      expect(mock.quests, hasLength(before + 1));
      expect(mock.quests.first.questId, 'q-baru');
    });

    test('updateQuest mengubah quest yang sama, bukan menambah', () {
      final target = mock.quests.first;
      final before = mock.quests.length;
      mock.updateQuest(target.copyWith(title: 'Judul Diubah'));
      expect(mock.quests, hasLength(before));
      expect(
        mock.quests.firstWhere((q) => q.questId == target.questId).title,
        'Judul Diubah',
      );
    });
  });
}
