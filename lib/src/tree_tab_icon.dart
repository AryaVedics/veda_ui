// Véda Allergy's own Today tab icon, and its sign wherever it is shown among
// the other apps (Today's clock, the Véda Link list): a small copy of the
// pollen tree, a domed
// crown over fanning branches on a short trunk. An outline when idle; solid
// with the branches cut through it when selected, as the Lifestyle tab's heart
// is. The same 24 x 24 grid as Phosphor's icons, so it sits beside them.

import 'package:flutter/material.dart';

import 'app_colors.dart';

class TreeTabIcon extends StatelessWidget {
  const TreeTabIcon({
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
      painter: _TreePainter(
        filled: selected,
        color: color,
        cut: selected ? context.colors.onAccent : color,
      ),
    ),
  );
}

/// The crown: a cloud of leaves, lumpy along the top and underneath, so it
/// reads as foliage and not as a cap.
Path _crown() {
  Path blob(double x, double y, double r) =>
      Path()..addOval(Rect.fromCircle(center: Offset(x, y), radius: r));
  // wide and low, like the drawn tree's dome
  var p = blob(12, 7.2, 5.2);
  for (final (x, y, r) in const <(double, double, double)>[
    (5.2, 8.6, 3.0),
    (7.8, 5.6, 3.3),
    (12.0, 4.2, 3.6),
    (16.2, 5.6, 3.3),
    (18.8, 8.6, 3.0),
    (8.6, 9.6, 2.5),
    (12.0, 9.2, 3.0),
    (15.4, 9.6, 2.5),
  ]) {
    p = Path.combine(PathOperation.union, p, blob(x, y, r));
  }
  return p;
}

/// The limbs, fanning up from the top of the trunk into the crown, so they
/// show in the gap beneath it.
Path _branches() => Path()
  ..moveTo(12, 15.4)
  ..quadraticBezierTo(11.6, 12.8, 7.2, 10.2)
  ..moveTo(12, 15.4)
  ..quadraticBezierTo(11.8, 12, 9.6, 8.2)
  ..moveTo(12, 15.4)
  ..lineTo(12, 7.4)
  ..moveTo(12, 15.4)
  ..quadraticBezierTo(12.2, 12, 14.6, 8.2)
  ..moveTo(12, 15.4)
  ..quadraticBezierTo(12.4, 12.8, 16.8, 10.2);

/// A slender trunk, wider at the foot, with the roots spreading. Drawn as its
/// two edges, open at the foot, so it does not read as a bottle.
Path _trunkEdges() => Path()
  ..moveTo(11.1, 15.4)
  ..cubicTo(11.3, 17.8, 11.0, 19.8, 8.8, 21.8)
  ..moveTo(12.9, 15.4)
  ..cubicTo(12.7, 17.8, 13.0, 19.8, 15.2, 21.8);

Path _trunkSolid() => Path()
  ..moveTo(11.1, 15.4)
  ..cubicTo(11.3, 17.8, 11.0, 19.8, 8.8, 21.8)
  ..lineTo(15.2, 21.8)
  ..cubicTo(13.0, 19.8, 12.7, 17.8, 12.9, 15.4)
  ..close();

class _TreePainter extends CustomPainter {
  _TreePainter({required this.filled, required this.color, required this.cut});

  final bool filled;
  final Color color;

  /// The colour of the branches over the solid crown (the cut-through look).
  final Color cut;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 1.5
      ..color = color;

    final crown = _crown();
    final wood = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = filled ? 1.35 : 1.15
      ..color = color;
    // the trunk first, so the crown sits over it
    canvas.drawPath(
      filled ? _trunkSolid() : _trunkEdges(),
      filled
          ? (Paint()..color = color)
          : (Paint()
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.round
              ..strokeWidth = 1.25
              ..color = color),
    );
    // the limbs
    canvas.drawPath(_branches(), wood);
    // the crown: solid, or an outline
    if (filled) {
      canvas.drawPath(crown, Paint()..color = color);
      // the limbs show through it as cut lines
      canvas.save();
      canvas.clipPath(crown);
      canvas.drawPath(_branches(), wood..color = cut);
      canvas.restore();
    } else {
      // idle: the limbs stay inside the outline, as the tree's skeleton
      canvas.drawPath(crown, stroke);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_TreePainter old) =>
      old.filled != filled || old.color != color || old.cut != cut;
}
