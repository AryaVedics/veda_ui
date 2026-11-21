// The two tiles pinned under Today in Véda Cycle and Véda Sleep: an icon and a
// label in a plain card, lit in the tile's own colour (with a soft glow) when
// what it stands for is done. One widget, so every app's tiles are the same.
// Any Today page that needs two buttons uses a pair of these, side by side.

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// One of the two tiles pinned under an app's Today page: an icon and a label,
/// lit when it is done.
class TodayTile extends StatelessWidget {
  const TodayTile({
    super.key,
    required this.icon,
    required this.label,
    required this.tint,
    required this.done,
    required this.onTap,
    this.compact = false,
  });

  final IconData icon;
  final String label;

  /// The icon beside the words instead of above them, for a short screen.
  final bool compact;

  /// The tile's own colour: lit in its fill and edge when it is done, and it
  /// glows then. Not done, it is a plain card.
  final Color tint;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = Text(
      label,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12.5,
        color: done ? colors.textPrimary : colors.textSecondary,
      ),
    );
    final glyph = Icon(icon, size: 18, color: done ? tint : colors.textMuted);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: compact ? 12 : 14),
        decoration: BoxDecoration(
          color: done ? Color.lerp(colors.card, tint, 0.14) : colors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: done ? tint.withValues(alpha: 0.6) : Colors.transparent,
          ),
          boxShadow: done
              ? [
                  BoxShadow(
                    color: tint.withValues(alpha: 0.35),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: compact
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  glyph,
                  const SizedBox(width: 8),
                  // wraps rather than running off the tile at large text
                  Flexible(child: text),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [glyph, const SizedBox(height: 6), text],
              ),
      ),
    );
  }
}
