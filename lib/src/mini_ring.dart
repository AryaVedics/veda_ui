// The ring that sits at the left of the message box, drawn the way Véda draws
// its Skin Score ring: the same size, thin edge rings round the band, flat ends
// and a straight glowing line where the arc stops. It holds the app's own
// number for today, with a short caption, and its arc runs in a gradient
// (see UI_RULES.md: Véda's standards are the basis of the UI).

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'theme.dart';

/// Véda's own ring size beside its message box.
const double kMiniRingSize = 132;

/// The warm white of Véda's end line.
const _markerWhite = Color(0xFFFFFDF5);

class MiniRing extends StatelessWidget {
  const MiniRing({
    super.key,
    required this.fraction,
    this.centre,
    this.caption,
    required this.gradient,
    required this.stops,
    this.size = kMiniRingSize,
    this.trackColor,
  });

  /// How much of the ring is filled, 0 to 1.
  final double fraction;

  /// The number in the middle, such as "94". Null for none.
  final String? centre;

  /// The short line under the number, such as "of 5". Null for none.
  final String? caption;

  /// Colours that run round the arc, with [stops] placing each one as a share
  /// of the whole circle (0 to 1). Every accessory ring has a gradient.
  final List<Color> gradient;
  final List<double> stops;

  final double size;

  /// The unfilled band. Null means the app's own dim accent.
  final Color? trackColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _MiniRingPainter(
          fraction: fraction.clamp(0.0, 1.0),
          centre: centre,
          caption: caption,
          gradient: gradient,
          stops: stops,
          colors: colors,
          track: trackColor ?? colors.accentDim,
        ),
      ),
    );
  }
}

class _MiniRingPainter extends CustomPainter {
  _MiniRingPainter({
    required this.fraction,
    required this.centre,
    required this.caption,
    required this.gradient,
    required this.stops,
    required this.colors,
    required this.track,
  });

  final Color track;
  final double fraction;
  final String? centre;
  final String? caption;
  final List<Color> gradient;
  final List<double> stops;
  final AppColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final stroke = size.shortestSide * 0.0757; // Véda's 10 at 132
    const edgeGap = 3.0;
    // the band, with room outside it for the thin edge ring
    final r = size.shortestSide / 2 - stroke / 2 - edgeGap - 1;
    final rect = Rect.fromCircle(center: c, radius: r);
    final edgeColour = gradient.last;

    // the thin edge rings just outside and inside the band, as Véda's has
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = edgeColour.withValues(alpha: 0.85);
    canvas.drawCircle(c, r + stroke / 2 + edgeGap, edge);
    canvas.drawCircle(c, r - stroke / 2 - edgeGap, edge);

    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = track,
    );

    const start = -math.pi / 2;
    if (fraction > 0) {
      final sweep = fraction * 2 * math.pi;
      // flat ends, as every Véda ring has
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.butt
          ..shader = SweepGradient(
            colors: gradient,
            stops: stops,
            transform: const GradientRotation(-math.pi / 2),
          ).createShader(rect),
      );
      _endLine(canvas, c, r, stroke, start + sweep, edgeColour);
    }

    if (centre != null) {
      _text(
        canvas,
        centre!,
        c + Offset(0, -size.shortestSide * 0.06),
        size.shortestSide * 0.28,
        colors.textPrimary,
        display: true,
      );
    }
    if (caption != null) {
      // a long caption shrinks to fit inside the ring rather than touch it
      final capAt = size.shortestSide * 0.17;
      final reach = r - stroke / 2 - edgeGap;
      final drop = capAt + size.shortestSide * 0.05;
      final room =
          2 * math.sqrt(math.max(0.0, reach * reach - drop * drop)) * 0.94;
      _text(
        canvas,
        caption!,
        c + Offset(0, capAt),
        size.shortestSide * 0.1,
        colors.textMuted,
        maxWidth: room,
      );
    }
  }

  /// Véda's end cap: a straight line across the band where the arc stops, warm
  /// white, with a soft glow behind it, clipped to the band.
  void _endLine(
    Canvas canvas,
    Offset c,
    double r,
    double stroke,
    double endAngle,
    Color glow,
  ) {
    final markerWidth = stroke * 0.4;
    final angle = endAngle - (markerWidth / 2) / r;
    final dir = Offset(math.cos(angle), math.sin(angle));
    final inner = c + dir * (r - stroke / 2);
    final outer = c + dir * (r + stroke / 2);
    canvas.save();
    canvas.clipPath(
      Path()
        ..fillType = PathFillType.evenOdd
        ..addOval(Rect.fromCircle(center: c, radius: r + stroke / 2))
        ..addOval(Rect.fromCircle(center: c, radius: r - stroke / 2)),
    );
    canvas.drawLine(
      inner,
      outer,
      Paint()
        ..strokeWidth = stroke * 0.9
        ..color = glow.withValues(alpha: 0.7)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, stroke * 0.22),
    );
    canvas.drawLine(
      inner,
      outer,
      Paint()
        ..strokeWidth = markerWidth
        ..color = _markerWhite,
    );
    canvas.restore();
  }

  void _text(
    Canvas canvas,
    String text,
    Offset at,
    double size,
    Color color, {
    bool display = false,
    double? maxWidth,
  }) {
    var tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: size,
          color: color,
          fontFamily: display ? kDisplayFont : null,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    if (maxWidth != null && tp.width > maxWidth) {
      tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(fontSize: size * maxWidth / tp.width, color: color),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
    }
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_MiniRingPainter old) =>
      old.fraction != fraction ||
      old.centre != centre ||
      old.caption != caption ||
      old.gradient != gradient ||
      old.stops != stops ||
      old.track != track ||
      old.colors != colors;
}
