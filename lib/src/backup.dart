// Backing up and restoring an app's data, by hand and nowhere else.
//
// Nothing in the Véda apps is backed up automatically: not to Google, not to
// iCloud, not to us. Someone who wants a copy makes one here. It is one file,
// sealed with a passphrase they choose (AES-256-GCM, the key stretched from the
// passphrase with PBKDF2), and they save it wherever they like through the
// phone's share sheet (Drive, iCloud, a computer, a USB stick). A forgotten
// passphrase cannot be recovered by anyone, which the dialog says plainly.
//
// This file is the codec and the screens around it. Each app only says how to
// export its data to JSON and how to put JSON back.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

import 'app_colors.dart';
import 'common.dart';

const _format = 'veda-backup/1';
const kBackupIterations = 150000;

/// Something the person should be told, in plain words.
class BackupException implements Exception {
  BackupException(this.message);
  final String message;

  @override
  String toString() => message;
}

Uint8List _randomBytes(int n) {
  final r = SecureRandom.defaultRandom;
  return Uint8List.fromList([for (var i = 0; i < n; i++) r.nextInt(256)]);
}

Future<SecretKey> _key(String passphrase, List<int> salt, int iterations) =>
    Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: 256,
    ).deriveKeyFromPassword(password: passphrase, nonce: salt);

/// [json] sealed under [passphrase] as the text of a backup file for [appKey].
Future<String> sealBackup(
  String appKey,
  String json,
  String passphrase, {
  int iterations = kBackupIterations,
  DateTime? now,
}) async {
  final salt = _randomBytes(16);
  final key = await _key(passphrase, salt, iterations);
  final box = await AesGcm.with256bits().encrypt(
    utf8.encode(json),
    secretKey: key,
    nonce: _randomBytes(12),
    aad: utf8.encode(appKey),
  );
  return jsonEncode({
    'format': _format,
    'app': appKey,
    'created': (now ?? DateTime.now()).toUtc().toIso8601String(),
    'kdf': 'pbkdf2-sha256',
    'iterations': iterations,
    'salt': base64Encode(salt),
    'data': base64Encode(box.concatenation()),
  });
}

/// Which app a backup file belongs to, without opening it; null if it is not
/// a Véda backup at all.
String? backupAppOf(String text) {
  try {
    final m = jsonDecode(text);
    if (m is Map && m['format'] == _format && m['app'] is String) {
      return m['app'] as String;
    }
  } catch (_) {}
  return null;
}

/// The JSON inside a backup file. Throws [BackupException] if it is not a
/// backup for [appKey] or the passphrase is wrong.
Future<String> openBackup(String appKey, String text, String passphrase) async {
  final app = backupAppOf(text);
  if (app == null) {
    throw BackupException('That file is not a Véda backup.');
  }
  if (app != appKey) {
    throw BackupException('That backup belongs to a different Véda app.');
  }
  final m = jsonDecode(text) as Map;
  try {
    final salt = base64Decode(m['salt'] as String);
    final key = await _key(passphrase, salt, (m['iterations'] as num).toInt());
    final box = SecretBox.fromConcatenation(
      base64Decode(m['data'] as String),
      nonceLength: 12,
      macLength: 16,
    );
    final clear = await AesGcm.with256bits().decrypt(
      box,
      secretKey: key,
      aad: utf8.encode(appKey),
    );
    return utf8.decode(clear);
  } on SecretBoxAuthenticationError {
    throw BackupException('That passphrase did not open this backup.');
  } on BackupException {
    rethrow;
  } catch (_) {
    throw BackupException('That backup file is damaged.');
  }
}

String _two(int n) => n.toString().padLeft(2, '0');

String backupFileName(String appKey, DateTime d) =>
    'veda-$appKey-backup-${d.year}-${_two(d.month)}-${_two(d.day)}.vedabackup';

/// How often a gentle reminder comes, and how long "Later" waits.
const kBackupReminderEvery = Duration(days: 30);
const kBackupLaterFor = Duration(days: 14);

