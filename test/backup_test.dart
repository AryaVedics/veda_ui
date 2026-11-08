import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veda_ui/veda_ui.dart';

// Few iterations: the point here is the format and the checks, not the cost.
const _fast = 1000;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('backup file', () {
    test('opens with the passphrase, and only that one', () async {
      final sealed = await sealBackup(
        'cycle',
        '{"days":{"2026-10-01":{"period":true}}}',
        'correct horse',
        iterations: _fast,
      );
      expect(backupAppOf(sealed), 'cycle');
      expect(
        sealed.contains('period'),
        isFalse,
        reason: 'sealed, not readable',
      );
      expect(
        await openBackup('cycle', sealed, 'correct horse'),
        '{"days":{"2026-10-01":{"period":true}}}',
      );
      expect(
        () => openBackup('cycle', sealed, 'wrong horse'),
        throwsA(isA<BackupException>()),
      );
    });

    test('belongs to one app, and is not a backup unless it is', () async {
      final sealed = await sealBackup(
        'cycle',
        '{}',
        'passphrase1',
        iterations: _fast,
      );
      expect(
        () => openBackup('lifestyle', sealed, 'passphrase1'),
        throwsA(isA<BackupException>()),
      );
      expect(backupAppOf('{"a":1}'), isNull);
      expect(backupAppOf('not json at all'), isNull);
      expect(
        () => openBackup('cycle', 'nonsense', 'passphrase1'),
        throwsA(isA<BackupException>()),
      );
    });

    test('a file asking for an absurd number of key rounds is refused, not worked through', () async {
      // The rounds are read from the file, so a damaged or edited one could
      // ask for billions and leave the restore working for hours. Nothing a
      // Véda app makes uses more than kBackupIterations.
      final sealed = await sealBackup(
        'sun',
        '{"x":1}',
        'passphrase1',
        iterations: _fast,
      );
      final m = jsonDecode(sealed) as Map<String, dynamic>;
      for (final rounds in [2000000000, 0, -5]) {
        await expectLater(
          openBackup(
            'sun',
            jsonEncode({...m, 'iterations': rounds}),
            'passphrase1',
          ),
          throwsA(
            isA<BackupException>().having(
              (e) => e.message,
              'message',
              'That backup file is damaged.',
            ),
          ),
          reason: '$rounds rounds',
        );
      }
    }, timeout: const Timeout(Duration(seconds: 20)));

    test('a changed file does not open', () async {
      final sealed = await sealBackup(
        'sun',
        '{"x":1}',
        'passphrase1',
        iterations: _fast,
      );
      final m = jsonDecode(sealed) as Map<String, dynamic>;
      final data = base64Decode(m['data'] as String);
      data[3] ^= 1;
      m['data'] = base64Encode(data);
      expect(
        () => openBackup('sun', jsonEncode(m), 'passphrase1'),
        throwsA(isA<BackupException>()),
      );
    });

    test(
      'two backups of the same data differ (fresh salt and nonce)',
      () async {
        final a = await sealBackup(
          'sun',
          '{}',
          'passphrase1',
          iterations: _fast,
        );
        final b = await sealBackup(
          'sun',
          '{}',
          'passphrase1',
          iterations: _fast,
        );
        expect(a, isNot(b));
      },
    );

    test('the file is named for the app and the day', () {
      expect(
        backupFileName('cycle', DateTime(2026, 10, 3)),
        'veda-cycle-backup-2026-10-03.vedabackup',
      );
    });
  });

  group('reminder', () {
    BackupController make(DateTime Function() clock) => BackupController(
      appKey: 'sun',
      appName: 'Véda Sun',
      exportJson: () => '{}',
      restoreJson: (_) async {},
      clock: clock,
    );

    test(
      'first use only starts the clock; due after 30 days; Later waits 14',
      () async {
        SharedPreferences.setMockInitialValues({});
        var now = DateTime(2026, 10, 1);
        final c = make(() => now);
        expect(await c.reminderDue(), isFalse);
        now = DateTime(2026, 10, 20);
        expect(await c.reminderDue(), isFalse);
        now = DateTime(2026, 11, 2);
        expect(await c.reminderDue(), isTrue);
        await c.snooze();
        now = DateTime(2026, 11, 10);
        expect(await c.reminderDue(), isFalse);
        now = DateTime(2026, 11, 17);
        expect(await c.reminderDue(), isTrue);
      },
    );

    test('a backup resets it', () async {
      final first = DateTime(2026, 10, 1).millisecondsSinceEpoch;
      SharedPreferences.setMockInitialValues({
        'backup_first_sun': first,
        'backup_last_sun': DateTime(2026, 11, 1).millisecondsSinceEpoch,
      });
      final c = make(() => DateTime(2026, 11, 20));
      expect(await c.reminderDue(), isFalse);
      expect((await c.lastBackup())!.month, 11);
    });
  });
}
