// The same ring as Véda's own Today tab (flutter_app/lib/widgets/score_ring.dart),
// so a Skin Score or a Wellness Score looks identical in every app. If one is
// changed, change the other.
//
// The ring around the latest score on the Today tab.
//
// Gold arc over a dim-gold track — accentDim exists specifically for this
// ("unfilled ring" in app_colors.dart). No color encodes whether the number
// is good or bad: the ring is exactly as full for a 40 as for a 90. Fullness
// communicates only "how far through 0-100", the same as the plain progress
// bars already used for per-metric rows elsewhere in the app.

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'theme.dart';

class ScoreRingPainter extends CustomPainter {
  ScoreRingPainter({
    required this.value,
    required this.trackColor,
    required this.fillColor,
    required this.edgeColor,
    this.glint = 0,
    this.ghostT,
    this.strokeWidth = 10,
    this.glass = false,
  });

  /// The glass look, for the main Skin Score only (see ScoreRing.glass): a
  /// faint translucent disc and track, and a bright highlight along the top-left
  /// rim. No sheen, so the fill stays one solid gold. Reversible: set it off.
  final bool glass;

  /// 0-100.
  final double value;
  final Color trackColor;

  /// One solid gold, deliberately — no sweep or bevel, not even gold-only
  /// ones. The app's most important number reads strongest in a single
  /// unalloyed gold; every gradient mocked up for it diluted that.
  final Color fillColor;

  /// The gold of the two border rings and of the soft glow behind the
  /// leading-edge marker. The marker itself is warm white (_markerColor).
  final Color edgeColor;

  /// 0-1: how brightly the marker catches the light right now. ScoreRing
  /// swells it once after the count-up lands, then lets it settle to 0.
  final double glint;

  /// 0-1, breathing back and forth — set only when this ring has no
  /// reading yet (see ScoreRing.hasReading), null the rest of the time.
  /// The real fill only ever draws for value > 0, so an empty ring drew
  /// nothing but a flat track; this previews the payoff instead, the
  /// same language the empty chart styles use.
  final double? ghostT;
  final double strokeWidth;

  // Same warm white as the petal chart's tips. A gold marker disappeared
  // into the gold arc end it sits on; white reads as the edge at a glance,
  // and the value itself — the arc — stays gold.
  static const _markerColor = kMarkerWhite;

  /// Not a real value — just enough of an arc that an empty ring previews
  /// what filling in looks like, the same way the empty chart styles
  /// preview an imagined shape rather than a real one. Matches the medallion
  /// logo fill (~78%) for brand continuity.
  static const _ghostFraction = 0.82;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    if (ghostT case final t?) {
      // Same warm ambient wash the petal chart's own empty state breathes
      // with — this ring is the single most-seen number in the app, so it
      // earns the same "waiting for data" glow rather than sitting flat.
      canvas.drawCircle(
        center,
        radius * 1.35,
        Paint()
          ..shader = ui.Gradient.radial(center, radius * 1.35, [
            fillColor.withValues(alpha: 0.14 + 0.12 * t),
            fillColor.withValues(alpha: 0),
          ]),
      );
    }

    // A thin gold frame just outside and just inside the band — the same
    // inner/outer edge treatment the small per-metric rings use for their
    // identityColor (see _MetricRingPainter), in gold here since this ring
    // has no identity color of its own. Gives the app's single most-seen
    // number a little more presence, and the leading-edge marker below
    // spans exactly between these two rings.
    const edgeGap = 3.0;
    final innerEdge = radius - strokeWidth / 2 - edgeGap;
    final outerEdge = radius + strokeWidth / 2 + edgeGap;
    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = edgeColor;
    if (glass && ghostT == null) {
      // A soft halo just outside the ring, fading to nothing: the ring reads
      // as lit glass rather than a flat line. A trial (see ScoreRing.glass).
      final reach = outerEdge + 16;
      canvas.drawCircle(
        center,
        reach,
        Paint()
          ..shader = ui.Gradient.radial(
            center,
            reach,
            [
              fillColor.withValues(alpha: 0),
              fillColor.withValues(alpha: 0.17),
              fillColor.withValues(alpha: 0),
            ],
            [(outerEdge - 3) / reach, (outerEdge + 2) / reach, 1.0],
          ),
      );
    }
    canvas.drawCircle(center, outerEdge, edgePaint);
    canvas.drawCircle(center, innerEdge, edgePaint);

    // Soft glow behind the number itself, filling the ring's inner disc —
    // only for a real reading (not the ghost/no-reading state, which
    // already breathes its own ambient wash outside the ring above). Faint
    // and constant regardless of the score: a backlight for the number,
    // not another fullness indicator competing with the arc itself.
    if (ghostT == null) {
      canvas.drawCircle(
        center,
        innerEdge,
        Paint()
          ..shader = ui.Gradient.radial(center, innerEdge, [
            // softer under the glass look, where the lens adds its own light
            fillColor.withValues(alpha: glass ? 0.11 : 0.20),
            fillColor.withValues(alpha: 0.0),
          ]),
      );
    }

