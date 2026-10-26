// What a chart looks like BEFORE there is data: the same Rings, Petals or Bars
// as the real thing, drawn as a soft ghost that breathes, with "–" where a
// number will be. It previews the shape the data will take, never a fake
// number. Ported from Véda's own empty Today tab and generalised to any set of
// parts, so every Véda app waits for its first data the same way.

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'hud_bars.dart';
import 'metric_info.dart';
import 'metric_views.dart' show MetricStyle, petalBaseWidth, ringRowSizes;

/// A plausible-looking fraction for part [i]: not data, just enough variation
/// that the ghost does not look like a flat line.
double ghostFraction(int i) =>
    (0.45 + 0.35 * math.sin(i * 2.1 + 0.6)).clamp(0.25, 0.95);

/// The ghost chart for [keys] (keys of [metricInfoByKey]) in the chosen style.
class GhostMetricChart extends StatelessWidget {
  const GhostMetricChart({
    super.key,
    required this.style,
    required this.keys,
    required this.colors,
    this.hud = false,
  });

  final MetricStyle style;
  final List<String> keys;
  final AppColors colors;

  /// Bars in the readout look (see MetricBarsView.hud).
  final bool hud;

  @override
  Widget build(BuildContext context) {
    final infos = [
      for (final k in keys)
        if (metricInfoByKey[k] case final m?) m,
    ];
    return Center(
      child: switch (style) {
        MetricStyle.bars => _FitRowsToHeight(
          child: hud
              ? HudGhostBars(colors: colors, infos: infos)
              : _BarsPlaceholder(colors: colors, infos: infos),
        ),
        MetricStyle.rings => _RingsPlaceholder(colors: colors, infos: infos),
        MetricStyle.petals => _PetalsPlaceholder(colors: colors, infos: infos),
      },
    );
  }
}

/// Bar rows have a natural height; in a shorter box they are scaled down only
/// as far as needed to fit.
class _FitRowsToHeight extends StatelessWidget {
  const _FitRowsToHeight({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(width: constraints.maxWidth, child: child),
    ),
  );
}

/// Same identity dot the real view always shows (previously just missing
/// here), plus a faint breathing ghost fill instead of a bare outlined
/// track — a preview of the shape a reading takes rather than seven
/// identical, colorless rows. Never a fake number: the value still reads
/// "–" throughout.
class _BarsPlaceholder extends StatefulWidget {
  const _BarsPlaceholder({required this.colors, required this.infos});
  final AppColors colors;
  final List<MetricInfo> infos;

  @override
  State<_BarsPlaceholder> createState() => _BarsPlaceholderState();
}

