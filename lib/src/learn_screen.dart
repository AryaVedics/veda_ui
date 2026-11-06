// Copy of Véda's template (flutter_app/lib/screens/learn_screen.dart). Keep in step.
// Learn: short, general notes about everyday skin habits and good-to-know
// facts, grouped by theme. Reached from the top of Trends, where it sits above
// the scores on purpose, so it is read first and is not tied to any one number.
//
// Everything here is descriptive, never advice (see learn_content.dart for the
// rules, and consent_screen.dart / score_info_screen.dart for the "not a
// medical device" wording this repeats, so the app never says it two ways).
//
// Each note is closed to its title and opens on a tap. [openId] opens one
// already, so a card elsewhere can point straight at a note.

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'app_colors.dart';
import 'brand.dart';
import 'learn_content.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key, this.openId});

  /// A note to show open when the page appears.
  final String? openId;

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
          'Learn',
          style: TextStyle(fontSize: 15, color: colors.textPrimary),
        ),
      ),
      body: CanvasBackdrop(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
          children: [
            Text(
              'Little things worth knowing about skin, kept short. These are '
              'general notes about what is commonly known or commonly done, '
              'not advice for you.',
              style: TextStyle(
                fontSize: 13.5,
                color: colors.textSecondary,
                height: 1.6,
              ),
            ),
            for (final category in LearnCategory.values) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(category.icon, size: 18, color: colors.accentText),
                  const SizedBox(width: 8),
                  Text(
                    category.title,
                    style: TextStyle(fontSize: 14, color: colors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    for (final (i, entry) in learnEntriesIn(
                      category,
                    ).indexed) ...[
                      if (i > 0) Divider(height: 1, color: colors.divider),
                      _EntryTile(entry: entry, startOpen: entry.id == openId),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 28),
            Text(
              'This is general information, not medical advice. If something '
              'changes suddenly or concerns you, that is a conversation for a '
              'doctor or dermatologist, not a note in this app.',
              style: TextStyle(
                fontSize: 12,
                color: colors.textMuted,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryTile extends StatefulWidget {
  const _EntryTile({required this.entry, required this.startOpen});

  final LearnEntry entry;
  final bool startOpen;

  @override
  State<_EntryTile> createState() => _EntryTileState();
}

class _EntryTileState extends State<_EntryTile> {
  late bool _open = widget.startOpen;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final e = widget.entry;
    return Semantics(
      button: true,
      expanded: _open,
      child: InkWell(
        key: Key('learn-${e.id}'),
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _open = !_open),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      e.title,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.35,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _open
                        ? PhosphorIconsThin.caretUp
                        : PhosphorIconsThin.caretDown,
                    size: 16,
                    color: colors.textMuted,
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: _open
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8, right: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.body,
                              key: Key('learn-body-${e.id}'),
                              style: TextStyle(
                                fontSize: 13.5,
                                height: 1.6,
                                color: colors.textSecondary,
                              ),
                            ),
                            if (e.sources.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Source: ${e.sources.join('; ')}',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  height: 1.45,
                                  color: colors.textMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