    // The glass look: the inner disc is a lens, brighter toward the top-left
    // and fading to clear at the far side, with a faint rim.
    if (glass && ghostT == null) {
      final lens = Rect.fromCircle(center: center, radius: innerEdge);
      canvas.drawCircle(
        center,
        innerEdge,
        Paint()
          ..shader = ui.Gradient.radial(
            center + Offset(-innerEdge * 0.45, -innerEdge * 0.5),
            innerEdge * 1.5,
            [
              Colors.white.withValues(alpha: 0.15),
              Colors.white.withValues(alpha: 0.03),
            ],
          ),
      );
      // a soft reflection in the upper left of the lens
      canvas.save();
      canvas.translate(
        center.dx - innerEdge * 0.38,
        center.dy - innerEdge * 0.5,
      );
      canvas.rotate(-0.6);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: innerEdge * 0.9,
          height: innerEdge * 0.42,
        ),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.10)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      canvas.restore();
      canvas.drawArc(
        lens.deflate(1),
        -math.pi * 0.95,
        math.pi * 0.5,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = Colors.white.withValues(alpha: 0.3),
      );
    }

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      // The dim gold stays under the glass look too: it echoes the logo's
      // bronze, and the ring must stay consistent with it.
      ..color = glass ? trackColor.withValues(alpha: 0.6) : trackColor;
    canvas.drawArc(rect, 0, 2 * math.pi, false, track);
    if (glass && ghostT == null) {
      // frosted band: a light wash over the whole track
      canvas.drawArc(
        rect,
        0,
        2 * math.pi,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..color = Colors.white.withValues(alpha: 0.16),
      );
    }

    // Starts at 12 o'clock, same convention as the capture screen's
    // countdown ring, so "progress" always reads the same way in this app.
    const start = -math.pi / 2;

    // Flat ends, not round ones (2026-09-27): a rounded end needed a curved
    // white edge to match, which never read cleanly at this size. Flat, the
    // fill ends in a straight edge marked by a straight white index line —
    // the same language as the small per-metric rings (_MetricRingPainter).
    if (ghostT case final t?) {
      const sweep = 2 * math.pi * _ghostFraction;
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.butt
          ..color = fillColor.withValues(alpha: 0.20 + 0.14 * t),
      );
      // A faint hint of the real marker, at the ghost arc's own end.
      _drawIndex(
        canvas,
        center,
        radius,
        start + sweep,
        coreColor: _markerColor.withValues(alpha: 0.35 + 0.3 * t),
      );
      return;
    }

    final fraction = (value / 100).clamp(0.0, 1.0);
    if (fraction <= 0) return;

    final sweep = 2 * math.pi * fraction;
    final fill = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt
      ..color = fillColor;
    canvas.drawArc(rect, start, sweep, false, fill);

    _drawIndex(
      canvas,
      center,
      radius,
      start + sweep,
      coreColor: _markerColor,
      glowColor: edgeColor.withValues(alpha: 0.4 + 0.55 * glint),
      glowWidth: strokeWidth * (0.9 + 0.5 * glint),
    );

    if (glass) {
      // The gloss: a thin highlight along the outer edge of the whole band,
      // brightest at the upper left and again, fainter, at the lower right,
      // the way light catches a glass tube. Flat, inside the band.
      final gloss = Rect.fromCircle(
        center: center,
        radius: radius + strokeWidth * 0.26,
      );
      Color lobe(double a) => Colors.white.withValues(alpha: a);
      canvas.drawArc(
        gloss,
        0,
        2 * math.pi,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth * 0.3
          ..strokeCap = StrokeCap.butt
          ..shader = SweepGradient(
            colors: [
              lobe(0.10),
              lobe(0.30),
              lobe(0),
              lobe(0.45),
              lobe(0),
              lobe(0.10),
            ],
            stops: const [0.0, 0.125, 0.375, 0.625, 0.875, 1.0],
          ).createShader(gloss),
      );
    }
  }

  /// The white index line at the fill's flat end: straight across the band,
  /// 40% of the band's width (the small rings' own proportion), its leading
  /// edge flush with where the gold stops. Clipped to the band, glow
  /// included, so nothing ever draws past the band's edges.
  void _drawIndex(
    Canvas canvas,
    Offset center,
    double radius,
    double endAngle, {
    required Color coreColor,
    Color? glowColor,
    double? glowWidth,
  }) {
    final markerWidth = strokeWidth * 0.4;
    final angle = endAngle - (markerWidth / 2) / radius;
    final dir = Offset(math.cos(angle), math.sin(angle));
    final inner = center + dir * (radius - strokeWidth / 2);
    final outer = center + dir * (radius + strokeWidth / 2);
    canvas.save();
    canvas.clipPath(
      Path()
        ..fillType = PathFillType.evenOdd
        ..addOval(
          Rect.fromCircle(center: center, radius: radius + strokeWidth / 2),
        )
        ..addOval(
          Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        ),
    );
    if (glowColor != null) {
      canvas.drawLine(
        inner,
        outer,
        Paint()
          ..strokeWidth = glowWidth ?? strokeWidth * 0.9
          ..color = glowColor
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, strokeWidth * 0.22),
      );
    }
    canvas.drawLine(
      inner,
      outer,
      Paint()
        ..strokeWidth = markerWidth
        ..color = coreColor,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(ScoreRingPainter old) =>
      old.value != value ||
      old.trackColor != trackColor ||
      old.fillColor != fillColor ||
      old.edgeColor != edgeColor ||
      old.glint != glint ||
      old.ghostT != ghostT;
}