class _BarsPlaceholderState extends State<_BarsPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Holds still when the phone asks for reduced motion.
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse
        ..stop()
        ..value = 0.5;
    } else if (!_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final glowT = Curves.easeInOut.transform(_pulse.value);
        final ghostAlpha = 0.28 + 0.14 * glowT;
        return Column(
          // Same reason as MetricBarsView's own Column: without this it
          // fills whatever height it's given instead of its own seven-row
          // content height, which is what lets Center actually center it
          // now that this sits in the same scaled box Rings/Petals do.
          mainAxisSize: MainAxisSize.min,
          children: widget.infos.asMap().entries.map((indexed) {
            final i = indexed.key;
            final m = indexed.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: m.identityColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 78,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        m.name,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) => CustomPaint(
                        size: Size(constraints.maxWidth, 6),
                        painter: _GhostBarPainter(
                          fraction: ghostFraction(i),
                          trackColor: colors.cardSunken,
                          goldColor: colors.accent,
                          identityColor: m.identityColor,
                          alpha: ghostAlpha,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 34,
                    child: Text(
                      '–',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 12.5, color: colors.textMuted),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _GhostBarPainter extends CustomPainter {
  _GhostBarPainter({
    required this.fraction,
    required this.trackColor,
    required this.goldColor,
    required this.identityColor,
    required this.alpha,
  });

  final double fraction;
  final Color trackColor;
  final Color goldColor;
  final Color identityColor;

  /// 0-1, breathing back and forth — how visible the ghost fill currently
  /// is, same pulse every placeholder style now shares.
  final double alpha;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.height / 2;
    final track = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    canvas.drawRRect(track, Paint()..color = trackColor);

    final ghostWidth = size.width * fraction;
    if (ghostWidth <= 0) return;
    final ghostRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, ghostWidth, size.height),
      Radius.circular(radius),
    );
    canvas.drawRRect(
      ghostRect,
      Paint()
        ..shader = ui.Gradient.linear(Offset.zero, Offset(ghostWidth, 0), [
          goldColor.withValues(alpha: alpha * 0.75),
          identityColor.withValues(alpha: alpha),
        ]),
    );
  }

  @override
  bool shouldRepaint(_GhostBarPainter old) =>
      old.fraction != fraction ||
      old.alpha != alpha ||
      old.identityColor != identityColor ||
      old.trackColor != trackColor;
}

/// Same grid the real view uses, but previously every ring was one flat
/// muted outline — no identity color anywhere, unlike Petals or Bars.
/// Now each ring's edge picks up its own metric's identity color (same
/// 35%-toward-black blend the real ring's edge/tip use — see
/// _MetricRingPainter), plus a faint breathing ghost arc previewing the
/// shape a reading takes. Never a fake number: the value still reads "–".
class _RingsPlaceholder extends StatefulWidget {
  const _RingsPlaceholder({required this.colors, required this.infos});
  final AppColors colors;
  final List<MetricInfo> infos;

  @override
  State<_RingsPlaceholder> createState() => _RingsPlaceholderState();
}

class _RingsPlaceholderState extends State<_RingsPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  static const _crossAxisCount = 4;
  static const _spacing = 8.0;
  static const _runSpacing = 6.0;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Holds still when the phone asks for reduced motion.
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse
        ..stop()
        ..value = 0.5;
    } else if (!_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final rowSizes = ringRowSizes(widget.infos.length, perRow: _crossAxisCount);
    final rows = rowSizes.length;
    final columns = rowSizes.fold(1, math.max);
    return LayoutBuilder(
      builder: (context, constraints) {
        final widthBased =
            (constraints.maxWidth - _spacing * (columns - 1)) / columns;
        final heightBased =
            (constraints.maxHeight - _runSpacing * (rows - 1)) / rows;
        final diameter = math.min(widthBased, heightBased);
        return AnimatedBuilder(
          animation: _pulse,
          builder: (context, _) {
            final glowT = Curves.easeInOut.transform(_pulse.value);
            final ghostAlpha = 0.22 + 0.14 * glowT;
            Widget cell(int i) {
              final m = widget.infos[i];
              return SizedBox(
                width: diameter,
                height: diameter,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: Size(diameter, diameter),
                      painter: _PlaceholderRingPainter(
                        identityColor: m.identityColor,
                        goldColor: colors.accent,
                        ghostFraction: ghostFraction(i),
                        ghostAlpha: ghostAlpha,
                      ),
                    ),
                    SizedBox(
                      width: diameter * 0.78,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '–',
                            style: TextStyle(
                              fontSize: diameter * 0.24,
                              fontWeight: FontWeight.w600,
                              height: 1,
                              color: colors.textMuted,
                            ),
                          ),
                          Text(
                            m.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: diameter * 0.115,
                              height: 1.2,
                              color: colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            var next = 0;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var r = 0; r < rows; r++) ...[
                  if (r > 0) const SizedBox(height: _runSpacing),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var c = 0; c < rowSizes[r]; c++) ...[
                        if (c > 0) const SizedBox(width: _spacing),
                        cell(next++),
                      ],
                    ],
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

class _PlaceholderRingPainter extends CustomPainter {
  _PlaceholderRingPainter({
    required this.identityColor,
    required this.goldColor,
    required this.ghostFraction,
    required this.ghostAlpha,
  });
  final Color identityColor;
  final Color goldColor;
  final double ghostFraction;

  /// 0-1, breathing back and forth — same pulse every placeholder style
  /// now shares.
  final double ghostAlpha;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Same geometry as the real ring (_MetricRingPainter) so switching
    // from empty to a first reading doesn't jump in thickness or
    // proportions.
    const strokeWidth = 7.0;
    const edgeGap = 3.0;
    final ringRadius =
        (math.min(size.width, size.height) - strokeWidth) / 2 - edgeGap - 1.5;
    final rect = Rect.fromCircle(center: center, radius: ringRadius);

    // A muted hint of which metric this is, not a full-strength claim —
    // same 35%-toward-black blend the real ring's edge/tip already use.
    final tipShade = Color.lerp(identityColor, Colors.black, 0.35)!;
    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = tipShade.withValues(alpha: 0.55);
    canvas.drawCircle(
      center,
      ringRadius + strokeWidth / 2 + edgeGap,
      edgePaint,
    );
    canvas.drawCircle(
      center,
      ringRadius - strokeWidth / 2 - edgeGap,
      edgePaint,
    );

    final sweep = 2 * math.pi * ghostFraction;
    final ghost = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt
      // Same rotated gradient as _MetricRingPainter's fill, for the same
      // reason — see the comment there.
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: sweep,
        colors: [
          goldColor.withValues(alpha: ghostAlpha * 0.75),
          tipShade.withValues(alpha: ghostAlpha),
        ],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect);
    canvas.drawArc(rect, -math.pi / 2, sweep, false, ghost);
  }

  @override
  bool shouldRepaint(_PlaceholderRingPainter old) =>
      old.identityColor != identityColor ||
      old.ghostFraction != ghostFraction ||
      old.ghostAlpha != ghostAlpha;
}

/// The full flower, every petal at its longest — not real data, just
/// the shape the real one will grow into, which is a better first
/// impression than a sparse flower with every petal barely there.
///
/// Two things preview the payoff of an actual reading rather than just
/// marking an absence: a slow ambient glow (the same warm wash the real
/// chart's own petals get, just breathing instead of static — see
/// _MetricPetalsPainter's own glow), and a faint "ghost" of a real
/// reading's uneven petal lengths sitting under the guide outline.
class _PetalsPlaceholder extends StatefulWidget {
  const _PetalsPlaceholder({required this.colors, required this.infos});
  final AppColors colors;
  final List<MetricInfo> infos;

  @override
  State<_PetalsPlaceholder> createState() => _PetalsPlaceholderState();
}

class _PetalsPlaceholderState extends State<_PetalsPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Holds still when the phone asks for reduced motion.
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse
        ..stop()
        ..value = 0.5;
    } else if (!_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(constraints.maxWidth, constraints.maxHeight);
        return Center(
          child: SizedBox(
            width: side,
            height: side,
            child: AnimatedBuilder(
              animation: _pulse,
              builder: (context, _) => CustomPaint(
                size: Size(side, side),
                painter: _PlaceholderPetalsPainter(
                  colors: widget.colors,
                  infos: widget.infos,
                  glowT: Curves.easeInOut.transform(_pulse.value),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PlaceholderPetalsPainter extends CustomPainter {
  _PlaceholderPetalsPainter({
    required this.colors,
    required this.infos,
    required this.glowT,
  });
  final AppColors colors;
  final List<MetricInfo> infos;

  /// 0-1, breathing back and forth — how far into the pulse the ambient
  /// glow behind the flower currently is.
  final double glowT;

  @override
  void paint(Canvas canvas, Size size) {
    final n = infos.length;
    final center = Offset(size.width / 2, size.height / 2);
    // Same fractions as the real petal painter, for a placeholder that
    // grows into the exact same shape once there's real data.
    final maxLen = math.min(size.width, size.height) * 0.37;
    const minLen = 0.30;
    final baseWidth = petalBaseWidth(maxLen, n);
    final outline = colors.textMuted.withValues(alpha: 0.45);

    // Same warm wash the real chart's flower sits in (_MetricPetalsPainter),
    // just breathing between a dim and a fuller alpha instead of sitting
    // static — this is what's waiting for data, not what's absent.
    final glowAlpha = 0.10 + 0.12 * glowT;
    canvas.drawCircle(
      center,
      maxLen * 1.3,
      Paint()
        ..shader = ui.Gradient.radial(center, maxLen * 1.3, [
          colors.accent.withValues(alpha: glowAlpha),
          colors.accent.withValues(alpha: 0),
        ]),
    );

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (var i = 0; i < n; i++) {
      final m = infos[i];
      final angle = (-90 + i * 360 / n) * math.pi / 180;
      final a = Offset(math.cos(angle), math.sin(angle));
      final p = Offset(-math.sin(angle), math.cos(angle));

      Offset along(double t) => center + a * (maxLen * t);
      Offset out(Offset base, double t) => base + p * (baseWidth * t);

      // A ghost of what an actual reading's uneven petal lengths look
      // like — a deterministic wave rather than any real value, so it
      // never reads as a claim about the user's own skin. Drawn under
      // the guide outline, in the metric's own identity color at a very
      // low alpha, the same shape language the real chart uses.
      final ghostLen = maxLen * (minLen + (1 - minLen) * ghostFraction(i));
      Offset ghostAlong(double t) => center + a * (ghostLen * t);
      Offset ghostOut(Offset base, double t) => base + p * (baseWidth * t);
      final gTip = ghostAlong(1.0);
      final gPath = Path()
        ..moveTo(center.dx, center.dy)
        ..cubicTo(
          ghostOut(ghostAlong(0.22), 1.0).dx,
          ghostOut(ghostAlong(0.22), 1.0).dy,
          ghostOut(ghostAlong(0.75), 0.55).dx,
          ghostOut(ghostAlong(0.75), 0.55).dy,
          gTip.dx,
          gTip.dy,
        )
        ..cubicTo(
          ghostOut(ghostAlong(0.75), -0.55).dx,
          ghostOut(ghostAlong(0.75), -0.55).dy,
          ghostOut(ghostAlong(0.22), -1.0).dx,
          ghostOut(ghostAlong(0.22), -1.0).dy,
          center.dx,
          center.dy,
        )
        ..close();
      canvas.drawPath(
        gPath,
        Paint()
          ..style = PaintingStyle.fill
          ..shader = ui.Gradient.linear(center, gTip, [
            colors.accent.withValues(alpha: 0.22),
            m.identityColor.withValues(alpha: 0.14),
          ]),
      );

      final tip = along(1.0);
      final c1 = out(along(0.22), 1.0);
      final c2 = out(along(0.75), 0.55);
      final c3 = out(along(0.75), -0.55);
      final c4 = out(along(0.22), -1.0);

      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, tip.dx, tip.dy)
        ..cubicTo(c3.dx, c3.dy, c4.dx, c4.dy, center.dx, center.dy)
        ..close();

      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = outline,
      );

      textPainter.text = TextSpan(
        text: m.name,
        style: TextStyle(fontSize: 9.5, color: colors.textMuted),
      );
      textPainter.layout();
      // Same tip-relative, size-aware clearance as the real petal
      // painter — see its comment for why a fixed fraction of maxLen
      // isn't enough for a wide, near-horizontal label.
      final reach =
          (textPainter.width / 2) * a.dx.abs() +
          (textPainter.height / 2) * a.dy.abs();
      final labelPos = tip + a * (reach + 6);
      textPainter.paint(
        canvas,
        labelPos - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    canvas.drawCircle(
      center,
      4,
      Paint()..color = colors.textMuted.withValues(alpha: 0.6),
    );
  }

  @override
  bool shouldRepaint(_PlaceholderPetalsPainter old) => old.glowT != glowT;
}
