import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:veda_ui/veda_ui.dart';

void main() {
  late Directory dir;
  var held = '{"now":true}';
  final restored = <String>[];

  RestoreTarget target({String key = 'sun'}) => RestoreTarget(
    appKey: key,
    appName: 'Véda Sun',
    exportJson: () => held,
    restoreJson: (j) async {
      restored.add(j);
      held = j;
    },
  );

  File pending() => File('${dir.path}/veda_restore_pending.json');
  File undoCopy() => File('${dir.path}/veda_before_restore.json');

  Future<void> leave({String app = 'sun', String json = '{"from":"backup"}'}) =>
      pending().writeAsString(
        jsonEncode({
          'format': 'veda-restore/1',
          'app': app,
          'backupMade': '2026-10-03T09:00:00.000Z',
          'json': json,
        }),
      );

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    dir = await Directory.systemTemp.createTemp('restore_inbox');
    RestoreInbox.debugDir = dir;
    RestoreInbox.clock = DateTime.now;
    held = '{"now":true}';
    restored.clear();
  });

  tearDown(() async {
    RestoreInbox.debugDir = null;
    await dir.delete(recursive: true);
  });

  test('nothing waiting: nothing happens', () async {
    expect(await RestoreInbox.applyIfWaiting(target()), isNull);
    expect(restored, isEmpty);
  });

  test('a restore Véda left is applied, what was there is kept, the file is removed', () async {
    await leave();
    final done = await RestoreInbox.applyIfWaiting(target());
    expect(done, isNotNull);
    expect(done!.backupMade, DateTime.utc(2026, 10, 3, 9));
    expect(restored, ['{"from":"backup"}']);
    expect(pending().existsSync(), isFalse);
    final copy = jsonDecode(await undoCopy().readAsString()) as Map;
    expect(copy['json'], '{"now":true}');
    expect(await RestoreInbox.undoAvailableSince(), isNotNull);
  });

  test('a restore meant for another app is dropped, never applied', () async {
    await leave(app: 'lifestyle');
    expect(await RestoreInbox.applyIfWaiting(target()), isNull);
    expect(restored, isEmpty);
    expect(pending().existsSync(), isFalse);
  });

  test('a file still being written is left for the next look', () async {
    await pending().writeAsString('{"format": "veda-restore/1", "app": "su');
    expect(await RestoreInbox.applyIfWaiting(target()), isNull);
    expect(pending().existsSync(), isTrue);
    // a day later it is given up on
    RestoreInbox.clock = () => DateTime.now().add(const Duration(days: 2));
    expect(await RestoreInbox.applyIfWaiting(target()), isNull);
    expect(pending().existsSync(), isFalse);
  });

  test('undo puts back what the app held, and only once', () async {
    await leave();
    await RestoreInbox.applyIfWaiting(target());
    expect(held, '{"from":"backup"}');
    expect(await RestoreInbox.undo(target()), isTrue);
    expect(held, '{"now":true}');
    expect(await RestoreInbox.undo(target()), isFalse);
    expect(await RestoreInbox.undoAvailableSince(), isNull);
  });

  test('the undo copy is gone after 14 days', () async {
    await leave();
    await RestoreInbox.applyIfWaiting(target());
    RestoreInbox.clock = () => DateTime.now().add(const Duration(days: 15));
    expect(await RestoreInbox.undoAvailableSince(), isNull);
    expect(undoCopy().existsSync(), isFalse);
  });

  test('Delete everything clears the undo copy and a restore still waiting', () async {
    await leave();
    await RestoreInbox.applyIfWaiting(target());
    await leave(); // a second restore left waiting
    expect(undoCopy().existsSync(), isTrue);
    expect(pending().existsSync(), isTrue);
    await RestoreInbox.clearUndo();
    expect(undoCopy().existsSync(), isFalse);
    expect(pending().existsSync(), isFalse);
    expect(await RestoreInbox.undo(target()), isFalse);
  });
}
