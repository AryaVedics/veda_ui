// The Profile card for Véda Link: one master switch for the whole family, then
// one switch per app, with what each is doing right now in plain words.

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'app_colors.dart';
import 'common.dart';
import 'heart_pulse_icon.dart';
import 'link_bridge.dart';
import 'shelf_glyph.dart';
import 'theme.dart';
import 'veda_link.dart';

/// The Connect card. When every Véda app on this phone is linked and working
/// it folds down to one line (so it takes no room on Profile); it opens by
/// itself when an app needs attention or a new one turns up, and a tap on its
/// expand row opens or closes it. It folds only as Profile opens, never while
/// the person is flipping switches.
class LinkSection extends StatefulWidget {
  const LinkSection({
    super.key,
    required this.bridge,
    this.shares,
    this.reads,
    this.link,
    this.why,
  });

  final LinkBridge bridge;

  /// What this app publishes, in a few words: "your period days and the
  /// estimated phase". Null for an app that only reads.
  final String? shares;

  /// What this app does with the others' entries: "Shows your sleep and
  /// stress beside your cycle."
  /// Null for an app that only publishes.
  final String? reads;

  /// The Véda readings this app keeps, when it uses them: shown on Véda's own
  /// row, with a way to remove them from this app.
  final VedaLinkStore? link;

  /// What this app does with Véda's readings, in one line: "To show your Skin
  /// Score next to your sleep and water."
  final String? why;

  /// Each app's own tab icon, so the list looks like the apps it names.
  static Widget _iconFor(LinkApp app, Color color) => SizedBox.square(
    dimension: 22,
    child: FittedBox(
      child: switch (app) {
        LinkApp.lifestyle => HeartPulseIcon(selected: false, color: color),
        LinkApp.routine => ShelfGlyph(color: color),
        LinkApp.cycle => Icon(PhosphorIconsThin.flowerLotus, color: color),
        LinkApp.sun => Icon(PhosphorIconsThin.sun, color: color),
        LinkApp.skin => Image.asset(
          'packages/veda_ui/assets/branding/veda_mark.png',
          filterQuality: FilterQuality.medium,
        ),
      },
    ),
  );

  @override
  State<LinkSection> createState() => _LinkSectionState();
}

class _LinkSectionState extends State<LinkSection> {
  /// Null until the card has seen the apps' statuses once; then whether the
  /// person (or the first look) left it open.
  bool? _open;

  LinkBridge get bridge => widget.bridge;

  bool _installed(LinkApp app) {
    final st = bridge.readOf(app).status;
    return st != LinkStatus.notInstalled &&
        st != LinkStatus.unknown &&
        st != LinkStatus.notRead;
  }

  /// An installed app that is not linked, or linked but not working.
  LinkApp? _attention(List<LinkApp> installed) {
    for (final app in installed) {
      if (!bridge.isLinked(app) ||
          bridge.readOf(app).status != LinkStatus.connected) {
        return app;
      }
    }
    return null;
  }

