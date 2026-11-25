// The screens for shelf cards (shelf_card.dart): share a list of the products
// on your shelf as a small file, or add products from a card someone shared
// with you. Both are the person's own choice, step by step: a card is only a
// list, nothing is added unless it is picked, and nothing goes through a
// server.
//
// Shared by the apps that keep a shelf. The app supplies what is shared
// ([ShelfShareChoice]), how a card's text is made, and what adding does.

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';

import 'app_colors.dart';
import 'backup.dart' show readPickedBytes;
import 'common.dart';
import 'restore_inbox.dart' show vedaMessengerKey;
import 'shelf_card.dart';
import 'theme.dart';

/// Reads the text of a card file the person picks. Tests replace it.
@visibleForTesting
Future<String?> Function() pickShelfCardText = _pickText;

Future<String?> _pickText() async {
  final r = await FilePicker.platform.pickFiles(
    type: FileType.any,
    withData: false,
  );
  final f = r?.files.single;
  if (f == null) return null;
  final bytes = await readPickedBytes(f);
  return bytes == null ? null : utf8.decode(bytes, allowMalformed: true);
}

void _say(String text) =>
    vedaMessengerKey.currentState?.showSnackBar(SnackBar(content: Text(text)));

/// The two rows that open the share and add screens, with a note on what a
/// card is.
class ShelfCardsPanel extends StatelessWidget {
  const ShelfCardsPanel({
    super.key,
    required this.appName,
    required this.onShare,
    required this.onAdd,
  });

