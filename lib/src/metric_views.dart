// Véda's own three ways to show the seven measurements (Rings, Petals, Bars)
// with the switch between them, ported unchanged from Véda's
// flutter_app/lib/widgets/metric_views.dart so every companion app draws them
// exactly as Véda does: the same shapes, the same gold values, the same
// identity colours (only to tell the metrics apart, never to say good or bad).
//
// What changes is only where the numbers come from: a companion shows the
// average of the person's Véda readings on days that match something in the
// app (slept 7-8h, a luteal-phase day, a high-UV day).

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'app_colors.dart';
import 'data_reveal.dart';
import 'metric_info.dart';

enum MetricStyle { bars, rings, petals }

/// The row of three small buttons that switches between styles.
/// Whatever is picked here is remembered as the default for next time.
class MetricStyleToggle extends StatelessWidget {
  const MetricStyleToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final MetricStyle value;
  final ValueChanged<MetricStyle> onChanged;

  @override
  Widget build(BuildContext context) => ChartStyleToggle<MetricStyle>(
    value: value,
    onChanged: onChanged,
    options: const [
      (
        value: MetricStyle.rings,
        icon: PhosphorIconsThin.chartDonut,
        label: 'Rings',
      ),
      (
        value: MetricStyle.petals,
        icon: PhosphorIconsThin.flower,
        label: 'Petals',
      ),
      (
        value: MetricStyle.bars,
        icon: PhosphorIconsThin.chartBar,
        label: 'Bars',
      ),
    ],
  );
}

/// The chart-style switch itself, for any set of views — Today's
/// Rings/Petals/Bars, Cycle's Flower/Rings, Lifestyle's Bars/Rings — so
/// every chart in the app switches with the exact same buttons.
class ChartStyleToggle<T> extends StatelessWidget {
  const ChartStyleToggle({
    super.key,
    required this.value,
    required this.onChanged,
    required this.options,
  });

  final T value;
  final ValueChanged<T> onChanged;
  final List<({T value, IconData icon, String label})> options;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Widget button(({T value, IconData icon, String label}) option) {
      final selected = option.value == value;
      return Expanded(
        child: GestureDetector(
          onTap: selected
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onChanged(option.value);
                },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: selected ? colors.accentDim : colors.cardSunken,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  option.icon,
                  size: 14,
                  color: selected ? colors.accentText : colors.textMuted,
                ),
                const SizedBox(width: 5),
                Text(
                  option.label,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: selected ? colors.accentText : colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(children: [for (final o in options) button(o)]);
  }
}

/// The chart itself, swipeable between whichever styles a ChartStyleToggle
/// above it offers — a swipe and a tap on the toggle are two paths to the
/// same [onChanged], so the toggle's own highlighted button always tracks
/// whichever page a swipe lands on, and a tap on the toggle animates the
/// page to match in turn.
class SwipeableChartPager<T> extends StatefulWidget {
  const SwipeableChartPager({
    super.key,
    required this.value,
    required this.values,
    required this.onChanged,
    required this.builder,
    this.swipeable = true,
  });

  final T value;

  /// Whether a swipe changes the style. Off when this pager sits inside
  /// another one (the reading's photo and chart): the inner pager would
  /// swallow every horizontal swipe, so the outer page could never be swiped
  /// back to. The toggle above still changes the style, by tap.
  final bool swipeable;

  /// In the same left-to-right order as the toggle buttons above, so a
  /// swipe moves to the adjacent button exactly as it looks like it should.
  final List<T> values;
  final ValueChanged<T> onChanged;
  final Widget Function(T value) builder;

  @override
  State<SwipeableChartPager<T>> createState() => _SwipeableChartPagerState<T>();
}

class _SwipeableChartPagerState<T> extends State<SwipeableChartPager<T>> {
  late final PageController _controller = PageController(
    initialPage: widget.values.indexOf(widget.value),
  );

