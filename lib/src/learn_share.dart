// Copy of Véda's template (flutter_app/lib/screens/learn_share.dart). Keep in step.
//
// The card carries only the note, the name of the portal and the education-only
// line: no photo, no reading, nothing about the person. It is built from real
// widgets, shown first, and captured to a PNG for the share sheet, so leaving
// the app is something the person sees and confirms.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'app_colors.dart';
import 'learn_content.dart';
import 'learn_screen.dart' show LearnButton;
import 'theme.dart' show kDisplayFont;

/// Opens the card for [entry].
void openLearnShareCard(BuildContext context, LearnEntry entry) {
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => LearnShareScreen(entry: entry)));
}

class LearnShareScreen extends StatefulWidget {
  const LearnShareScreen({
    super.key,
    required this.entry,
    this.share,
    this.folder,
  });

  final LearnEntry entry;

  /// For tests: where the PNG is made, instead of the phone's temporary folder.
  final Directory? folder;

  /// For tests: takes the made PNG instead of the share sheet.
  final Future<void> Function(File file)? share;

  @override
  State<LearnShareScreen> createState() => _LearnShareScreenState();
}

class _LearnShareScreenState extends State<LearnShareScreen> {
  final _boundary = GlobalKey();
  bool _busy = false;

  Future<void> _send() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final box =
          _boundary.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      final image = await box.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw StateError('Could not make the card.');
      final dir = widget.folder ?? await getTemporaryDirectory();
      final file = File('${dir.path}/education-${widget.entry.id}.png');
      await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
      await (widget.share ?? _shareFile)(file);
    } catch (_) {
      // nothing left the app; the card is still here to try again
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _shareFile(File file) =>
      Share.shareXFiles([XFile(file.path, mimeType: 'image/png')]);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: colors.canvas,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        title: Text(
          'Share this note',
          style: TextStyle(fontSize: 15, color: colors.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: RepaintBoundary(
                key: _boundary,
                child: LearnNoteCard(entry: widget.entry),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Only this note is shared: no photo, no reading, nothing about you.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: colors.textMuted),
          ),
          const SizedBox(height: 14),
          LearnButton(
            key: const Key('learnShareSend'),
            label: _busy ? 'Making the card…' : 'Share',
            onPressed: _send,
          ),
        ],
      ),
    );
  }
}

/// The card itself.
class LearnNoteCard extends StatelessWidget {
  const LearnNoteCard({super.key, required this.entry});

  final LearnEntry entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: Container(
        padding: const EdgeInsets.fromLTRB(26, 26, 26, 22),
        decoration: BoxDecoration(
          color: colors.canvas,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.accent.withValues(alpha: 0.7)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'VÉDA EDUCATION',
              style: TextStyle(
                fontSize: 11.5,
                letterSpacing: 2.4,
                color: colors.accentText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              entry.category.title,
              style: TextStyle(fontSize: 12, color: colors.textMuted),
            ),
            const Spacer(),
            Text(
              entry.title,
              style: TextStyle(
                fontFamily: kDisplayFont,
                fontSize: 22,
                height: 1.25,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              entry.body,
              maxLines: 9,
              overflow: TextOverflow.fade,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.55,
                color: colors.textSecondary,
              ),
            ),
            if (entry.sources.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Source: ${entry.sources.join('; ')}',
                style: TextStyle(fontSize: 10.5, color: colors.textMuted),
              ),
            ],
            const Spacer(),
            Container(height: 1, color: colors.accent.withValues(alpha: 0.35)),
            const SizedBox(height: 10),
            Text(
              'For education only. Not medical advice.',
              style: TextStyle(fontSize: 10.5, color: colors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
