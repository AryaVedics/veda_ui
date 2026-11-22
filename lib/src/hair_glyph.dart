// Véda Hair's sign: a little circle of braid, as on Hair's icon, the plaits
// leaning in and out in turn round the ring, with a flower tucked into it at
// one o'clock. An outline when idle; solid when
// selected, as the Lifestyle tab's heart is. The same 24 x 24 grid as
// Phosphor's icons, so it sits beside them.

import 'dart:math' as math;

import 'package:flutter/material.dart';

class HairGlyph extends StatelessWidget {
  const HairGlyph({
    super.key,
    required this.selected,
    required this.color,
    this.size = 24,
  });

  final bool selected;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: CustomPaint(
      painter: _BraidRingPainter(filled: selected, color: color),
    ),
  );
}

/// Where the flower is tucked in: one o'clock (clock degrees, 0 at twelve).
const _flowerDeg = 22.5;

/// The plaits round the ring: almonds along it, leaning in and out in turn.
List<Path> _plaits() {
  // many small plaits with a gentle lean, so the ring stays round (ten
  // leaning hard made corners, like a pentagon)
  const n = 16, r = 7.7;
  return [
    for (var i = 0; i < n; i++)
      // the flower sits where the plait at one o'clock would be
      if ((i / n * 360 - _flowerDeg).abs() > 14)
        () {
          final a = i / n * math.pi * 2 - math.pi / 2;
          final c = Offset(12 + r * math.cos(a), 12 + r * math.sin(a));
          // along the ring, turned in or out
          final lean = a + math.pi / 2 + (i.isEven ? 0.42 : -0.42);
          final u = Offset(math.cos(lean), math.sin(lean)) * 2.1;
          final v = Offset(-u.dy, u.dx) * 0.5;
          final p0 = c - u, p1 = c + u;
          return Path()
            ..moveTo(p0.dx, p0.dy)
            ..quadraticBezierTo(c.dx + v.dx * 2, c.dy + v.dy * 2, p1.dx, p1.dy)
            ..quadraticBezierTo(c.dx - v.dx * 2, c.dy - v.dy * 2, p0.dx, p0.dy)
            ..close();
        }(),
  ];
}

class _BraidRingPainter extends CustomPainter {
  _BraidRingPainter({required this.filled, required this.color});

  final bool filled;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final paint = filled
        ? (Paint()..color = color)
        : (Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.1
            ..strokeJoin = StrokeJoin.round
            ..color = color);
    for (final p in _plaits()) {
      canvas.drawPath(p, paint);
    }
    // the flower: five solid petals round an open heart, a little larger
    // than a plait, so it reads at the smallest sizes
    final a = _flowerDeg * math.pi / 180 - math.pi / 2;
    final c = Offset(12 + 7.7 * math.cos(a), 12 + 7.7 * math.sin(a));
    canvas.saveLayer(Rect.fromCircle(center: c, radius: 5), Paint());
    for (var j = 0; j < 5; j++) {
      final pa = j * math.pi * 2 / 5 - math.pi / 2;
      canvas.drawCircle(
        c + Offset(math.cos(pa), math.sin(pa)) * 2.05,
        1.65,
        Paint()..color = color,
      );
    }
    canvas.drawCircle(c, 0.95, Paint()..blendMode = BlendMode.clear);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BraidRingPainter old) =>
      old.filled != filled || old.color != color;
}