  @override
  void didUpdateWidget(covariant SwipeableChartPager<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == oldWidget.value) return;
    final target = widget.values.indexOf(widget.value);
    // A swipe already lands the controller on the target page itself
    // (onPageChanged fires widget.onChanged, which is what got us here) —
    // only a tap on the toggle button needs this widget to drive the page
    // change instead. Comparing against the settled page, not one mid-drag,
    // is what tells the two apart.
    if (!_controller.hasClients || _controller.page?.round() == target) return;
    _controller.animateToPage(
      target,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      physics: widget.swipeable ? null : const NeverScrollableScrollPhysics(),
      itemCount: widget.values.length,
      onPageChanged: (i) => widget.onChanged(widget.values[i]),
      itemBuilder: (context, i) => widget.builder(widget.values[i]),
    );
  }
}

/// A deterministic, plausible-looking "what a real reading might show"
/// fraction for metric index [i] — not real data (never shown as a
/// number), just enough variation that an empty state's preview doesn't
/// look like a flat line. Shared by every style's placeholder (and the
/// Cycle tab's flower) so every empty chart previews the same kind of
/// imagined shape rather than each inventing its own.

/// The existing horizontal-bar layout, now with each track's own
/// identityColor as a thin border so the same at-a-glance metric
/// recognition is available here too, not just in the newer two. Bars
/// already fit the card's own footprint at full detail, so there's no
/// separate compact/expanded distinction here.
class MetricBarsView extends StatelessWidget {
  const MetricBarsView({
    super.key,
    required this.scores,
    required this.colors,
    required this.onTap,
  });

  final Map<String, double> scores;
  final AppColors colors;
  final void Function(String key) onTap;

