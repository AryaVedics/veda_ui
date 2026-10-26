// The soft glow behind a chart that shows a live score. One recipe for every
// Véda app, so the constellation reads as one family. It fades to nothing
// inside the chart's own box, so no edge ever shows.

import 'package:flutter/material.dart';

/// Paints the glow in [box], centred on [centre] (default: the box's middle).
/// [alpha] is how strong the glow is at its middle.
void paintScoreGlow(
  Canvas canvas,
  Rect box,
  Color tone, {
  double alpha = 0.16,
  Offset? centre,
}) {
  final c = centre ?? box.center;
  // Ends at 46% of the box's height, which keeps it inside the box wherever
  // the centre sits.
  final r = box.height * 0.46;
  canvas.drawCircle(
    c,
    r,
    Paint()
      ..shader = RadialGradient(
        colors: [tone.withValues(alpha: alpha), tone.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: c, radius: r)),
  );
}

/// A chart with the glow behind it, when the chart has a live score.
class ScoreGlow extends StatelessWidget {
  const ScoreGlow({
    super.key,
    required this.tone,
    required this.active,
    required this.child,
  });

  /// The app's own colour: gold for Lifestyle, teal for Routine.
  final Color tone;

  /// False when there is no score yet: the chart then sits without a glow.
  final bool active;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!active) return child;
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _ScoreGlowPainter(tone))),
        child,
      ],
    );
  }
}

class _ScoreGlowPainter extends CustomPainter {
  _ScoreGlowPainter(this.tone);

  final Color tone;

  @override
  void paint(Canvas canvas, Size size) =>
      paintScoreGlow(canvas, Offset.zero & size, tone);

  @override
  bool shouldRepaint(_ScoreGlowPainter old) => old.tone != tone;
}
