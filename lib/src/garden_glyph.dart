// Véda Garden's sign: a little ring of flowering vine, as on Garden's icon:
// a thin stem round a circle, leaves along it leaning out and in, and three
// small flowers. An outline when idle; solid leaves when selected, as the
// Lifestyle tab's heart is. The same 24 x 24 grid as Phosphor's icons, so it
// sits beside them.

import 'dart:math' as math;

import 'package:flutter/material.dart';

class GardenGlyph extends StatelessWidget {
  const GardenGlyph({
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
      painter: _WreathPainter(filled: selected, color: color),
    ),
  );
}

const _r = 7.4;

/// Where on the ring the flowers are (clock degrees, 0 at twelve).
const _flowers = [30.0, 150.0, 270.0];

class _WreathPainter extends CustomPainter {
  _WreathPainter({required this.filled, required this.color});

  final bool filled;
  final Color color;

  Offset _at(double deg, [double r = _r]) {
    final a = deg * math.pi / 180 - math.pi / 2;
    return Offset(12 + r * math.cos(a), 12 + r * math.sin(a));
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    // the stem
    canvas.drawCircle(const Offset(12, 12), _r, line);
    // the leaves, between the flowers, leaning out and in in turn
    var out = true;
    for (var deg = 0.0; deg < 360; deg += 30) {
      if (_flowers.contains(deg)) continue;
      final base = _at(deg);
      final a = deg * math.pi / 180 - math.pi / 2;
      final dir = Offset(math.cos(a), math.sin(a)) * (out ? 1 : -1);
      final along = Offset(-math.sin(a), math.cos(a));
      final tip = base + dir * 2.4 + along * 2.0;
      final mid = Offset.lerp(base, tip, 0.5)!;
      final n = Offset(-(tip - base).dy, (tip - base).dx) * 0.35;
      final leaf = Path()
        ..moveTo(base.dx, base.dy)
        ..quadraticBezierTo(mid.dx + n.dx, mid.dy + n.dy, tip.dx, tip.dy)
        ..quadraticBezierTo(mid.dx - n.dx, mid.dy - n.dy, base.dx, base.dy)
        ..close();
      canvas.drawPath(leaf, filled ? (Paint()..color = color) : line);
      out = !out;
    }
    // the flowers: five petals round a heart
    for (final deg in _flowers) {
      final c = _at(deg);
      for (var j = 0; j < 5; j++) {
        final pa = j * math.pi * 2 / 5 - math.pi / 2;
        final p = c + Offset(math.cos(pa), math.sin(pa)) * 1.5;
        canvas.drawCircle(p, 1.05, filled ? (Paint()..color = color) : line);
      }
      canvas.drawCircle(c, 0.55, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_WreathPainter old) =>
      old.filled != filled || old.color != color;
}