  @override
  Widget build(BuildContext context) {
    final entries = scores.entries.toList();
    return DataReveal(
      builder: (context, tAt) => Column(
        // Same fix as MetricChartCard's own Column: without this, this
        // Column fills whatever height it's given (the default) instead
        // of its own seven-row content height, so wrapping it in Center
        // (the reading screen's expand mode) had nothing to actually
        // center — the rows just sat at the top of the oversized box.
        mainAxisSize: MainAxisSize.min,
        children: entries.asMap().entries.map((indexed) {
          final i = indexed.key;
          final e = indexed.value;
          final t = tAt(i, entries.length);
          final info = metricInfoByKey[e.key];
          final identity = info?.identityColor ?? colors.textMuted;
          final shown = e.value * t;
          return InkWell(
            onTap: () => onTap(e.key),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  // Identity color as a small dot rather than a frame around
                  // the bar — the same "accent, not an outline" language as
                  // the petal's vein and the ring's edge. It also carries the
                  // identity on its own at a low value, where the vein below
                  // is too short to read clearly by itself.
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: identity,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 64,
                    child: Text(
                      info?.name ?? e.key,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) => CustomPaint(
                        size: Size(constraints.maxWidth, 6),
                        painter: _MetricBarPainter(
                          fraction: (shown / 100).clamp(0.0, 1.0),
                          trackColor: colors.cardSunken,
                          fillColor: colors.accent,
                          veinColor: identity,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 34,
                    child: Text(
                      shown.toStringAsFixed(0),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// The pill-shaped bar itself: a track, a gold fill sized to the value,
/// and a thin identity-colored "vein" running through the fill — the
/// same idea as the petal's own vein, scaled to the value the same way
/// the petal's length is. Inset slightly from both ends of the fill so
/// it sits inside the pill's rounded caps rather than poking through them.
class _MetricBarPainter extends CustomPainter {
  _MetricBarPainter({
    required this.fraction,
    required this.trackColor,
    required this.fillColor,
    required this.veinColor,
  });

  final double fraction;
  final Color trackColor;
  final Color fillColor;
  final Color veinColor;

  /// The glowing cap line at the fill's own leading edge — same warm
  /// white as the score ring's marker and the petal chart's own tips
  /// (see ScoreRingPainter._markerColor), not the per-metric identity
  /// color the vein already uses. A fixed design constant, not something
  /// any call site has ever actually varied.
  static const _tipColor = kMarkerWhite;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.height / 2;
    final track = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    canvas.drawRRect(track, Paint()..color = trackColor);

    final fillWidth = size.width * fraction;
    if (fillWidth <= 0) return;
    final fillRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, fillWidth, size.height),
      Radius.circular(radius),
    );
    // Same gold-into-identity-color wash as the petal chart's fill, so
    // switching styles doesn't lose the richer look — plain gold left to
    // right read as flatter than it needed to once petals had this.
    canvas.drawRRect(
      fillRect,
      Paint()
        ..shader = ui.Gradient.linear(Offset.zero, Offset(fillWidth, 0), [
          fillColor,
          veinColor.withValues(alpha: 0.6),
        ]),
    );

    final inset = radius * 0.8;
    if (fillWidth > inset * 2) {
      final y = size.height / 2;
      canvas.drawLine(
        Offset(inset, y),
        Offset(fillWidth - inset, y),
        Paint()
          ..color = veinColor
          ..strokeWidth = 1.3
          ..strokeCap = StrokeCap.round,
      );
    }

    // The same glowing cap line the score ring's arc and the petals' own
    // tips mark their leading edge with — here, a vertical line crossing
    // the fill's own right edge, the bar's equivalent of "the boundary
    // between filled and unfilled."
    final capX = (fillWidth - 1).clamp(0.0, size.width - 1);
    canvas.drawLine(
      Offset(capX, 0),
      Offset(capX, size.height),
      Paint()
        ..strokeWidth = size.height * 0.9
        ..strokeCap = StrokeCap.round
        ..color = _tipColor.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawLine(
      Offset(capX, 0),
      Offset(capX, size.height),
      Paint()
        ..strokeWidth = size.height * 0.35
        ..strokeCap = StrokeCap.round
        ..color = _tipColor,
    );
  }

  @override
  bool shouldRepaint(_MetricBarPainter old) =>
      old.fraction != fraction ||
      old.trackColor != trackColor ||
      old.fillColor != fillColor ||
      old.veinColor != veinColor;
}

/// A small version of the Today ring for each metric — a 4-on-top,
/// 3-on-bottom centered grid, each edged in its own identityColor, each
/// showing its value and name inside the ring the same way the big
/// skin-score ring does. Sized to whatever height its parent gives it
/// (MetricChartCard's own flexible chart area).
class MetricRingsView extends StatelessWidget {
  const MetricRingsView({
    super.key,
    required this.scores,
    required this.colors,
    required this.onTap,
  });

  final Map<String, double> scores;
  final AppColors colors;
  final void Function(String key) onTap;

  static const _crossAxisCount = 4;
  static const _spacing = 8.0;
  static const _runSpacing = 6.0;

  @override
  Widget build(BuildContext context) {
    final entries = scores.entries.toList();
    final rows = (entries.length / _crossAxisCount).ceil();

    Widget ring(MapEntry<String, double> e, double diameter, double t) {
      final info = metricInfoByKey[e.key];
      final identity = info?.identityColor ?? colors.textMuted;
      final shown = e.value * t;
      return GestureDetector(
        onTap: () => onTap(e.key),
        child: SizedBox(
          width: diameter,
          height: diameter,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(diameter, diameter),
                painter: _MetricRingPainter(
                  value: shown,
                  trackColor: colors.accentDim,
                  fillColor: colors.accent,
                  edgeColor: identity,
                ),
              ),
              SizedBox(
                width: diameter * 0.78,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      shown.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: diameter * 0.24,
                        fontWeight: FontWeight.w600,
                        height: 1,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      info?.name ?? e.key,
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
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final widthBased =
            (constraints.maxWidth - _spacing * (_crossAxisCount - 1)) /
            _crossAxisCount;
        final heightBased =
            (constraints.maxHeight - _runSpacing * (rows - 1)) / rows;
        final diameter = math.min(widthBased, heightBased);
        return DataReveal(
          builder: (context, tAt) => Wrap(
            alignment: WrapAlignment.center,
            spacing: _spacing,
            runSpacing: _runSpacing,
            children: entries
                .asMap()
                .entries
                .map(
                  (indexed) => ring(
                    indexed.value,
                    diameter,
                    tAt(indexed.key, entries.length),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}

/// The Rings view for the Cycle and Lifestyle tabs: Today's own mini rings
/// in a 2-wide grid (3 over 2 when there are five), one per cycle phase or
/// wellness factor, all
/// edged in the selected metric's identity color (every ring here is the
/// same metric, unlike Today's grid). An item with no value yet shows an
/// empty track and "—", the same as a missing petal or quadrant.
class ValueRingsGrid extends StatelessWidget {
  const ValueRingsGrid({
    super.key,
    required this.items,
    required this.edgeColor,
  });

  /// [fraction] is how full the ring draws (0-1); [value] is the number
  /// printed in it, null for nothing yet.
  final List<({String label, double? value, double fraction})> items;
  final Color edgeColor;

  static const _spacing = 18.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Five rings (every Lifestyle factor) sit three over two rather than
    // 2-2-1, which would strand the last one alone on its own row.
    final rowSizes = items.length == 5
        ? const [3, 2]
        : [
            for (var left = items.length; left > 0; left -= 2)
              math.min(left, 2),
          ];
    final columns = rowSizes.fold(1, math.max);
    return LayoutBuilder(
      builder: (context, constraints) {
        final rows = rowSizes.length;
        final diameter = math.min(
          math.min(
            (constraints.maxWidth - _spacing * (columns - 1)) / columns,
            (constraints.maxHeight - _spacing * (rows - 1)) / rows,
          ),
          140.0,
        );
        return DataReveal(
          builder: (context, tAt) {
            var next = 0;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var r = 0; r < rows; r++)
                  Padding(
                    padding: EdgeInsets.only(top: r == 0 ? 0 : _spacing),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var c = 0; c < rowSizes[r]; c++) ...[
                          if (c > 0) const SizedBox(width: _spacing),
                          _ring(
                            colors,
                            items[next],
                            diameter,
                            tAt(next++, items.length),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _ring(
    AppColors colors,
    ({String label, double? value, double fraction}) item,
    double diameter,
    double t,
  ) {
    final value = item.value;
    return SizedBox(
      width: diameter,
      height: diameter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(diameter, diameter),
            painter: _MetricRingPainter(
              value: value == null ? 0 : item.fraction * 100 * t,
              trackColor: colors.accentDim,
              fillColor: colors.accent,
              edgeColor: edgeColor,
            ),
          ),
          SizedBox(
            width: diameter * 0.74,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value == null ? '—' : (value * t).toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: diameter * 0.22,
                    fontWeight: FontWeight.w600,
                    height: 1,
                    color: value == null
                        ? colors.textMuted
                        : colors.textPrimary,
                  ),
                ),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: diameter * 0.105,
                    height: 1.3,
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
}

class _MetricRingPainter extends CustomPainter {
  _MetricRingPainter({
    required this.value,
    required this.trackColor,
    required this.fillColor,
    required this.edgeColor,
  });

  final double value;
  final Color trackColor;
  final Color fillColor;
  final Color edgeColor;

  /// The glowing cap line at the arc's leading tip — same warm white as
  /// the score ring's marker and the petal chart's own tips (see
  /// ScoreRingPainter._markerColor), not the per-metric identity color
  /// the sweep already ends in. A fixed design constant, not something
  /// any call site has ever actually varied.
  static const _tipColor = kMarkerWhite;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 7.0;
    const edgeGap = 3.0;
    final ringRadius =
        (math.min(size.width, size.height) - strokeWidth) / 2 - edgeGap - 1.5;
    final rect = Rect.fromCircle(center: center, radius: ringRadius);

    // Some identity colors (pink, gray, tan) are naturally as light as the
    // gold itself, so both the edge line and the fill's own tip are blended
    // toward black rather than using the raw identity color — that's what
    // actually guarantees "darker," not just "different." Without this, a
    // light color like Spots' near-white gray washes out against the gold
    // ring, and at a value of 0 (no fill at all) the edge line is the only
    // color signal there is.
    final tipShade = Color.lerp(edgeColor, Colors.black, 0.35)!;

    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = tipShade;
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

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor;
    canvas.drawArc(rect, 0, 2 * math.pi, false, track);

    final fraction = (value / 100).clamp(0.0, 1.0);
    if (fraction <= 0) return;
    final sweep = 2 * math.pi * fraction;
    // Gold-into-identity-color wash, swept around exactly the arc actually
    // drawn (same start/end angles) so the gradient doesn't bunch up or
    // leave a flat tail past what's visible. Full-strength gold at the
    // start, fading to the identity color at the tip — the tip is the actual
    // reading, so it should read as the most visually anchored point.
    final fill = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt
      // A sweep gradient measures each pixel's angle in [0, 2π) from 3
      // o'clock, so a start/end range can't cross that seam — and an arc
      // starting at 12 o'clock always does. Passing -π/2..-π/2+sweep
      // clamped the 12-to-3 stretch to the tip color; shifting by +2π
      // clamped everything past 3 o'clock to gold instead (both checked
      // against real renders, 2026-09-27). Running the gradient from 0 and
      // rotating it a quarter turn back keeps the whole arc inside one
      // unbroken range.
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: sweep,
        colors: [fillColor, edgeColor.withValues(alpha: 0.75)],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect);
    canvas.drawArc(rect, -math.pi / 2, sweep, false, fill);

    // Same glowing cap line as the big score ring's own arc, radial
    // across the band's thickness at the exact tip angle.
    final tipAngle = -math.pi / 2 + sweep;
    final tipDir = Offset(math.cos(tipAngle), math.sin(tipAngle));
    final tipInner = center + tipDir * (ringRadius - strokeWidth / 2);
    final tipOuter = center + tipDir * (ringRadius + strokeWidth / 2);
    canvas.drawLine(
      tipInner,
      tipOuter,
      Paint()
        ..strokeWidth = strokeWidth * 0.9
        ..strokeCap = StrokeCap.round
        ..color = _tipColor.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawLine(
      tipInner,
      tipOuter,
      Paint()
        ..strokeWidth = strokeWidth * 0.4
        ..strokeCap = StrokeCap.round
        ..color = _tipColor,
    );
  }

  @override
  bool shouldRepaint(_MetricRingPainter old) =>
      old.value != value ||
      old.trackColor != trackColor ||
      old.fillColor != fillColor ||
      old.edgeColor != edgeColor;
}

/// Seven petals radiating from a center point, one per metric, length
/// carrying the value the same way bar length or ring fill does. Each
/// petal's center vein picks up that metric's identityColor. Sized to
/// whatever height its parent gives it (MetricChartCard always wraps
/// this in a fixed-height SizedBox) — the canvas keeps the card's full
/// width rather than forcing a square, so labels on either side of the
/// flower have room to spread out instead of being squeezed into a box
/// only as wide as it is tall.
class MetricPetalsView extends StatelessWidget {
  const MetricPetalsView({
    super.key,
    required this.scores,
    required this.colors,
    required this.onTap,
  });

  final Map<String, double> scores;
  final AppColors colors;
  final void Function(String key) onTap;

  @override
  Widget build(BuildContext context) {
    final entries = scores.entries.toList();
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        return Center(
          child: SizedBox(
            width: width,
            height: height,
            child: GestureDetector(
              onTapUp: (details) {
                final center = Offset(width / 2, height / 2);
                final v = details.localPosition - center;
                // Same -90° start as the painter, so the wedge under the
                // finger matches the wedge that gets tapped.
                var angle = math.atan2(v.dy, v.dx) * 180 / math.pi + 90;
                if (angle < 0) angle += 360;
                final i =
                    (angle / (360 / entries.length)).floor() % entries.length;
                onTap(entries[i].key);
              },
              child: DataReveal(
                builder: (context, tAt) => CustomPaint(
                  size: Size(width, height),
                  painter: _MetricPetalsPainter(
                    entries: entries,
                    colors: colors,
                    reveals: List.generate(
                      entries.length,
                      (i) => tAt(i, entries.length),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MetricPetalsPainter extends CustomPainter {
  _MetricPetalsPainter({
    required this.entries,
    required this.colors,
    required this.reveals,
  });

  final List<MapEntry<String, double>> entries;
  final AppColors colors;

  /// Each petal's own 0-1 growth progress, same length as [entries] —
  /// see DataReveal for why these are staggered rather than uniform.
  final List<double> reveals;

  @override
  void paint(Canvas canvas, Size size) {
    final n = entries.length;
    if (n == 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    // The label's own clearance (see the reach/labelPos math below) scales
    // with the label itself, not a fixed fraction of maxLen, so this can
    // grow independently of leaving room for the text.
    final maxLen = math.min(size.width, size.height) * 0.37;
    const minLen = 0.30;
    final baseWidth = maxLen * 0.16;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Petals is the default chart style — the one thing almost everyone
    // actually sees — so it earns more than the other two: a warm ambient
    // glow behind the whole flower, rather than it just sitting flat
    // against the card.
    canvas.drawCircle(
      center,
      maxLen * 1.3,
      Paint()
        ..shader = ui.Gradient.radial(center, maxLen * 1.3, [
          colors.accent.withValues(alpha: 0.16),
          colors.accent.withValues(alpha: 0),
        ]),
    );

    for (var i = 0; i < n; i++) {
      final entry = entries[i];
      final info = metricInfoByKey[entry.key];
      final identity = info?.identityColor ?? colors.textMuted;
      final fraction = (entry.value / 100).clamp(0.0, 1.0);
      final len = maxLen * (minLen + (1 - minLen) * fraction) * reveals[i];
      final angle = (-90 + i * 360 / n) * math.pi / 180;
      final a = Offset(math.cos(angle), math.sin(angle));
      final p = Offset(-math.sin(angle), math.cos(angle));

      Offset along(double t) => center + a * (len * t);
      Offset out(Offset base, double t) => base + p * (baseWidth * t);

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

      // A soft blurred shadow, offset slightly toward the bottom-right
      // (one consistent light direction for every petal, not each along
      // its own axis) — what actually sells "this is a raised shape" over
      // "this is a flat sticker," more than the gradient above does alone.
      canvas.drawPath(
        path.shift(Offset(maxLen * 0.02, maxLen * 0.03)),
        Paint()
          ..color = colors.canvasDeep.withValues(alpha: 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );

      // Gold at the base fading into a wash of this metric's own identity
      // color toward the tip — gold still dominates (see the file header's
      // "actual value is always gold" rule; this never gets bright/opaque
      // enough to compete with it), but seven petals no longer read as the
      // same flat shape seven times over.
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.fill
          ..shader = ui.Gradient.linear(center, tip, [
            colors.accent,
            identity.withValues(alpha: 0.6),
          ]),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = colors.accentText,
      );

      final veinTip = along(0.92);
      // A soft pale highlight under the identity-colored vein — a bare
      // flat-colored line read as a decal sitting on top of the petal;
      // this wide, faint stroke underneath it is what a real petal's own
      // midrib catching the light would look like.
      canvas.drawLine(
        center,
        veinTip,
        Paint()
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round
          ..color = colors.accentText.withValues(alpha: 0.5),
      );
      canvas.drawLine(
        center,
        veinTip,
        Paint()
          ..strokeWidth = 1.2
          ..color = identity,
      );

      // A glowing line traced along each of the two edges converging at
      // the tip — the same glow-behind-crisp-core language as the score
      // ring's own cap line, just following the "V" this petal's point
      // actually makes instead of a single radial line.
      for (final edgeControl in [c2, c3]) {
        final edgeEnd = tip + (edgeControl - tip) * 0.3;
        canvas.drawLine(
          tip,
          edgeEnd,
          Paint()
            ..strokeWidth = baseWidth * 0.28
            ..strokeCap = StrokeCap.round
            ..color = kMarkerWhite.withValues(alpha: 0.22)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
        );
        canvas.drawLine(
          tip,
          edgeEnd,
          Paint()
            ..strokeWidth = baseWidth * 0.1
            ..strokeCap = StrokeCap.round
            ..color = kMarkerWhite.withValues(alpha: 0.75),
        );
      }

      // Name and value stack as one block rather than sitting side by
      // side along the petal's own direction — a sideways-pointing petal
      // would otherwise print its two labels right into each other.
      // Font size scales with the flower itself (maxLen was tuned against
      // a ~220px box, where it comes out to ~81) — a box squeezed by a
      // large system font setting or a short screen shrinks the labels
      // right along with the petals, instead of holding a fixed pixel
      // size that no longer leaves room for itself.
      final labelScale = (maxLen / 81).clamp(0.55, 1.25);
      // The name is muted, not bold white (2026-09-27) — matching the
      // Rings view's own already-established split (MetricRingsView: value
      // white/w600, label muted/regular): the number is the point of each
      // petal, the name is just there to say which one, and both being
      // bold white made them compete instead.
      textPainter.text = TextSpan(
        children: [
          TextSpan(
            text: '${info?.name ?? entry.key}\n',
            style: TextStyle(
              fontSize: 9.5 * labelScale,
              color: colors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: (entry.value * reveals[i]).toStringAsFixed(0),
            style: TextStyle(
              fontSize: 10.5 * labelScale,
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
      textPainter.layout();
      // How far the label's own (centered) bounding box reaches back
      // toward the petal, given the label's size and the petal's own
      // angle — a wide, mostly-horizontal label (e.g. "Evenness") needs
      // more clearance than a narrow, mostly-vertical one.
      final reach =
          (textPainter.width / 2) * a.dx.abs() +
          (textPainter.height / 2) * a.dy.abs();
      // Anchored to where this petal would reach at 100, not its actual
      // tip — every label sits on the same outer ring regardless of
      // value, so the empty space between a short petal and its label
      // reads as "how far from 100" instead of the label just trailing
      // the tip. Still clamped to the box's own half-extent as a hard
      // backstop — CustomPaint doesn't clip, so without this an
      // unexpectedly small box (or a label longer than planned for) would
      // paint the label outside this chart entirely, over whatever sits
      // above it, rather than just crowding the flower.
      // Floored at 0: in a box under 4px across this would go negative,
      // and clamp() with its upper bound below its lower one throws —
      // mid-paint (found 2026-09-27 rendering a squeezed chart).
      final maxRadius = math.max(
        0.0,
        math.min(size.width, size.height) / 2 - 2,
      );
      final labelRadius = (maxLen + reach + 6).clamp(0.0, maxRadius);
      final labelPos = center + a * labelRadius;
      textPainter.paint(
        canvas,
        labelPos - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    // A small medallion rather than a bare dot — seven petals converging
    // on nothing but a point read as unfinished; this gives the flower an
    // actual center, echoing the ring/stroke language BrandMark and
    // MedallionButton already use elsewhere for "this is the anchor."
    final centerRadius = maxLen * 0.075;
    canvas.drawCircle(center, centerRadius, Paint()..color = colors.accentText);
    canvas.drawCircle(
      center,
      centerRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = centerRadius * 0.35
        ..color = colors.accentDim,
    );
  }

  @override
  bool shouldRepaint(_MetricPetalsPainter old) => true;
}
