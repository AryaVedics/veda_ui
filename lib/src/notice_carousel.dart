// The swipeable notice carousel the Véda apps share: short, honest messages
// on the bare canvas, one at a time, each with its own × to dismiss it for
// good. The same rules as Véda's Today tab: a message is shown once it
// first appears, stays for fourteen days from then, and is gone for good once
// dismissed. Each app passes in its own messages, keyed by [appKey].

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_colors.dart';
import 'mini_ring.dart';

/// How long a message stays after it is first shown.
const kNoticeLifetime = Duration(days: 14);

/// One message: a stable [id] (what its dismissal and first showing are
/// remembered under), its icon, and its text.
class NoticeMessage {
  const NoticeMessage(this.id, this.icon, this.text);

  final String id;
  final IconData icon;
  final String text;
}

/// Which of [messages] should show now, in order. Records the first showing of
/// each one it shows, so the fourteen days start then.
Future<List<NoticeMessage>> visibleNotices(
  String appKey,
  List<NoticeMessage> messages, {
  required DateTime now,
  SharedPreferences? prefs,
}) async {
  final store = prefs ?? await SharedPreferences.getInstance();
  final out = <NoticeMessage>[];
  for (final m in messages) {
    final dismissedKey = 'notice.$appKey.${m.id}.dismissed';
    if (store.getBool(dismissedKey) ?? false) continue;
    final shownKey = 'notice.$appKey.${m.id}.shownAt';
    final shownMs = store.getInt(shownKey);
    if (shownMs == null) {
      await store.setInt(shownKey, now.millisecondsSinceEpoch);
    } else if (now.difference(DateTime.fromMillisecondsSinceEpoch(shownMs)) >=
        kNoticeLifetime) {
      continue;
    }
    out.add(m);
  }
  return out;
}

/// Marks [m] dismissed for good in [appKey]'s messages.
Future<void> dismissNotice(
  String appKey,
  NoticeMessage m, {
  SharedPreferences? prefs,
}) async {
  final store = prefs ?? await SharedPreferences.getInstance();
  await store.setBool('notice.$appKey.${m.id}.dismissed', true);
}

/// The carousel itself.
///
/// Where it goes, in every Véda app (the rule, from Véda's own Today tab):
/// - At the top of Today, directly under the header and the date, and above the
///   centrepiece. Never at the bottom of the page and never in the scrolling
///   cards. Véda draws it in the row beside its Skin Score ring.
/// - Its size is Véda's: the app's mark on the left (about a third of the
///   width), then a message box 112 high with a 3px track beneath it,
///   no card behind it, an icon and a line of text, and a × to dismiss.
/// - New user messages go into this carousel, never into a card of their own
///   (see NOTICES.md). Shows nothing until its messages are worked out, and
/// takes no room at all when none are left to show.
class NoticeCarousel extends StatefulWidget {
  const NoticeCarousel({
    super.key,
    required this.appKey,
    required this.messages,
    required this.leading,
    this.now,
  });

  /// What sits at the left of the message box: the app's own ring, with its
  /// number for today (see MiniRing).
  final Widget leading;

  /// Which app these messages belong to, so their dismissals stay apart.
  final String appKey;
  final List<NoticeMessage> messages;

  /// The clock; tests pass a fixed one. Null means the real time.
  final DateTime? now;

  /// Véda's own size: the message box is 112 high, with a 3px track under it.
  static const _cardHeight = 112.0;
  static const _trackHeight = 3.0;

  @override
  State<NoticeCarousel> createState() => _NoticeCarouselState();
}

class _NoticeCarouselState extends State<NoticeCarousel> {
  List<NoticeMessage>? _shown;
  int _page = 0;
  final _controller = PageController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(NoticeCarousel old) {
    super.didUpdateWidget(old);
    if (old.appKey != widget.appKey || old.messages != widget.messages) {
      _load();
    }
  }

  Future<void> _load() async {
    final shown = await visibleNotices(
      widget.appKey,
      widget.messages,
      now: widget.now ?? DateTime.now(),
    );
    if (!mounted) return;
    setState(() {
      _shown = shown;
      _page = 0;
    });
  }

  Future<void> _dismiss(NoticeMessage m) async {
    await dismissNotice(widget.appKey, m);
    if (!mounted) return;
    setState(() {
      _shown = [
        for (final s in _shown ?? const <NoticeMessage>[])
          if (s.id != m.id) s,
      ];
      _page = 0;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shown = _shown;
    // Nothing until the first answer, and nothing taking up room when there is
    // nothing to show.
    if (shown == null || shown.isEmpty) return const SizedBox.shrink();
    final showTrack = shown.length > 1;
    // Véda's own layout: the ring at the left edge, a 20 gap, and the message
    // box in the rest of the row, both centred on the same line.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox.square(dimension: kMiniRingSize, child: widget.leading),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            children: [
              SizedBox(
                height: NoticeCarousel._cardHeight,
                child: PageView(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _page = i),
                  children: [for (final m in shown) _card(colors, m)],
                ),
              ),
              if (showTrack) ...[
                const SizedBox(height: 8),
                _track(colors, shown.length),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _card(AppColors colors, NoticeMessage m) => Container(
    // no side inset: the icon lines up with the title and the date above it,
    // and the × with the right edge
    padding: const EdgeInsets.symmetric(vertical: 7),
    alignment: Alignment.centerLeft,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(m.icon, size: 14, color: colors.accentText),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            m.text,
            style: TextStyle(
              fontSize: 11.5,
              color: colors.textSecondary,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(width: 5),
        GestureDetector(
          onTap: () => _dismiss(m),
          child: Icon(PhosphorIconsThin.x, size: 14, color: colors.textMuted),
        ),
      ],
    ),
  );

  // One continuous track, not a dot per message, so it never gets busier.
  Widget _track(AppColors colors, int total) => LayoutBuilder(
    builder: (context, constraints) {
      final segmentWidth = constraints.maxWidth * (1 / total).clamp(0.12, 1.0);
      final maxLeft = constraints.maxWidth - segmentWidth;
      final left = maxLeft * (_page / (total - 1));
      return Stack(
        children: [
          Container(
            height: NoticeCarousel._trackHeight,
            decoration: BoxDecoration(
              color: colors.divider,
              borderRadius: BorderRadius.circular(NoticeCarousel._trackHeight),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOut,
            left: left,
            child: Container(
              width: segmentWidth,
              height: NoticeCarousel._trackHeight,
              decoration: BoxDecoration(
                color: colors.accent,
                borderRadius: BorderRadius.circular(
                  NoticeCarousel._trackHeight,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
