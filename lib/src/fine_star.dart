// The Véda family's star: the twinkling star of Véda Lifestyle's centrepiece. A
// wide soft halo, a bright heart, four long fine rays and four short ones, each
// ray tapering to nothing. Every app that draws a star as a star (a lit star in
// a constellation, a night sky's featured star) draws this one, so a star looks
// the same in every app. See UI_RULES.md.
//
// Lifestyle drew it first (its heart_art.dart); this is that drawing, moved
// here so the apps share it. With the defaults it is exactly Lifestyle's.

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

const _white = Color(0xFFFFFDF5);
const _starlight = Color(0xFFDCE8FF);

/// A thin ray through [p] along [angle]: widest at the middle, tapering to
/// nothing at both ends, and fading as it goes.
void _needle(
  Canvas canvas,
  Offset p,
  double angle,
  double len,
  double halfWidth,
  double alpha,
) {
  final d = Offset(math.cos(angle), math.sin(angle));
  final q = Offset(-d.dy, d.dx) * halfWidth;
  final a = p + d * len, b = p - d * len;
  final path = Path()
    ..moveTo(a.dx, a.dy)
    ..quadraticBezierTo(
      p.dx + q.dx * 0.5,
      p.dy + q.dy * 0.5,
      p.dx + q.dx,
      p.dy + q.dy,
    )
    ..quadraticBezierTo(p.dx + q.dx * 0.5, p.dy + q.dy * 0.5, b.dx, b.dy)
    ..quadraticBezierTo(
      p.dx - q.dx * 0.5,
      p.dy - q.dy * 0.5,
      p.dx - q.dx,
      p.dy - q.dy,
    )
    ..quadraticBezierTo(p.dx - q.dx * 0.5, p.dy - q.dy * 0.5, a.dx, a.dy)
    ..close();
  canvas.drawPath(
    path,
    Paint()
      ..shader = ui.Gradient.radial(
        p,
        len,
        [
          _white.withValues(alpha: alpha),
          _white.withValues(alpha: alpha * 0.55),
          _white.withValues(alpha: 0),
        ],
        const [0, 0.5, 1],
      ),
  );
}

/// One lit star at [p], [v] of the way to full (0 to 1): brighter and larger
/// the higher [v]; [tw] (0 to 1) is its twinkle. [scale] sizes it: 1 is the
/// star in Lifestyle's centrepiece, which is large, so a small star (on a dial,
/// by an icon) uses a fraction of it.
///
/// Two things are meant to be fixed pixel sizes at Lifestyle's size and so do
/// not follow [scale] on their own; a small star lowers them: [minRay] is the
/// least half-width of a ray, and [heartScale] sizes the bright point at the
/// centre (1 is Lifestyle's).
void paintFineStar(
  Canvas canvas,
  Offset p,
  double v,
  double tw,
  double scale, {
  double minRay = 1.0,
  double heartScale = 1.0,
}) {
  final r = (4 + 26 * math.pow(v, 1.6)) * scale * (0.93 + 0.12 * tw);
  final wide = r * 2.3;
  canvas.drawCircle(
    p,
    wide,
    Paint()
      ..shader = ui.Gradient.radial(
        p,
        wide,
        [
          _starlight.withValues(alpha: (0.16 + 0.26 * v) * (0.6 + 0.5 * tw)),
          _starlight.withValues(alpha: (0.05 + 0.08 * v) * (0.6 + 0.5 * tw)),
          _starlight.withValues(alpha: 0),
        ],
        const [0, 0.4, 1],
      ),
  );
  canvas.drawCircle(
    p,
    r * 0.8,
    Paint()
      ..shader = ui.Gradient.radial(
        p,
        r * 0.8,
        [
          _white.withValues(alpha: 0.85),
          _white.withValues(alpha: 0.40 + 0.14 * tw),
          _white.withValues(alpha: 0),
        ],
        const [0, 0.32, 1],
      ),
  );
  final w = math.max(minRay, r * 0.12);
  final a = 0.82 + 0.18 * tw;
  _needle(canvas, p, 0, r * 1.6, w, a);
  _needle(canvas, p, math.pi / 2, r * 1.95, w, a);
  _needle(canvas, p, math.pi / 4, r * 0.72, w * 0.7, a * 0.6);
  _needle(canvas, p, -math.pi / 4, r * 0.72, w * 0.7, a * 0.6);
  canvas.drawCircle(p, (1.8 + 1.6 * v) * heartScale, Paint()..color = _white);
}
