// Regresi audit-fix: stream MockData harus snapshot-first (replay).
// Dulu keempat stream getter mengembalikan broadcast stream mentah:
// layar yang subscribe SETELAH initDemoData() (mis. dashboard Expert
// sesudah login) terjebak loading selamanya — ketahuan live 19 Nov 2026
// dari spinner "Quest Aktif" yang tak pernah berhenti. streamUserData
// sudah snapshot-first; tes ini mengunci perilaku yang sama untuk
// quests/users/profiles/notifications + update live tetap mengalir.
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:cariquest/core/mock/mock_data.dart';
import 'package:cariquest/shared/models/quest_model.dart';
import 'package:cariquest/core/constants/app_enums.dart';

void main() {
  late MockData mock;

  setUp(() {
    mock = MockData.instance;
    mock.initDemoData();
  });

  group('subscribe telat tetap langsung dapat data (replay)', () {
    test('questsStream: 5 quest demo tanpa menunggu emit baru',
        timeout: const Timeout(Duration(seconds: 5)), () async {
      final first = await mock.questsStream.first;
      expect(first, hasLength(5));
    });

    test('usersStream: 3 pengguna demo tanpa menunggu emit baru',
        timeout: const Timeout(Duration(seconds: 5)), () async {
      final first = await mock.usersStream.first;
      expect(first, hasLength(3));
    });

    test('profilesStream: snapshot sama dengan isi saat ini',
        timeout: const Timeout(Duration(seconds: 5)), () async {
      final first = await mock.profilesStream.first;
      expect(first.length, mock.profiles.length);
    });

    test('notificationsStream: snapshot sama dengan isi saat ini',
        timeout: const Timeout(Duration(seconds: 5)), () async {
      final first = await mock.notificationsStream.first;
      expect(first.length, mock.notifications.length);
    });
  });

  test('update live tetap mengalir setelah snapshot awal',
      timeout: const Timeout(Duration(seconds: 5)), () async {
    final events = <List<QuestModel>>[];
    final sub = mock.questsStream.listen(events.add);
    mock.addQuest(QuestModel(
      questId: 'q-replay',
      seekerUid: 'demo_seeker_1',
      title: 'Quest replay',
      description: 'd',
      jobdeskDetail: 'j',
      deadline: DateTime(2026, 12, 1),
      minBudget: 50000,
      maxBudget: 100000,
      status: QuestStatus.pending,
      createdAt: DateTime(2026, 11, 1),
    ));
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await sub.cancel();
    expect(events.length, greaterThanOrEqualTo(2));
    expect(events.first, hasLength(5));
    expect(events.last, hasLength(6));
    expect(events.last.map((q) => q.questId), contains('q-replay'));
  });
}
