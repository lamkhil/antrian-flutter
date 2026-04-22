import 'package:antrian/features/pengguna/widgets/service_account_setup_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ServiceAccountSetupDialog (initial state)', () {
    Future<void> pumpDialog(WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ServiceAccountSetupDialog()),
        ),
      );
    }

    testWidgets('renders title + buttons', (tester) async {
      await pumpDialog(tester);

      expect(find.text('Setup Service Account'), findsOneWidget);
      expect(find.text('Pilih file...'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
      expect(find.text('Simpan'), findsOneWidget);
    });

    testWidgets('Simpan button disabled before file picked', (tester) async {
      await pumpDialog(tester);

      final saveBtn = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text('Simpan'),
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(saveBtn.onPressed, isNull);
    });

    testWidgets('shows empty-state helper text', (tester) async {
      await pumpDialog(tester);
      expect(find.text('Belum ada file dipilih'), findsOneWidget);
    });

    testWidgets('reassures user that file stays on-device', (tester) async {
      await pumpDialog(tester);
      expect(
        find.textContaining('disimpan terenkripsi di perangkat ini'),
        findsOneWidget,
      );
    });
  });
}
