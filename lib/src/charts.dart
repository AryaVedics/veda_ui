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
import 'scaled_box.dart';
import 'chart_gradient.dart';
import 'chart_carousel.dart';

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
    this.barLabel,
    this.markLabel,
  });

  final List<TrendDay> days;

  /// What the bars are, and what the dots are; null leaves that out of the key.
  final String? barLabel;
  final String? markLabel;

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
        ScaledBox(
          designWidth: 350,
          designHeight: 170,
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
            if (barLabel != null)
              key(
                Container(
                  width: 12,
                  height: 11,
                  decoration: BoxDecoration(
                    color: colors.textMuted.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                barLabel!,
              ),
            if (markLabel != null)
              key(
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: colors.accentText,
                    shape: BoxShape.circle,
                  ),
                ),
                markLabel!,
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

    // Faint guides at 0, 50 and 100, as Véda's own Trends chart has.
    final grid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = colors.divider;
    for (final v in const [0.0, 50.0, 100.0]) {
      final gy = _scoreY(v, plotH);
      canvas.drawLine(Offset(0, gy), Offset(size.width, gy), grid);
    }
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

    // The score line, on the same fixed 0-100 range as Véda's own chart, so a
    // few points either way read as the small change they are.
    final scores = [
      for (final d in days)
        if (d.score != null) d.score!,
    ];
    if (scores.isNotEmpty) {
      double y(double s) => _scoreY(s, plotH);
      final line = Paint()
        ..color = colors.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round;
      final points = <Offset>[];
      for (var i = 0; i < n; i++) {
        final s = days[i].score;
        if (s == null) continue;
        points.add(Offset(i * w + w / 2, y(s)));
      }
      final last = points.isEmpty ? null : points.last;
      if (points.isNotEmpty && points.first.dx > w) {
        _drawDashedLine(
          canvas,
          Offset(0, points.first.dy),
          Offset(points.first.dx, points.first.dy),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = colors.accent.withValues(alpha: 0.4),
        );
      }
      final path = _smoothPath(points);
      // The line fades from faint at the oldest reading to full at the latest.
      final x0 = points.isEmpty ? 0.0 : points.first.dx;
      final x1 = points.isEmpty ? 1.0 : points.last.dx;
      if (x1 - x0 > 1) {
        line.shader = fadeAcross(colors.accent)
            .createShader(Rect.fromLTRB(x0, 0, x1, size.height));
      }
      canvas.drawPath(path, line);
      // a dot on every reading and a ringed marker on the latest, as Véda's
      // own Trends chart draws them, each as strong as the line beside it
      for (final p in points.take(points.length - 1)) {
        final t = x1 - x0 > 1 ? ((p.dx - x0) / (x1 - x0)).clamp(0.0, 1.0) : 1.0;
        canvas.drawCircle(
          p,
          4,
          Paint()
            ..color = Color.lerp(fadeStart(colors.accent), colors.accent, t)!,
        );
      }
      if (last != null) {
        canvas.drawCircle(last, 5, Paint()..color = kMarkerWhite);
        canvas.drawCircle(
          last,
          7.5,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.3
            ..color = kMarkerWhite.withValues(alpha: 0.7),
        );
      }
    }

    // Dots under the days that are marked.
    final dot = Paint()..color = colors.accentText;
    for (var i = 0; i < n; i++) {
      if (days[i].marked) {
        canvas.drawCircle(Offset(i * w + w / 2, size.height - 6), 3, dot);
      }
    }
  }

  /// Where a score sits: 0 at the bottom and 100 at the top of the plot, with
  /// a little room above and below (as Véda's Trends chart).
  static double _scoreY(double score, double plotH) =>
      12 + (plotH - 24) * (1 - (score / 100).clamp(0.0, 1.0));

  /// A dashed line, for the stretch before the first reading.
  void _drawDashedLine(Canvas canvas, Offset from, Offset to, Paint paint) {
    const dash = 5.0, gap = 4.0;
    final total = (to - from).distance;
    if (total <= 0) return;
    final dir = (to - from) / total;
    var covered = 0.0;
    while (covered < total) {
      final end = covered + dash < total ? covered + dash : total;
      canvas.drawLine(from + dir * covered, from + dir * end, paint);
      covered = end + gap;
    }
  }

  /// A gentle curve through the points rather than straight segments, drawn
  /// exactly as Véda's own Trends chart draws it (mirrors Véda's
  /// trend_chart.dart; change both together): each point is the control point
  /// of a quadratic curve to the midpoint between it and the next one.
  Path _smoothPath(List<Offset> points) {
    final path = Path();
    if (points.isEmpty) return path;
    path.moveTo(points.first.dx, points.first.dy);
    if (points.length == 1) return path;
    if (points.length == 2) {
      path.lineTo(points[1].dx, points[1].dy);
      return path;
    }
    for (var i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
    }
    final lastPoint = points.last;
    final secondLast = points[points.length - 2];
    path.quadraticBezierTo(
      secondLast.dx,
      secondLast.dy,
      lastPoint.dx,
      lastPoint.dy,
    );
    return path;
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
    // In a carousel the carousel shows the title as its dropdown instead.
    final titleHere = !ChartCarouselScope.titleInHeaderOf(context);
    return CardBox(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (titleHere) ...[
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontFamily: kDisplayFont,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 3),
          ],
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
