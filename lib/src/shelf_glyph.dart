// The Shelf tab's icon: three bottles standing on a shelf line. Outlined when
// the tab is idle, filled when it is selected.

import 'package:flutter/material.dart';

class ShelfGlyph extends StatelessWidget {
  const ShelfGlyph({super.key, required this.color, this.filled = false});

  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 24,
    height: 24,
    child: CustomPaint(painter: _ShelfGlyphPainter(color, filled)),
  );
}

class _ShelfGlyphPainter extends CustomPainter {
  _ShelfGlyphPainter(this.color, this.filled);

  final Color color;
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    final body = Paint()
      ..color = color
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 1.5 * k
      ..strokeJoin = StrokeJoin.round;
    final cap = Paint()..color = color;

    // the shelf
    canvas.drawLine(
      Offset(2 * k, 20.5 * k),
      Offset(22 * k, 20.5 * k),
      Paint()
        ..color = color
        ..strokeWidth = 1.8 * k
        ..strokeCap = StrokeCap.round,
    );

    // three bottles of different heights, standing on the shelf
    const bottles = [
      (x: 6.0, top: 9.0, w: 4.5),
      (x: 12.0, top: 6.5, w: 5.0),
      (x: 18.0, top: 10.5, w: 4.5),
    ];
    for (final b in bottles) {
      final left = (b.x - b.w / 2) * k;
      final right = (b.x + b.w / 2) * k;
      final neck = (b.top + 2.2) * k;
      // the neck and shoulders
      final shape = Path()
        ..moveTo(left + 0.9 * k, b.top * k + 2.5 * k)
        ..lineTo(left + 0.9 * k, neck)
        ..lineTo(left, neck + 1.5 * k)
        ..lineTo(left, 20.5 * k)
        ..lineTo(right, 20.5 * k)
        ..lineTo(right, neck + 1.5 * k)
        ..lineTo(right - 0.9 * k, neck)
        ..lineTo(right - 0.9 * k, b.top * k + 2.5 * k)
        ..close();
      canvas.drawPath(shape, body);
      // the cap
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(
            left + 0.7 * k,
            b.top * k,
            right - 0.7 * k,
            (b.top + 2.5) * k,
          ),
          Radius.circular(0.8 * k),
        ),
        cap,
      );
    }
  }

  @override
  bool shouldRepaint(_ShelfGlyphPainter old) =>
      old.color != color || old.filled != filled;
}