/// A score ring with the value and a label centered inside it.
///
/// Plays in once per mount: the ring counts up to its value, and as it
/// lands the leading-edge marker catches the light once and settles. The
/// glint is this ring's alone — the metric charts beside it don't get one,
/// so the eye knows which number matters most.
class ScoreRing extends StatefulWidget {
  const ScoreRing({
    super.key,
    required this.value,
    required this.label,
    required this.trackColor,
    required this.fillColor,
    required this.edgeColor,
    required this.valueColor,
    required this.labelColor,
    this.size = 148,
    this.hasReading = true,
    this.glass = false,
  });

  /// The glass look (see ScoreRingPainter.glass). Only the main Skin Score uses it.
  final bool glass;

  final double value;
  final String label;
  final Color trackColor;
  final Color fillColor;
  final Color edgeColor;
  final Color valueColor;
  final Color labelColor;
  final double size;

  /// False only for Today's "nothing taken yet" ring. [value] is ignored
  /// then (there's no real number to show or count up to) — the ring
  /// breathes a soft glow and a ghost preview arc instead, with just the
  /// label, no numeral at all: showing "0" for "no reading yet" reads as
  /// a real score, not an absence of one.
  final bool hasReading;

  @override
  State<ScoreRing> createState() => _ScoreRingState();
}

class _ScoreRingState extends State<ScoreRing>
    with SingleTickerProviderStateMixin {
  // One timeline rather than two animations, so the glint can never drift
  // from the count-up it follows: the first 900ms is the same eased
  // count-up the ring always had, the last 800ms the glint.
  static const _countUp = Duration(milliseconds: 900);
  static const _glint = Duration(milliseconds: 800);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _countUp + _glint,
  );

  static final _countUpEnd =
      _countUp.inMilliseconds / (_countUp + _glint).inMilliseconds;
  static final _reveal = Interval(0, _countUpEnd, curve: Curves.easeOutCubic);
  static final _glintPhase = Interval(_countUpEnd, 1);

  @override
  void initState() {
    super.initState();
    if (widget.hasReading) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant ScoreRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A new reading updates this same mounted ring in place (same widget
    // type and position in the tree, so Flutter reuses this State rather
    // than remounting it) — without this, only the very first reading ever
    // actually played the count-up/glint; every one after it just snapped
    // straight to the new number.
    if (widget.hasReading && widget.value != oldWidget.value) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    if (!widget.hasReading) {
      return SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(size, size),
              painter: ScoreRingPainter(
                value: 0,
                trackColor: widget.trackColor,
                fillColor: widget.fillColor,
                edgeColor: widget.edgeColor,
                ghostT: 1.0,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(size * 0.2),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.3,
                    color: widget.labelColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          final shown = widget.value * _reveal.transform(t);
          final glint = math.sin(math.pi * _glintPhase.transform(t));
          return Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: ScoreRingPainter(
                  value: shown,
                  trackColor: widget.trackColor,
                  fillColor: widget.fillColor,
                  edgeColor: widget.edgeColor,
                  glint: glint,
                  glass: widget.glass,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    shown.toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 40,
                      fontFamily: kDisplayFont,
                      color: widget.valueColor,
                      // Marcellus only ships one weight — w500 here would
                      // just ask Flutter to synthesize a fake bold.
                      height: 1,
                      // Fixed-width digits: this number counts up on every
                      // reveal and changes on every new reading, and
                      // proportional digits (a "1" narrower than a "8")
                      // made the ring's centered content visibly shift
                      // side to side as it did.
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.label,
                    style: TextStyle(fontSize: 12, color: widget.labelColor),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
