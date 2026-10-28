import 'package:flutter_test/flutter_test.dart';
import 'package:veda_ui/veda_ui.dart';

void main() {
  const json = '{"days":{"2026-10-15":{"sleep":"7-8h"}}}';

  test('a backup made without a passphrase opens without one', () async {
    final file = plainBackup('lifestyle', json);
    expect(isPlainBackup(file), isTrue);
    expect(backupAppOf(file), 'lifestyle');
    expect(await openBackup('lifestyle', file, null), json);
  });

  test('a sealed backup still needs its passphrase', () async {
    final file = await sealBackup(
      'lifestyle',
      json,
      'correct horse',
      iterations: 1000,
    );
    expect(isPlainBackup(file), isFalse);
    expect(await openBackup('lifestyle', file, 'correct horse'), json);
    expect(
      () => openBackup('lifestyle', file, null),
      throwsA(isA<BackupException>()),
    );
    expect(
      () => openBackup('lifestyle', file, 'wrong one'),
      throwsA(isA<BackupException>()),
    );
  });

  test('a passphrase-free backup is for its own app only', () async {
    final file = plainBackup('lifestyle', json);
    expect(
      () => openBackup('routine', file, null),
      throwsA(isA<BackupException>()),
    );
  });
}