/// One app's backup: what it holds, and the two things it can do.
class BackupController {
  BackupController({
    required this.appKey,
    required this.appName,
    required this.exportJson,
    required this.restoreJson,
    this.iterations = kBackupIterations,
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now;

  /// "cycle", "lifestyle": names the file and binds it to this app.
  final String appKey;

  /// "Véda Cycle".
  final String appName;

  final String Function() exportJson;

  /// Puts a backup's JSON back, replacing what the app holds now.
  final Future<void> Function(String json) restoreJson;
  final int iterations;
  final DateTime Function() clock;

  String get _lastKey => 'backup_last_$appKey';
  String get _firstKey => 'backup_first_$appKey';
  String get _laterKey => 'backup_later_$appKey';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  /// When the last backup was made, or null if never.
  Future<DateTime?> lastBackup() async {
    try {
      final ms = (await _prefs).getInt(_lastKey);
      return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
    } catch (_) {
      return null;
    }
  }

  /// Whether the reminder is due: 30 days since the last backup (or, with
  /// none yet, since the app was first used), and not snoozed.
  Future<bool> reminderDue() async {
    try {
      final p = await _prefs;
      final now = clock();
      final first = p.getInt(_firstKey);
      if (first == null) {
        await p.setInt(_firstKey, now.millisecondsSinceEpoch);
        return false;
      }
      final last = p.getInt(_lastKey);
      final since = DateTime.fromMillisecondsSinceEpoch(last ?? first);
      if (now.difference(since) < kBackupReminderEvery) return false;
      final later = p.getInt(_laterKey);
      return later == null ||
          now.isAfter(DateTime.fromMillisecondsSinceEpoch(later));
    } catch (_) {
      return false;
    }
  }

  Future<void> snooze() async {
    try {
      await (await _prefs).setInt(
        _laterKey,
        clock().add(kBackupLaterFor).millisecondsSinceEpoch,
      );
    } catch (_) {}
  }

  Future<void> _markDone() async {
    try {
      final p = await _prefs;
      await p.setInt(_lastKey, clock().millisecondsSinceEpoch);
      await p.remove(_laterKey);
    } catch (_) {}
  }

  /// Asks for a passphrase twice, seals the data and opens the share sheet.
  Future<bool> backUp(BuildContext context) async {
    final pass = await _askNewPassphrase(context, appName);
    if (pass == null || !context.mounted) return false;
    final messenger = ScaffoldMessenger.of(context);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _Working('Sealing your backup…'),
    );
    String sealed;
    try {
      sealed = await sealBackup(
        appKey,
        exportJson(),
        pass,
        iterations: iterations,
        now: clock(),
      );
    } finally {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
    }
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${backupFileName(appKey, clock())}');
    await file.writeAsString(sealed);
    final result = await Share.shareXFiles([
      XFile(file.path, mimeType: 'application/octet-stream'),
    ], subject: '$appName backup');
    if (result.status == ShareResultStatus.dismissed) return false;
    await _markDone();
    messenger.showSnackBar(
      const SnackBar(
        content: Text(
          'Backup made. Keep the file somewhere safe, and remember your '
          'passphrase.',
        ),
      ),
    );
    return true;
  }

  /// Picks a backup file, asks for its passphrase, and puts it back.
  Future<bool> restore(BuildContext context) async {
    final picked = await FilePicker.platform.pickFiles(withData: true);
    final bytes = picked?.files.single.bytes;
    if (bytes == null || !context.mounted) return false;
    final text = utf8.decode(bytes, allowMalformed: true);
    final messenger = ScaffoldMessenger.of(context);
    final app = backupAppOf(text);
    if (app == null || app != appKey) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            app == null
                ? 'That file is not a Véda backup.'
                : app == 'veda-all'
                ? 'That is the master backup of all your apps. Restore it from '
                      'Véda: Profile, Your data, Restore all my apps.'
                : 'That backup belongs to a different Véda app.',
          ),
        ),
      );
      return false;
    }
    final pass = await _askPassphrase(context);
    if (pass == null || !context.mounted) return false;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _Working('Opening your backup…'),
    );
    String json;
    try {
      json = await openBackup(appKey, text, pass);
    } on BackupException catch (e) {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
      return false;
    }
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
    if (!context.mounted) return false;
    final sure = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Replace what is in $appName?'),
        content: const Text(
          'Everything in this app now is replaced by the backup. This cannot '
          'be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (sure != true) return false;
    try {
      await restoreJson(json);
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('That backup could not be restored.')),
      );
      return false;
    }
    messenger.showSnackBar(const SnackBar(content: Text('Restored.')));
    return true;
  }
}

