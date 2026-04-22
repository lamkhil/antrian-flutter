import 'package:antrian/features/pengguna/widgets/reset_password_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures.dart';

/// Helper: mount dialog inside a MaterialApp and show it. Returns the future
/// resolved when dialog is popped.
Future<String?> _openDialog(WidgetTester tester) async {
  String? result;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (ctx) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                result = await showDialog<String>(
                  context: ctx,
                  builder: (_) => ResetPasswordDialog(target: fixPengguna),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
  return result;
}

void main() {
  group('ResetPasswordDialog', () {
    testWidgets('renders target nama + email', (tester) async {
      await _openDialog(tester);
      expect(
        find.textContaining('${fixPengguna.nama} (${fixPengguna.email})'),
        findsOneWidget,
      );
    });

    testWidgets('shows validation error for password < 6 chars',
        (tester) async {
      await _openDialog(tester);

      await tester.enterText(find.byType(TextField), 'abc');
      await tester.tap(find.text('Simpan'));
      await tester.pump();

      expect(find.text('Password minimal 6 karakter.'), findsOneWidget);
    });

    testWidgets('trims whitespace and rejects whitespace-only', (tester) async {
      await _openDialog(tester);

      await tester.enterText(find.byType(TextField), '     ');
      await tester.tap(find.text('Simpan'));
      await tester.pump();

      expect(find.text('Password minimal 6 karakter.'), findsOneWidget);
    });

    testWidgets('pops with trimmed password on valid submit', (tester) async {
      String? captured;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    captured = await showDialog<String>(
                      context: ctx,
                      builder: (_) =>
                          ResetPasswordDialog(target: fixPengguna),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '  newpass123  ');
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(captured, 'newpass123');
    });

    testWidgets('pressing Batal returns null', (tester) async {
      String? captured = 'not-null';
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    captured = await showDialog<String>(
                      context: ctx,
                      builder: (_) =>
                          ResetPasswordDialog(target: fixPengguna),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      expect(captured, isNull);
    });

    testWidgets('toggles password visibility via suffix icon', (tester) async {
      await _openDialog(tester);

      // Default obscure = true → visibility_off icon
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsNothing);

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsNothing);
    });
  });
}
