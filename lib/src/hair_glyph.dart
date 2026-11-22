// Véda Hair's sign: a little circle of braid, as on Hair's icon, the plaits
// leaning in and out in turn round the ring. An outline when idle; solid when
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

/// The plaits round the ring: almonds along it, leaning in and out in turn.
List<Path> _plaits() {
  // many small plaits with a gentle lean, so the ring stays round (ten
  // leaning hard made corners, like a pentagon)
  const n = 16, r = 7.7;
  return [
    for (var i = 0; i < n; i++)
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
  }

  @override
  bool shouldRepaint(_BraidRingPainter old) =>
      old.filled != filled || old.color != color;
}