class _Working extends StatelessWidget {
  const _Working(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => AlertDialog(
    content: Row(
      children: [
        const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 16),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

Future<String?> _askPassphrase(BuildContext context) {
  final c = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (d) => AlertDialog(
      title: const Text('Passphrase'),
      content: TextField(
        controller: c,
        obscureText: true,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'The passphrase you chose for this backup',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(d),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(d, c.text),
          child: const Text('Open'),
        ),
      ],
    ),
  );
}

Future<String?> _askNewPassphrase(BuildContext context, String appName) {
  final a = TextEditingController();
  final b = TextEditingController();
  String? problem;
  return showDialog<String>(
    context: context,
    builder: (d) => StatefulBuilder(
      builder: (d, setState) => AlertDialog(
        title: const Text('Choose a passphrase'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your $appName backup is sealed with it. Nobody can open the '
                'file without it, including us, and there is no way to recover '
                'a forgotten one. At least 8 characters.',
                style: const TextStyle(fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: a,
                obscureText: true,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Passphrase'),
              ),
              TextField(
                controller: b,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Again'),
              ),
              if (problem != null) ...[
                const SizedBox(height: 8),
                Text(
                  problem!,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (a.text.length < 8) {
                setState(() => problem = 'Use at least 8 characters.');
              } else if (a.text != b.text) {
                setState(() => problem = 'The two do not match.');
              } else {
                Navigator.pop(d, a.text);
              }
            },
            child: const Text('Back up'),
          ),
        ],
      ),
    ),
  );
}

/// "Nothing here is backed up automatically…" with when it last was, and the
/// two actions. Lives in each app's Profile, always.
class BackupCard extends StatefulWidget {
  const BackupCard({super.key, required this.controller});

  final BackupController controller;

  @override
  State<BackupCard> createState() => _BackupCardState();
}

class _BackupCardState extends State<BackupCard> {
  DateTime? _last;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final last = await widget.controller.lastBackup();
    if (mounted) setState(() => _last = last);
  }

  String _lastWords() {
    final l = _last;
    if (l == null) return 'You have not made a backup yet.';
    return 'Last backed up ${l.day}/${l.month}/${l.year}.';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return CardBox(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
            child: Text(
              'Nothing here is backed up automatically. Make a backup now and '
              'then, and keep the file somewhere safe, or you could lose '
              'everything if you lose or reset this phone. ${_lastWords()}',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.5,
                color: colors.textSecondary,
              ),
            ),
          ),
          ProfileRow(
            icon: PhosphorIconsThin.export,
            title: 'Back up',
            subtitle: 'One file, sealed with a passphrase you choose.',
            onTap: () async {
              await widget.controller.backUp(context);
              await _refresh();
            },
          ),
          ProfileRow(
            icon: PhosphorIconsThin.downloadSimple,
            title: 'Restore from a backup',
            subtitle: 'Replaces what is in this app now.',
            onTap: () async {
              await widget.controller.restore(context);
              await _refresh();
            },
          ),
        ],
      ),
    );
  }
}

/// A gentle reminder at the top of Today, once a month, while there is no
/// recent backup. "Later" waits two weeks.
class BackupNudge extends StatefulWidget {
  const BackupNudge({super.key, required this.controller});

  final BackupController controller;

  @override
  State<BackupNudge> createState() => _BackupNudgeState();
}

class _BackupNudgeState extends State<BackupNudge> {
  bool _due = false;

  @override
  void initState() {
    super.initState();
    widget.controller.reminderDue().then((v) {
      if (mounted) setState(() => _due = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_due) return const SizedBox.shrink();
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: CardBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time for a backup?',
              style: TextStyle(fontSize: 15, color: colors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              'Nothing here is saved anywhere but this phone. A backup file '
              'keeps your data safe if you lose it.',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: colors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton(
                  onPressed: () async {
                    final done = await widget.controller.backUp(context);
                    if (done && mounted) setState(() => _due = false);
                  },
                  child: const Text('Back up'),
                ),
                TextButton(
                  onPressed: () async {
                    await widget.controller.snooze();
                    if (mounted) setState(() => _due = false);
                  },
                  child: const Text('Later'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