  String _words(LinkApp app, LinkRead r) {
    if (!bridge.isLinked(app)) return 'not linked';
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
        return 'installed, but not sharing with this app';
      case LinkStatus.notAllowed:
        return 'installed, but not allowed (different signing key)';
      case LinkStatus.notInstalled:
        return 'not installed';
      case LinkStatus.oldVersion:
        return 'installed, but this version does not share yet (needs an update)';
      case LinkStatus.noAnswer:
        return 'did not answer in time; open it once and come back';
      case LinkStatus.unlinked:
        return 'not linked';
      case LinkStatus.notRead:
        return 'linked';
      case LinkStatus.unknown:
        return 'checking…';
    }
  }

  void _whatIsShared(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('What is shared'),
        content: SingleChildScrollView(
          child: Text(
            bridge.readOnly
                ? 'This app shares nothing with any other app. Linking only '
                      'lets it read what the others choose to share.'
                      '${widget.reads == null ? '' : ' ${widget.reads}'}\n\n'
                      'It all stays on this phone: only Véda apps signed by us '
                      'can be read, and nothing is sent anywhere. Switch one '
                      'off and this app stops reading it; nothing else changes.'
                : 'This app shares ${widget.shares} with the apps you link.'
                      '${widget.reads == null ? '' : ' ${widget.reads}'}\n\n'
                      'It all stays on this phone: only Véda apps signed by us '
                      'can read it, and nothing is sent anywhere. A link is '
                      'two-way for a pair of apps; switch one off and that '
                      'pair stops sharing, nothing else changes.',
            style: const TextStyle(fontSize: 14, height: 1.45),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _forget(BuildContext context) async {
    await widget.link!.deleteEverything();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your Véda readings were removed from this app.'),
        ),
      );
    }
  }

  /// The extra lines under Véda's own row: what its readings are for, how many
  /// this app holds, and a way to remove them.
  Widget _vedaDetail(BuildContext context, AppColors colors) {
    final readings = widget.link!.data.readings;
    final live =
        bridge.use &&
        bridge.readOf(LinkApp.skin).status == LinkStatus.connected;
    final words = live
        ? (readings.isNotEmpty
              ? '${readings.length} readings, latest '
                    '${dayMonth(readings.last.takenAt)}. They update whenever '
                    'you open this app.'
              : 'Connected. Your readings appear here after your next scan in '
                    'Véda.')
        : '${widget.why ?? ''} In Véda: Profile, "Let my other Véda apps use '
              'my readings". Only dates and scores, kept on this phone.';
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(44, 0, 8, 6),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              words.trim(),
              style: TextStyle(
                fontSize: 12.5,
                height: 1.4,
                color: colors.textMuted,
              ),
            ),
          ),
        ),
        if (readings.isNotEmpty)
          ProfileRow(
            icon: PhosphorIconsThin.eraser,
            title: 'Remove my Véda readings',
            subtitle: 'From this app only. Véda keeps its own.',
            onTap: () => _forget(context),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListenableBuilder(
      listenable: Listenable.merge([
        bridge,
        if (widget.link != null) widget.link!,
      ]),
      builder: (context, _) {
        final others = bridge.others.toList();
        final installed = [
          for (final a in others)
            if (_installed(a)) a,
        ];
        final attention = _attention(installed);
        final statusKnown = others.any(
          (a) => bridge.readOf(a).status != LinkStatus.unknown,
        );
        // Decided once, as the card first sees real statuses: folded only if
        // everything installed is linked and working.
        if (_open == null && statusKnown) _open = attention != null;
        final canFold = installed.isNotEmpty;
        final open = !canFold || (_open ?? true) || attention != null;
        final n = bridge.linkedCount;
        final label = attention != null
            ? (bridge.isLinked(attention)
                  ? '${attention.name}: see below'
                  : '${attention.name} is not linked yet')
            : open
            ? 'Hide the apps'
            : installed.length == 1
            ? '${installed.first.name} is connected'
            : 'All ${installed.length} installed apps connected';
        return CardBox(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileRow(
                icon: PhosphorIconsThin.shareNetwork,
                title: 'Connect all my Véda apps',
                subtitle: n == 0
                    ? 'Not connected. Nothing is shared.'
                    : '$n of ${others.length} connected · on this phone only',
                trailing: Switch(
                  value: n > 0,
                  onChanged: (on) => bridge.connectAll(on),
                ),
              ),
              if (canFold) ...[
                Divider(height: 8, color: colors.accentDim),
                InkWell(
                  onTap: attention != null
                      ? null
                      : () => setState(() => _open = !open),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        for (final app in installed)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: CircleAvatar(
                              radius: 13,
                              backgroundColor: colors.cardSunken,
                              child: SizedBox.square(
                                dimension: 16,
                                child: FittedBox(
                                  child: LinkSection._iconFor(
                                    app,
                                    bridge.isLinked(app) &&
                                            bridge.readOf(app).status ==
                                                LinkStatus.connected
                                        ? colors.accentText
                                        : colors.textMuted,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        Icon(
                          open
                              ? PhosphorIconsThin.caretUp
                              : PhosphorIconsThin.caretDown,
                          size: 16,
                          color: colors.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (open) ...[
                Divider(height: 8, color: colors.accentDim),
                for (final app in others) ...[
                  ProfileRow(
                    iconWidget: LinkSection._iconFor(app, colors.accentText),
                    title: app.name,
                    subtitle:
                        '${app.gives}\n${_words(app, bridge.readOf(app))}',
                    trailing: Switch(
                      value: bridge.isLinked(app),
                      onChanged: (on) => bridge.setLinked(app, on),
                    ),
                  ),
                  if (app == LinkApp.skin && widget.link != null)
                    _vedaDetail(context, colors),
                ],
                // Véda Cycle shares nothing, so it has no switch and no feed:
                // it is listed only so the person can see it is not part of this.
                if (bridge.self != LinkApp.cycle)
                  ProfileRow(
                    key: const Key('linkCycleRow'),
                    iconWidget: LinkSection._iconFor(
                      LinkApp.cycle,
                      colors.textMuted,
                    ),
                    title: LinkApp.cycle.name,
                    subtitle: LinkApp.cycle.gives,
                  ),
                Divider(height: 8, color: colors.divider),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                  child: Text(
                    bridge.readOnly
                        ? 'Each switch lets this app read that one. This app '
                              'shares nothing with any of them.'
                        : 'Each switch links this app with that one, both ways. '
                              'Turn one off and the two stop sharing; nothing '
                              'else changes.',
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.45,
                      color: colors.textMuted,
                    ),
                  ),
                ),
                ProfileRow(
                  icon: PhosphorIconsThin.info,
                  title: 'What is shared',
                  onTap: () => _whatIsShared(context),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// The Connect card in a sheet, so it can be reached from the logo menu on
/// any screen.
Future<void> showLinkSheet(
  BuildContext context, {
  required WidgetBuilder section,
}) {
  final colors = context.colors;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: colors.canvas,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (c) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My other Véda apps',
              style: TextStyle(
                fontSize: 20,
                fontFamily: kDisplayFont,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            section(c),
          ],
        ),
      ),
    ),
  );
}

/// A one-line card showing something read from another Véda app.
class LinkNote extends StatelessWidget {
  const LinkNote({
    super.key,
    required this.icon,
    required this.text,
    required this.from,
  });

  final IconData icon;
  final String text;

  /// "Véda Cycle".
  final String from;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return CardBox(
      child: Row(
        children: [
          Icon(icon, color: colors.accentText),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(fontSize: 14.5, color: colors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  'from $from',
                  style: TextStyle(fontSize: 11.5, color: colors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
