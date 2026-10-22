// The parts of Profile every companion app has: its Véda readings (Véda
// Link), exporting its data, deleting everything, and a few plain words about
// what the app is and is not.

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'app_colors.dart';
import 'common.dart';
import 'json_store.dart';
import 'veda_link.dart';

/// "Your Véda readings": bring them in from Véda's export, or forget them.
class VedaLinkSection extends StatelessWidget {
  const VedaLinkSection({super.key, required this.link, required this.why});

  final VedaLinkStore link;

  /// What this app does with them, in one line: "To chart them next to
  /// your sleep and water."
  final String why;

  Future<void> _import(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final n = await link.pickAndImport();
      if (n == null) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            n == 1 ? '1 reading brought in.' : '$n readings brought in.',
          ),
        ),
      );
    } on FormatException {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'That file is not a Véda export. In Véda, use '
            'Profile, Export my data.',
          ),
        ),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('The file could not be read.')),
      );
    }
  }

  Future<void> _forget(BuildContext context) async {
    await link.deleteEverything();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your Véda readings were removed from this app.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: link,
      builder: (context, _) {
        final readings = link.data.readings;
        final has = readings.isNotEmpty;
        return CardBox(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
          child: Column(
            children: [
              ProfileRow(
                icon: PhosphorIconsThin.sparkle,
                title: has
                    ? 'Update my Véda readings'
                    : 'Bring in my Véda readings',
                subtitle: has
                    ? '${readings.length} readings, up to ${dayMonth(readings.last.takenAt)}. '
                          'In Véda: Profile, Export my data, then pick the file here.'
                    : '$why In Véda: Profile, Export my data, then pick the file here. '
                          'Only the dates and scores are kept, on this phone.',
                onTap: () => _import(context),
              ),
              if (has)
                ProfileRow(
                  icon: PhosphorIconsThin.eraser,
                  title: 'Remove my Véda readings',
                  subtitle: 'From this app only. Véda keeps its own.',
                  onTap: () => _forget(context),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Export and delete, for the app's own data file.
class DataSection extends StatelessWidget {
  const DataSection({
    super.key,
    required this.appName,
    required this.store,
    required this.exportFileName,
    required this.whatIsDeleted,
    this.alsoDelete,
  });

  final String appName;
  final JsonStore store;
  final String exportFileName;

  /// "Your sunscreen log and UV history are deleted from this phone."
  final String whatIsDeleted;

  /// Anything else to clear with it (the Véda readings, preferences).
  final Future<void> Function()? alsoDelete;

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
    return CardBox(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: Column(
        children: [
          ProfileRow(
            icon: PhosphorIconsThin.export,
            title: 'Export my data',
            subtitle: 'Everything $appName holds, in one file.',
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
