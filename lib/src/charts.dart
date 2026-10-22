// The charts the companion apps draw from Véda's readings and their own
// entries. Charts live here, in the apps, never in Véda itself.
//
// Descriptive only: an average on days with both a reading and an entry, with
// how many days it rests on. Every chart says it shows a difference and not a
// cause, because a handful of days can look like a pattern and prove nothing.

import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'brand.dart';
import 'common.dart';
import 'theme.dart';

/// "A difference, not proof of a cause."
class ChartCaveat extends StatelessWidget {
  const ChartCaveat(this.extra, {super.key});

  /// What the figures rest on, e.g. "Days with both a Véda reading and a check-in."
  final String extra;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(2, 10, 2, 0),
    child: Text(
      '$extra A difference, not proof of a cause.',
      style: TextStyle(
        fontSize: 11.5,
        height: 1.4,
        color: context.colors.textMuted,
      ),
    ),
  );
}

/// One day on the trend chart.
class TrendDay {
  const TrendDay(this.day, {this.score, this.bar, this.marked = false});

  final DateTime day;

  /// The day's average Skin Score.
  final double? score;

  /// A second series drawn as bars (UV peak).
  final double? bar;

  /// A dot under the day (sunscreen on).
  final bool marked;
}

/// The Skin Score as a gold line over bars and dots from the app's own data.
class TrendChart extends StatelessWidget {
  const TrendChart({
    super.key,
    required this.days,
    required this.barLabel,
    required this.markLabel,
  });

  final List<TrendDay> days;
  final String barLabel;
  final String markLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Widget key(Widget swatch, String t) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        swatch,
        const SizedBox(width: 6),
        Text(t, style: TextStyle(fontSize: 12, color: colors.textSecondary)),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 170,
          width: double.infinity,
          child: CustomPaint(painter: _TrendPainter(days, colors)),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 6,
          children: [
            key(
              Container(width: 20, height: 3, color: colors.accent),
              'Skin Score',
            ),
            key(
              Container(
                width: 12,
                height: 11,
                decoration: BoxDecoration(
                  color: colors.textMuted.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              barLabel,
            ),
            key(
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: colors.accentText,
                  shape: BoxShape.circle,
                ),
              ),
              markLabel,
            ),
          ],
        ),
      ],
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter(this.days, this.colors);

  final List<TrendDay> days;
  final AppColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    if (days.isEmpty) return;
    final n = days.length;
    final w = size.width / n;
    final plotH = size.height - 22; // room for the dots underneath
    final maxBar = days
        .map((d) => d.bar ?? 0)
        .fold<double>(0, (a, b) => a > b ? a : b);

    // Bars first, so the line sits on top.
    final barPaint = Paint()..color = colors.textMuted.withValues(alpha: 0.55);
    for (var i = 0; i < n; i++) {
      final b = days[i].bar;
      if (b == null || maxBar == 0) continue;
      final h = (b / maxBar) * plotH * 0.55;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(i * w + 1.5, plotH - h, w - 3, h),
          const Radius.circular(2),
        ),
        barPaint,
      );
    }

    // The score line: scaled to the range actually seen, with a little air.
    final scores = [
      for (final d in days)
        if (d.score != null) d.score!,
    ];
    if (scores.isNotEmpty) {
      var lo = scores.reduce((a, b) => a < b ? a : b);
      var hi = scores.reduce((a, b) => a > b ? a : b);
      if (hi - lo < 12) {
        final mid = (hi + lo) / 2;
        lo = mid - 6;
        hi = mid + 6;
      }
      double y(double s) =>
          plotH - ((s - lo) / (hi - lo)) * plotH * 0.9 - plotH * 0.05;
      final line = Paint()
        ..color = colors.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round;
      final path = Path();
      Offset? last;
      var started = false;
      for (var i = 0; i < n; i++) {
        final s = days[i].score;
        if (s == null) continue;
        final p = Offset(i * w + w / 2, y(s));
        if (!started) {
          path.moveTo(p.dx, p.dy);
          started = true;
        } else {
          path.lineTo(p.dx, p.dy);
        }
        last = p;
      }
      canvas.drawPath(path, line);
      if (last != null)
        canvas.drawCircle(last, 5.5, Paint()..color = kMarkerWhite);
    }

    // Dots under the days that are marked.
    final dot = Paint()..color = colors.accentText;
    for (var i = 0; i < n; i++) {
      if (days[i].marked) {
        canvas.drawCircle(Offset(i * w + w / 2, size.height - 6), 3, dot);
      }
    }
  }

  @override
  bool shouldRepaint(_TrendPainter old) =>
      old.days != days || old.colors != colors;
}

/// The card around a chart, with its title and a quiet explainer, and the
/// gentle empty state when there is nothing to chart yet.
class ChartCard extends StatelessWidget {
  const ChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.empty,
  });

  final String title;
  final String subtitle;
  final Widget child;

  /// Shown instead of [child] when there is nothing to chart yet.
  final String? empty;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return CardBox(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontFamily: kDisplayFont,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12.5, color: colors.textMuted),
          ),
          const SizedBox(height: 12),
          if (empty != null)
            Text(
              empty!,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.45,
                color: colors.textSecondary,
              ),
            )
          else
            child,
        ],
      ),
    );
  }
}

/// The app's own mark, wordmark and the meaning of the name, at the bottom of
/// Profile, as in Véda (profile_screen.dart): a quiet footer, not tappable.
class BrandFooter extends StatelessWidget {
  const BrandFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final brand = VedaBrandScope.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(brand.markAsset, width: 140, height: 140),
            const SizedBox(height: 8),
            Text(
              'VÉDA ${brand.word}',
              style: TextStyle(
                fontSize: 20,
                fontFamily: kDisplayFont,
                letterSpacing: 2.5,
                color: colors.textPrimary,
                height: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: kDisplayFont,
                  color: colors.textMuted,
                ),
                children: const [
                  TextSpan(
                    text: '/VAY-duh/ ',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  TextSpan(text: '· noun'),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Sanskrit: sacred knowledge; wisdom.',
              style: TextStyle(
                fontSize: 10.5,
                fontFamily: kDisplayFont,
                letterSpacing: 0.2,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