  /// What the app calls itself in the note ("Routine", "Véda Hair").
  final String appName;
  final VoidCallback onShare;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return CardBox(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileRow(
            icon: PhosphorIconsThin.paperPlaneTilt,
            title: 'Share my shelf as a card',
            subtitle: 'Pick the products and share a small file.',
            onTap: onShare,
          ),
          ProfileRow(
            icon: PhosphorIconsThin.downloadSimple,
            title: 'Add products from a card',
            subtitle: 'Open a card someone shared with you.',
            onTap: onAdd,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
            child: Text(
              'A card is only a list of products someone chose to share. '
              '$appName does not recommend anything, and nothing is added '
              'unless you pick it.',
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: colors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ sharing

/// One product the person can put on a card.
class ShelfShareChoice {
  const ShelfShareChoice({
    required this.id,
    required this.name,
    required this.kindLabel,
  });

  final String id;
  final String name;
  final String kindLabel;
}

/// Opens the sheet that picks the products for a card and shares the file.
/// [cardText] makes the card's text for the chosen ids and the "from" line.
Future<void> showShelfShareSheet(
  BuildContext context, {
  required List<ShelfShareChoice> choices,
  required String whatIsShared,
  required String Function(Set<String> chosen, String from) cardText,
}) {
  if (choices.isEmpty) {
    _say('Add products to your shelf first.');
    return Future.value();
  }
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _ShareSheet(
      choices: choices,
      whatIsShared: whatIsShared,
      cardText: cardText,
    ),
  );
}

class _ShareSheet extends StatefulWidget {
  const _ShareSheet({
    required this.choices,
    required this.whatIsShared,
    required this.cardText,
  });

  final List<ShelfShareChoice> choices;
  final String whatIsShared;
  final String Function(Set<String> chosen, String from) cardText;

  @override
  State<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<_ShareSheet> {
  late final Set<String> _chosen = {for (final c in widget.choices) c.id};
  final _from = TextEditingController();

  @override
  void dispose() {
    _from.dispose();
    super.dispose();
  }

  Future<void> _share() async {
    final text = widget.cardText({..._chosen}, _from.text);
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/shelf-card.json');
      await file.writeAsString(text, flush: true);
      await Share.shareXFiles([
        XFile(file.path, mimeType: 'application/json'),
      ], subject: 'Shelf card');
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      _say('Could not make the card. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Share my shelf as a card',
                style: TextStyle(
                  fontSize: 21,
                  fontFamily: kDisplayFont,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.whatIsShared,
                style: TextStyle(fontSize: 12.5, color: colors.textMuted),
              ),
              const SizedBox(height: 10),
              for (final c in widget.choices)
                CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  value: _chosen.contains(c.id),
                  title: Text(
                    c.name,
                    style: TextStyle(color: colors.textPrimary),
                  ),
                  subtitle: Text(
                    c.kindLabel,
                    style: TextStyle(color: colors.textMuted, fontSize: 12.5),
                  ),
                  onChanged: (v) => setState(() {
                    if (v ?? false) {
                      _chosen.add(c.id);
                    } else {
                      _chosen.remove(c.id);
                    }
                  }),
                ),
              const SizedBox(height: 8),
              TextField(
                controller: _from,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'From (optional), for example your name',
                ),
              ),
              const SizedBox(height: 16),
              GoldButton(
                label: 'Share card',
                onPressed: _chosen.isEmpty ? null : _share,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------- adding

/// Picks a card file, reads it with [decode] and opens a preview of it. [add]
/// puts the chosen entries on the shelf and says how many were added.
Future<void> addFromShelfCardFile(
  BuildContext context, {
  required ShelfCardData? Function(String text) decode,
  required String Function(ShelfCardEntry) subtitle,
  required Future<int> Function(List<ShelfCardEntry> chosen) add,
}) async {
  final text = await pickShelfCardText();
  if (text == null || !context.mounted) return;
  final card = decode(text);
  if (card == null) {
    _say('That file is not a shelf card.');
    return;
  }
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) =>
        ShelfCardPreviewSheet(card: card, subtitle: subtitle, add: add),
  );
}

/// What is on a card, with a box per product. None is ticked to begin with:
/// nothing is added until the person picks it.
class ShelfCardPreviewSheet extends StatefulWidget {
  const ShelfCardPreviewSheet({
    super.key,
    required this.card,
    required this.subtitle,
    required this.add,
  });

  final ShelfCardData card;

  /// The small line under a product's name.
  final String Function(ShelfCardEntry) subtitle;

  /// Adds the chosen entries to the shelf; returns how many were added.
  final Future<int> Function(List<ShelfCardEntry> chosen) add;

  @override
  State<ShelfCardPreviewSheet> createState() => _ShelfCardPreviewSheetState();
}

class _ShelfCardPreviewSheetState extends State<ShelfCardPreviewSheet> {
  final Set<int> _picked = {};

  Future<void> _add() async {
    final items = [
      for (var i = 0; i < widget.card.entries.length; i++)
        if (_picked.contains(i)) widget.card.entries[i],
    ];
    final n = await widget.add(items);
    if (!mounted) return;
    Navigator.of(context).pop();
    _say(
      n == 0
          ? 'Those are already on your shelf.'
          : 'Added $n ${n == 1 ? 'product' : 'products'} to your shelf.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final card = widget.card;
    final all = _picked.length == card.entries.length;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card.from == null
                    ? 'A shelf card'
                    : 'A shelf card from ${card.from}',
                style: TextStyle(
                  fontSize: 21,
                  fontFamily: kDisplayFont,
                  color: colors.textPrimary,
                ),
              ),
              if (card.note != null) ...[
                const SizedBox(height: 6),
                Text(
                  card.note!,
                  style: TextStyle(fontSize: 13.5, color: colors.textSecondary),
                ),
              ],
              const SizedBox(height: 6),
              Text(
                'Pick the products you want on your shelf. Nothing is added '
                'unless you pick it, and this is a list, not advice.',
                style: TextStyle(fontSize: 12.5, color: colors.textMuted),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => setState(() {
                    if (all) {
                      _picked.clear();
                    } else {
                      _picked.addAll([
                        for (var i = 0; i < card.entries.length; i++) i,
                      ]);
                    }
                  }),
                  child: Text(
                    all ? 'Clear' : 'Select all',
                    style: TextStyle(color: colors.accentText),
                  ),
                ),
              ),
              for (var i = 0; i < card.entries.length; i++)
                CheckboxListTile(
                  key: Key('cardItem$i'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  value: _picked.contains(i),
                  title: Text(
                    card.entries[i].displayName,
                    style: TextStyle(color: colors.textPrimary),
                  ),
                  subtitle: Text(
                    widget.subtitle(card.entries[i]),
                    style: TextStyle(color: colors.textMuted, fontSize: 12.5),
                  ),
                  onChanged: (v) => setState(() {
                    if (v ?? false) {
                      _picked.add(i);
                    } else {
                      _picked.remove(i);
                    }
                  }),
                ),
              const SizedBox(height: 14),
              GoldButton(
                label: _picked.isEmpty
                    ? 'Pick products to add'
                    : 'Add ${_picked.length} to my shelf',
                onPressed: _picked.isEmpty ? null : _add,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
