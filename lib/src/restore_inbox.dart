// The receiving end of Véda's "Restore all my apps".
//
// Véda (and only Véda, see VedaLinkProvider) can leave a file for this app. The
// next time the app is open (or comes back to the front) it finds that file,
// keeps a copy of what it holds now for 14 days (so the restore can be undone),
// puts the backup's data in place of it, and tells the person in one line. The
// person already chose this in Véda, after seeing what would be replaced, so
// the app does not ask again.
//
// Nothing here is automatic in the sense of "behind the person's back": a
// restore only ever exists because they made one in Véda by hand.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'common.dart';

/// Apps set this as their MaterialApp's scaffoldMessengerKey so a restore can
/// say it happened wherever the person is.
final GlobalKey<ScaffoldMessengerState> vedaMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

const _format = 'veda-restore/1';
const _pendingName = 'veda_restore_pending.json';
const _undoName = 'veda_before_restore.json';

/// How long the copy of what the app held before a restore is kept.
const kRestoreUndoFor = Duration(days: 14);

/// A restore left for the app but not complete or valid is dropped after this.
const _staleAfter = Duration(days: 1);

/// What an app lends to the inbox: its name, and how to read and replace its
/// data.
class RestoreTarget {
  const RestoreTarget({
    required this.appKey,
    required this.appName,
    required this.exportJson,
    required this.restoreJson,
  });

  /// "lifestyle", "sun", "routine": must match the app the restore is for.
  final String appKey;
  final String appName;
  final String Function() exportJson;
  final Future<void> Function(String json) restoreJson;
}

/// What a restore changed, for the line that tells the person.
class RestoreApplied {
  const RestoreApplied(this.backupMade);

  /// When the backup that was put back was made.
  final DateTime? backupMade;
}

class RestoreInbox {
  RestoreInbox._();

  /// Overrides for tests: where the files live, and the clock.
  static Directory? debugDir;
  static DateTime Function() clock = DateTime.now;

  static Future<Directory> _dir() async =>
      debugDir ?? await getApplicationSupportDirectory();

  /// Applies the restore Véda left, if there is one waiting. Never throws: a
  /// file that is incomplete (Véda may still be writing it) is simply left for
  /// the next look, and one that is wrong or stale is dropped.
  static Future<RestoreApplied?> applyIfWaiting(RestoreTarget target) async {
    try {
      final dir = await _dir();
      final pending = File('${dir.path}/$_pendingName');
      if (!await pending.exists()) return null;
      final Map<dynamic, dynamic> m;
      try {
        m = jsonDecode(await pending.readAsString()) as Map;
      } catch (_) {
        // Half written, or not ours. Wait, then give up on it.
        final age = clock().difference(await pending.lastModified());
        if (age > _staleAfter) await pending.delete();
        return null;
      }
      if (m['format'] != _format ||
          m['app'] != target.appKey ||
          m['json'] is! String) {
        await pending.delete();
        return null;
      }
      final json = m['json'] as String;
      // Make sure it is whole before anything is replaced.
      jsonDecode(json);
      // Keep what is here now, so the restore can be undone.
      await File('${dir.path}/$_undoName').writeAsString(
        jsonEncode({
          'format': _format,
          'app': target.appKey,
          'savedAt': clock().toUtc().toIso8601String(),
          'json': target.exportJson(),
        }),
        flush: true,
      );
      await target.restoreJson(json);
      await pending.delete();
      final made = DateTime.tryParse('${m['backupMade'] ?? ''}');
      vedaMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
            made == null
                ? 'Restored from your Véda backup. You can undo it in '
                      'Profile, Your data.'
                : 'Restored from your Véda backup of ${shortDate(made.toLocal())}. '
                      'You can undo it in Profile, Your data.',
          ),
        ),
      );
      return RestoreApplied(made);
    } catch (_) {
      return null;
    }
  }

  /// When the copy from before the last restore was made, or null if there is
  /// none (or it is older than [kRestoreUndoFor], which is then removed).
  static Future<DateTime?> undoAvailableSince() async {
    try {
      final dir = await _dir();
      final f = File('${dir.path}/$_undoName');
      if (!await f.exists()) return null;
      final m = jsonDecode(await f.readAsString()) as Map;
      final at = DateTime.tryParse('${m['savedAt']}');
      if (at == null || clock().difference(at) > kRestoreUndoFor) {
        await f.delete();
        return null;
      }
      return at.toLocal();
    } catch (_) {
      return null;
    }
  }

  /// Puts back what the app held before the last restore. False if there is
  /// nothing to put back.
  static Future<bool> undo(RestoreTarget target) async {
    try {
      final dir = await _dir();
      final f = File('${dir.path}/$_undoName');
      if (!await f.exists()) return false;
      final m = jsonDecode(await f.readAsString()) as Map;
      if (m['app'] != target.appKey || m['json'] is! String) return false;
      await target.restoreJson(m['json'] as String);
      await f.delete();
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// Profile's "Undo last restore" row; shows only while there is something to
/// undo.
class UndoRestoreRow extends StatefulWidget {
  const UndoRestoreRow({super.key, required this.target});

  final RestoreTarget target;

  @override
  State<UndoRestoreRow> createState() => _UndoRestoreRowState();
}

class _UndoRestoreRowState extends State<UndoRestoreRow> {
  DateTime? _since;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _look();
  }

  Future<void> _look() async {
    final since = await RestoreInbox.undoAvailableSince();
    if (mounted) {
      setState(() {
        _since = since;
        _loaded = true;
      });
    }
  }

  Future<void> _undo() async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Undo the restore in ${widget.target.appName}?'),
        content: const Text(
          'This puts back what the app held before the restore, and drops what '
          'the restore brought in.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Keep it'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Undo it'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final done = await RestoreInbox.undo(widget.target);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          done ? 'Back to how it was before the restore.' : 'Nothing to undo.',
        ),
      ),
    );
    await _look();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _since == null) return const SizedBox.shrink();
    final until = _since!.add(kRestoreUndoFor);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: CardBox(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
        child: ProfileRow(
          icon: PhosphorIconsThin.arrowCounterClockwise,
          title: 'Undo the last restore',
          subtitle:
              'Restored from Véda on ${shortDate(_since!)}. You can go back to '
              'how it was until ${shortDate(until)}.',
          onTap: _undo,
        ),
      ),
    );
  }
}
