// The forest friends on screen, shared by every app that has them: one
// friend's sheet, the short peek shown on a Profile card, and the full page
// with everyone on it (name, what kind of animal, and a line about them).
//
// The Profile card stays short on purpose: the switch, a few faces and a
// "Meet all" row. The whole cast lives on its own page.

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'app_colors.dart';
import 'brand.dart';
import 'forest_friends.dart';
import 'theme.dart';

/// A friend's story as a sheet from the bottom. [extras] go under the story,
/// above the meaning of the name (Kitchen puts where the friend cooks there).
void showForestFriendSheet(
  BuildContext context,
  ForestFriend f, {
  List<Widget> extras = const [],
}) {
  final colors = context.colors;
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: colors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          key: const Key('friendSheet'),
          mainAxisSize: MainAxisSize.min,
          children: [
            ForestHeadIcon(f.animal, special: f.special, size: 120),
            const SizedBox(height: 10),
            Text(
              f.name,
              style: TextStyle(
                fontSize: 26,
                fontFamily: kDisplayFont,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              f.kind,
              key: const Key('friendKind'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: colors.textSecondary),
            ),
            const SizedBox(height: 2),
            Text(
              f.line,
              style: TextStyle(fontSize: 13, color: colors.accentText),
            ),
            const SizedBox(height: 16),
            Text(
              f.story,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.55,
                color: colors.textSecondary,
              ),
            ),
            ...extras,
            if (f.means != null) ...[
              const SizedBox(height: 12),
              Text(
                f.means!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: colors.textMuted),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

/// A few faces and a "Meet all" row, for a Profile card. [onOpen] opens one
/// friend; [onSeeAll] opens the full page.
class ForestFriendsPeek extends StatelessWidget {
  const ForestFriendsPeek({
    super.key,
    required this.onOpen,
    required this.onSeeAll,
    this.count = 4,
  });

  final void Function(ForestFriend) onOpen;
  final VoidCallback onSeeAll;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shown = kForestFriends.take(count).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, box) {
            const gap = 8.0;
            final tile = (box.maxWidth - gap * (count - 1)) / count;
            return Row(
              children: [
                for (final (i, f) in shown.indexed) ...[
                  if (i > 0) const SizedBox(width: gap),
                  SizedBox(
                    width: tile,
                    child: InkWell(
                      key: Key('friend-${f.name}'),
                      onTap: () => onOpen(f),
                      customBorder: const StadiumBorder(),
                      child: Column(
                        children: [
                          ForestHeadIcon(
                            f.animal,
                            special: f.special,
                            size: tile * 0.9,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            f.name,
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 6),
        InkWell(
          key: const Key('allFriends'),
          onTap: onSeeAll,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Meet all ${kForestFriends.length} friends',
                    style: TextStyle(fontSize: 13.5, color: colors.accentText),
                  ),
                ),
                Icon(
                  PhosphorIconsThin.caretRight,
                  size: 16,
                  color: colors.accentText,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Everyone, four to a row: face and name. A tap opens the friend's sheet,
/// which says what kind of animal they are. [onOpen] defaults to that sheet.
class ForestFriendsPage extends StatelessWidget {
  const ForestFriendsPage({
    super.key,
    this.onOpen,
    this.intro =
        'They peek out from the trees now and then, and then duck back. '
        'Tap a friend to hear their story.',
  });

  final void Function(BuildContext context, ForestFriend friend)? onOpen;
  final String intro;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: colors.canvas,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        title: Text(
          'The Little Vedafolk',
          style: TextStyle(fontSize: 15, color: colors.textPrimary),
        ),
      ),
      body: CanvasBackdrop(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
          children: [
            Text(
              intro,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(14),
              ),
              child: LayoutBuilder(
                builder: (context, box) {
                  const gap = 8.0;
                  final tile = (box.maxWidth - gap * 3) / 4;
                  return Wrap(
                    spacing: gap,
                    runSpacing: 14,
                    children: [
                      for (final f in kForestFriends)
                        SizedBox(
                          width: tile,
                          child: InkWell(
                            key: Key('friendRow-${f.name}'),
                            onTap: () => (onOpen ?? _defaultOpen)(context, f),
                            customBorder: const StadiumBorder(),
                            child: Column(
                              children: [
                                ForestHeadIcon(
                                  f.animal,
                                  special: f.special,
                                  size: tile * 0.9,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  f.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Mei is shy and only comes out now and then.',
              style: TextStyle(fontSize: 12, color: colors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  static void _defaultOpen(BuildContext context, ForestFriend f) =>
      showForestFriendSheet(context, f);
}
