// Widget test StatusChip — label tiap status lifecycle quest
// (menggantikan template counter bawaan `flutter create` yang tidak
// pernah cocok dengan aplikasi ini).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cariquest/core/constants/app_enums.dart';
import 'package:cariquest/shared/widgets/status_chip.dart';

void main() {
  const cases = <QuestStatus, String>{
    QuestStatus.pending: 'Mencari Expert',
    QuestStatus.paid: 'Dana di Escrow',
    QuestStatus.working: 'Sedang Dikerjakan',
    QuestStatus.review: 'Review Hasil',
    QuestStatus.finished: 'Selesai',
    QuestStatus.disputed: 'Banding',
    QuestStatus.cancelled: 'Dibatalkan',
  };

  for (final entry in cases.entries) {
    testWidgets('StatusChip ${entry.key.name} menampilkan "${entry.value}"',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: StatusChip(status: entry.key)),
        ),
      );
      expect(find.text(entry.value), findsOneWidget);
    });
  }

  testWidgets('StatusChip label kustom menimpa label status', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatusChip(status: QuestStatus.pending, label: 'Khusus'),
        ),
      ),
    );
    expect(find.text('Khusus'), findsOneWidget);
    expect(find.text('Mencari Expert'), findsNothing);
  });

  testWidgets('StatusChip tanpa status menampilkan Unknown', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StatusChip()),
      ),
    );
    expect(find.text('Unknown'), findsOneWidget);
  });
}
