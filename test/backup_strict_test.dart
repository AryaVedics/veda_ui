import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veda_ui/veda_ui.dart';

BackupController _controller({required bool strict}) => BackupController(
  appKey: 'cycle',
  appName: 'Véda Cycle',
  exportJson: () => '{}',
  restoreJson: (_) async {},
  strict: strict,
);

Future<void> _openDialog(WidgetTester t, BackupController c) async {
  await t.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => c.backUp(context),
              child: const Text('go'),
            ),
          ),
        ),
      ),
    ),
  );
  await t.tap(find.text('go'));
  await t.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('a normal app may back up with no passphrase', (t) async {
    await _openDialog(t, _controller(strict: false));
    expect(find.byKey(const Key('backupWithoutPassphrase')), findsOneWidget);
  });

  testWidgets('a strict app (Véda Cycle) always asks for a passphrase', (
    t,
  ) async {
    await _openDialog(t, _controller(strict: true));
    expect(find.text('Choose a passphrase'), findsOneWidget);
    expect(find.byKey(const Key('backupWithoutPassphrase')), findsNothing);
    expect(find.textContaining('leave the passphrase out'), findsNothing);
  });
}
