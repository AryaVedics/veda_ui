// A quiet text tab, for choosing one of a few things (a group of days, an
// exercise): the name, a small line beneath it, and a short gold line under
// the one showing. No pill, no box. One with nothing in it is dimmed and
// cannot be picked.

import 'package:flutter/material.dart';

import 'app_colors.dart';

class QuietTab extends StatelessWidget {
  const QuietTab({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.sub,
    this.empty = false,
  });

  final String label;

  /// The small line beneath the name ("26 days").
  final String? sub;
  final bool empty;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: empty ? null : onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: selected
                    ? colors.accentText
                    : empty
                    ? colors.textMuted.withValues(alpha: 0.6)
                    : colors.textSecondary,
              ),
            ),
            if (sub != null) ...[
              const SizedBox(height: 2),
              Text(
                sub!,
                style: TextStyle(
                  fontSize: 11,
                  color: colors.textMuted.withValues(alpha: empty ? 0.6 : 1),
                ),
              ),
            ],
            const SizedBox(height: 5),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 1.5,
              width: selected ? 24 : 0,
              color: colors.accent,
            ),
          ],
        ),
      ),
    );
  }
}
