// The Profile card for Véda Link: the two switches, and what each other app
// is doing right now, in plain words.

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'app_colors.dart';
import 'common.dart';
import 'link_bridge.dart';

class LinkSection extends StatelessWidget {
  const LinkSection({
    super.key,
    required this.bridge,
    required this.shares,
    this.reads,
  });

  final LinkBridge bridge;

  /// What this app publishes, in a few words: "your period days and the
  /// estimated phase".
  final String shares;

  /// What this app does with the others' entries: "Shows your sleep and
  /// stress beside your cycle."
  /// Null for an app that only publishes (no "use" switch is shown).
  final String? reads;

  String _words(LinkRead r) {
    switch (r.status) {
      case LinkStatus.connected:
        final ago = DateTime.now().difference(r.feed!.updatedAt);
        final when = ago.inMinutes < 1
            ? 'just now'
            : ago.inMinutes < 60
                ? '${ago.inMinutes} min ago'
                : ago.inHours < 24
                    ? '${ago.inHours} h ago'
                    : '${ago.inDays} days ago';
        return 'connected, updated $when';
      case LinkStatus.sharingOff:
        return 'installed, but sharing is off there';
      case LinkStatus.notAllowed:
        return 'installed, but not allowed (different signing key)';
      case LinkStatus.notInstalled:
        return 'not installed';
      case LinkStatus.unknown:
        return 'checking…';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListenableBuilder(
      listenable: bridge,
      builder: (context, _) => CardBox(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ProfileRow(
            icon: PhosphorIconsThin.shareNetwork,
            title: 'Share my entries with my other Véda apps',
            subtitle: 'Shares $shares. Only Véda apps signed by us can read it, '
                'on this phone. Nothing is sent anywhere.',
            trailing: Switch(value: bridge.share, onChanged: bridge.setShare),
          ),
          if (reads != null)
            ProfileRow(
              icon: PhosphorIconsThin.arrowsLeftRight,
              title: 'Use entries from my other Véda apps',
              subtitle: reads,
              trailing: Switch(value: bridge.use, onChanged: bridge.setUse),
            ),
          if (reads != null && bridge.use) ...[
            const SizedBox(height: 4),
            for (final app in bridge.others)
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 3, 4, 3),
                child: Text('${app.name}: ${_words(bridge.readOf(app))}',
                    style: TextStyle(fontSize: 12.5, color: colors.textMuted)),
              ),
          ],
        ]),
      ),
    );
  }
}

/// A one-line card showing something read from another Véda app.
class LinkNote extends StatelessWidget {
  const LinkNote({super.key, required this.icon, required this.text, required this.from});

  final IconData icon;
  final String text;

  /// "Véda Cycle".
  final String from;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return CardBox(
      child: Row(children: [
        Icon(icon, color: colors.accentText),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(text, style: TextStyle(fontSize: 14.5, color: colors.textPrimary)),
            const SizedBox(height: 2),
            Text('from $from',
                style: TextStyle(fontSize: 11.5, color: colors.textMuted)),
          ]),
        ),
      ]),
    );
  }
}
