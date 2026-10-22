// The parts of Profile every companion app has: whether Véda's readings are
// coming in (Véda Link), exporting its data, deleting everything, and a few plain words about
// what the app is and is not.

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'app_colors.dart';
import 'common.dart';
import 'json_store.dart';
import 'link_bridge.dart';
import 'veda_link.dart';

/// "Véda": whether Véda's readings are coming in live, and how to switch that
/// on. The readings themselves arrive by Véda Link (see LinkRefresher); there
/// is nothing to import by hand.
class VedaLinkSection extends StatelessWidget {
  const VedaLinkSection({
    super.key,
    required this.link,
    required this.bridge,
    required this.why,
  });

  final VedaLinkStore link;
  final LinkBridge bridge;

  /// What this app does with them, in one line: "To chart them next to
  /// your sleep and water."
  final String why;

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
      listenable: Listenable.merge([link, bridge]),
      builder: (context, _) {
        final readings = link.data.readings;
        final has = readings.isNotEmpty;
        final live = bridge.use &&
            bridge.readOf(LinkApp.skin).status == LinkStatus.connected;
        return CardBox(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
          child: Column(
            children: [
              ProfileRow(
                icon: PhosphorIconsThin.sparkle,
                title: live ? 'Live from Véda' : 'Véda is not connected',
                subtitle: live
                    ? (has
                          ? '${readings.length} readings, latest '
                                '${dayMonth(readings.last.takenAt)}. They update '
                                'whenever you open this app.'
                          : 'Connected. Your readings appear here after your '
                                'next scan in Véda.')
                    : '$why In Véda: Profile, "Let my other Véda apps use my '
                          'readings". Here: switch on "Use entries from my '
                          'other Véda apps" above. Only dates and scores, kept '
                          'on this phone.',
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
