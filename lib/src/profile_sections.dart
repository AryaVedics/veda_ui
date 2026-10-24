// The parts of Profile every companion app has: whether Véda's readings are
// coming in (Véda Link), exporting its data, deleting everything, and a few plain words about
// what the app is and is not.

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'app_colors.dart';
import 'backup.dart';
import 'common.dart';
import 'restore_inbox.dart';
import 'json_store.dart';

/// Export and delete, for the app's own data file.
class DataSection extends StatelessWidget {
  const DataSection({
    super.key,
    required this.appName,
    required this.store,
    required this.exportFileName,
    required this.backupKey,
    required this.whatIsDeleted,
    this.alsoDelete,
    this.restoreTarget,
  });

  final String appName;
  final JsonStore store;
  final String exportFileName;

  /// "cycle", "lifestyle", "sun": names the backup file and binds it to this app.
  final String backupKey;

  /// "Your sunscreen log and UV history are deleted from this phone."
  final String whatIsDeleted;

  /// Anything else to clear with it (the Véda readings, preferences).
  final Future<void> Function()? alsoDelete;

  /// Lets "Undo the last restore" appear after Véda has restored this app.
  final RestoreTarget? restoreTarget;

  Future<void> _delete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete everything?'),
        content: Text('$whatIsDeleted This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await store.deleteEverything();
    await alsoDelete?.call();
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Everything was deleted.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final backup = BackupController(
      appKey: backupKey,
      appName: appName,
      exportJson: store.exportJson,
      restoreJson: store.restoreJson,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BackupCard(controller: backup),
        if (restoreTarget != null) UndoRestoreRow(target: restoreTarget!),
        const SizedBox(height: 12),
        CardBox(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
          child: Column(
            children: [
              ProfileRow(
                icon: PhosphorIconsThin.export,
                title: 'Export my data',
                subtitle: 'Everything $appName holds, in a file you can read.',
                onTap: () => shareJsonFile(
                  exportFileName,
                  store.exportJson(),
                  'My $appName data',
                ),
              ),
              ProfileRow(
                icon: PhosphorIconsThin.trash,
                title: 'Delete everything',
                subtitle: 'From this phone. Nothing is kept anywhere else.',
                onTap: () => _delete(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A few plain sentences at the bottom of Profile.
class AboutNote extends StatelessWidget {
  const AboutNote(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 12.5,
        height: 1.5,
        color: context.colors.textMuted,
      ),
    ),
  );
}
