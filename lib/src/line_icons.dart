// The Véda line icons: every tab icon and every app sign in the constellation,
// drawn here by hand in one system so they read as one family.
//
// Each icon is drawn on a 24-unit grid with the same line weight
// ([kLineIconStroke]), rounded ends and rounded joins. Idle, an icon is a fine
// line in the colour it is given. Selected, the line is the same and the main
// shape takes a soft fill of the same colour, so a selected tab reads clearly
// without the heavy solid shapes of a stock icon set.
//
// The app signs follow the apps' own icons: Today's dial with the sun on its
// rim, Routine's shelf, Sun's sun, Allergy's tree, Sleep's moon, Lifestyle's
// heart with its pulse, Kitchen's pot, Curio's capsule, Hair's circle of braid
// with its flower, Garden's ring of vine with its blossom, Learn's open book and
// Cycle's lotus. Véda itself is its medallion (a picture, not a line icon).

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The line weight, in units of the 24-unit grid (1.35 px at 24 px).
const double kLineIconStroke = 1.35;

enum VedaIcon {
  // the app signs
  today,
  routine,
  sun,
  allergy,
  sleep,
  lifestyle,
  kitchen,
  curio,
  hair,
  garden,
  learn,
  cycle,
  // the tabs inside the apps
  profile,
  notebook,
  calendar,
  chart,
  plants,
  recipes,
  library,
  nutrition,
  fitness,
  history,
  weather,
  notes,
}

/// The sign for an app's id ('routine', 'sun' ...), or null for Véda itself
/// (its medallion) and ids it does not know.
VedaIcon? vedaIconForApp(String id) => switch (id) {
  'today' => VedaIcon.today,
  'routine' => VedaIcon.routine,
  'sun' => VedaIcon.sun,
  'allergy' => VedaIcon.allergy,
  'sleep' => VedaIcon.sleep,
  'lifestyle' => VedaIcon.lifestyle,
  'kitchen' => VedaIcon.kitchen,
  'curio' => VedaIcon.curio,
  'hair' => VedaIcon.hair,
  'garden' => VedaIcon.garden,
  'learn' => VedaIcon.learn,
  'cycle' => VedaIcon.cycle,
  _ => null,
};

class VedaLineIcon extends StatelessWidget {
  const VedaLineIcon(
    this.icon, {
    super.key,
    required this.color,
    this.selected = false,
    this.size = 24,
  });

  final VedaIcon icon;
  final Color color;
  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(
      painter: VedaLineIconPainter(icon, color: color, selected: selected),
    ),
  );
}

class VedaLineIconPainter extends CustomPainter {
  const VedaLineIconPainter(
    this.icon, {
    required this.color,
    this.selected = false,
  });

  final VedaIcon icon;
  final Color color;
  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    final s = math.min(size.width, size.height) / 24;
    canvas.translate((size.width - 24 * s) / 2, (size.height - 24 * s) / 2);
    canvas.scale(s);
    _Pen(canvas, color, selected).draw(icon);
    canvas.restore();
  }

  @override
  bool shouldRepaint(VedaLineIconPainter old) =>
      old.icon != icon || old.color != color || old.selected != selected;
}

/// Draws one icon on the 24-unit grid.
class _Pen {
  _Pen(this.canvas, this.color, this.selected);

  final Canvas canvas;
  final Color color;
  final bool selected;

  Paint get _line => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = kLineIconStroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = color;

  Paint get _solid => Paint()..color = color;

  /// The outline; when selected, the shape also takes a soft fill.
  void shape(Path p) {
    if (selected) {
      canvas.drawPath(p, Paint()..color = color.withValues(alpha: 0.28));
    }
    canvas.drawPath(p, _line);
  }

  void stroke(Path p) => canvas.drawPath(p, _line);

  void line(double x1, double y1, double x2, double y2) =>
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), _line);

  void dot(double x, double y, double r) =>
      canvas.drawCircle(Offset(x, y), r, _solid);

  Path circle(double x, double y, double r) =>
      Path()..addOval(Rect.fromCircle(center: Offset(x, y), radius: r));

  Path rrect(double l, double t, double r, double b, double radius) =>
      Path()..addRRect(RRect.fromLTRBR(l, t, r, b, Radius.circular(radius)));

  /// A ring of radius [r] round the middle, leaving out the arc from [gapFrom]
  /// to [gapTo] (radians, clockwise from three o'clock).
  Path ringWithGap(double r, double gapFrom, double gapTo) {
    final sweep = 2 * math.pi - (gapTo - gapFrom);
    return Path()..addArc(
      Rect.fromCircle(center: const Offset(12, 12), radius: r),
      gapTo,
      sweep,
    );
  }

  Offset onRing(double r, double a) =>
      Offset(12 + r * math.cos(a), 12 + r * math.sin(a));

  /// A small flower: [n] round petals about [c], and a dot in the middle.
  void flower(Offset c, {int n = 5, double petal = 1.05, double reach = 1.3}) {
    final petals = Path();
    for (var i = 0; i < n; i++) {
      final a = -math.pi / 2 + i * 2 * math.pi / n;
      petals.addOval(
        Rect.fromCircle(
          center: c + Offset(math.cos(a), math.sin(a)) * reach,
          radius: petal,
        ),
      );
    }
    shape(petals);
    dot(c.dx, c.dy, 0.6);
  }

  /// A leaf from [base] to [tip]: two gentle arcs.
  Path leaf(Offset base, Offset tip, {double width = 1.15}) {
    final d = tip - base;
    final n = Offset(-d.dy, d.dx) / d.distance * width;
    final mid = base + d / 2;
    return Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(mid.dx + n.dx, mid.dy + n.dy, tip.dx, tip.dy)
      ..quadraticBezierTo(mid.dx - n.dx, mid.dy - n.dy, base.dx, base.dy)
      ..close();
  }

  void draw(VedaIcon icon) {
    switch (icon) {
      case VedaIcon.today:
        _today();
      case VedaIcon.routine:
        _routine();
      case VedaIcon.sun:
        _sun();
      case VedaIcon.allergy:
        _allergy();
      case VedaIcon.sleep:
        _sleep();
      case VedaIcon.lifestyle:
        _lifestyle();
      case VedaIcon.kitchen:
        _kitchen();
      case VedaIcon.curio:
        _curio();
      case VedaIcon.hair:
        _hair();
      case VedaIcon.garden:
        _garden();
      case VedaIcon.learn:
        _learn();
      case VedaIcon.cycle:
        _cycle();
      case VedaIcon.profile:
        _profile();
      case VedaIcon.notebook:
        _notebook();
      case VedaIcon.calendar:
        _calendar();
      case VedaIcon.chart:
        _chart();
      case VedaIcon.plants:
        _plants();
      case VedaIcon.recipes:
        _recipes();
      case VedaIcon.library:
        _library();
      case VedaIcon.nutrition:
        _nutrition();
      case VedaIcon.fitness:
        _fitness();
      case VedaIcon.history:
        _history();
      case VedaIcon.weather:
        _weather();
      case VedaIcon.notes:
        _notes();
    }
  }

  // ------------------------------------------------------------ app signs

  /// Today: the dial as it is in the app: the rim, the face in the middle,
  /// the hours 12, 3, 6 and 9 marked between them, and the sun on the rim.
  void _today() {
    const r = 8.8;
    const sunA = -math.pi / 4; // half past one
    if (selected) {
      canvas.drawPath(
        circle(12, 12, r),
        Paint()..color = color.withValues(alpha: 0.28),
      );
    }
    stroke(ringWithGap(r, sunA - 0.32, sunA + 0.32));
    stroke(circle(12, 12, 4.1));
    for (var i = 0; i < 4; i++) {
      final a = -math.pi / 2 + i * math.pi / 2;
      final p1 = onRing(5.9, a), p2 = onRing(7.2, a);
      line(p1.dx, p1.dy, p2.dx, p2.dy);
    }
    final sun = onRing(r, sunA);
    canvas.drawCircle(sun, 2.3, _solid);
  }

  /// Routine: a shelf of two rows, a tall bottle and a jar above, a pump
  /// bottle and a round pot below.
  void _routine() {
    line(3.5, 11.5, 20.5, 11.5);
    line(3.5, 20.5, 20.5, 20.5);
    // tall bottle with a narrow neck
    shape(
      Path()
        ..moveTo(6, 11.5)
        ..lineTo(6, 6.6)
        ..quadraticBezierTo(6, 5.6, 7, 5.4)
        ..lineTo(7, 3.6)
        ..lineTo(9, 3.6)
        ..lineTo(9, 5.4)
        ..quadraticBezierTo(10, 5.6, 10, 6.6)
        ..lineTo(10, 11.5),
    );
    // a jar with its lid
    shape(rrect(12.5, 7.4, 17.5, 11.5, 1.2));
    line(13, 5.9, 17, 5.9);
    // a pump bottle
    shape(rrect(6, 15, 10, 20.5, 1.2));
    line(8, 15, 8, 13.2);
    line(8, 13.2, 10.2, 13.2);
    // a round pot
    shape(
      Path()
        ..moveTo(12.6, 17)
        ..lineTo(17.4, 17)
        ..quadraticBezierTo(17.4, 20.5, 15, 20.5)
        ..lineTo(15, 20.5)
        ..quadraticBezierTo(12.6, 20.5, 12.6, 17)
        ..close(),
    );
  }

  /// Sun: a round sun and eight rays.
  void _sun() {
    shape(circle(12, 12, 4.3));
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      final long = i.isEven;
      final p1 = onRing(6.7, a), p2 = onRing(long ? 9.4 : 8.6, a);
      line(p1.dx, p1.dy, p2.dx, p2.dy);
    }
  }

  /// Allergy: a tree with a round, three-lobed crown and two branches.
  void _allergy() {
    final crown = Path.combine(
      PathOperation.union,
      Path.combine(
        PathOperation.union,
        circle(12, 7.9, 4.3),
        circle(7.6, 11, 3.4),
      ),
      circle(16.4, 11, 3.4),
    );
    shape(crown);
    line(12, 13.8, 12, 20.5);
    line(12, 16.4, 9.6, 14.1);
    line(12, 15.4, 14.5, 13.2);
    line(8.5, 20.5, 15.5, 20.5);
  }

  /// Sleep: a crescent moon and two small stars.
  void _sleep() {
    final moon = Path.combine(
      PathOperation.difference,
      circle(10.8, 12.8, 7.4),
      circle(15, 9.2, 6.2),
    );
    shape(moon);
    // a four-pointed star with curved sides, solid
    void star(double x, double y, double r) {
      const pinch = 0.22;
      canvas.drawPath(
        Path()
          ..moveTo(x, y - r)
          ..quadraticBezierTo(x + r * pinch, y - r * pinch, x + r, y)
          ..quadraticBezierTo(x + r * pinch, y + r * pinch, x, y + r)
          ..quadraticBezierTo(x - r * pinch, y + r * pinch, x - r, y)
          ..quadraticBezierTo(x - r * pinch, y - r * pinch, x, y - r)
          ..close(),
        _solid,
      );
    }

    star(17.4, 4.6, 2.0);
    star(20.6, 9.8, 1.35);
  }

  /// Lifestyle: a heart with a pulse running through it.
  void _lifestyle() {
    shape(
      Path()
        ..moveTo(12, 20)
        ..cubicTo(5, 15, 2.6, 11, 4.2, 7.9)
        ..cubicTo(5.8, 4.9, 9.9, 4.7, 12, 7.7)
        ..cubicTo(14.1, 4.7, 18.2, 4.9, 19.8, 7.9)
        ..cubicTo(21.4, 11, 19, 15, 12, 20)
        ..close(),
    );
    stroke(
      Path()
        ..moveTo(4.6, 12.2)
        ..lineTo(8.2, 12.2)
        ..lineTo(9.6, 9.8)
        ..lineTo(11.3, 15.2)
        ..lineTo(13.1, 8.2)
        ..lineTo(14.6, 12.2)
        ..lineTo(19.4, 12.2),
    );
  }

  /// Kitchen: a karahi, the two-handled pan, a short foot beneath it and three
  /// curls of steam above.
  void _kitchen() {
    shape(
      Path()
        ..moveTo(4.5, 11.5)
        ..lineTo(19.5, 11.5)
        ..cubicTo(19.5, 16.2, 16.2, 19.5, 12, 19.5)
        ..cubicTo(7.8, 19.5, 4.5, 16.2, 4.5, 11.5)
        ..close(),
    );
    stroke(
      Path()
        ..moveTo(4.5, 12.5)
        ..cubicTo(2.4, 12.5, 2, 11, 3, 10.2)
        ..moveTo(19.5, 12.5)
        ..cubicTo(21.6, 12.5, 22, 11, 21, 10.2),
    );
    line(9.5, 21, 14.5, 21);
    stroke(
      Path()
        ..moveTo(9, 8.5)
        ..cubicTo(8, 7, 10, 6, 9, 4.8)
        ..moveTo(12, 8.5)
        ..cubicTo(11, 7, 13, 5.8, 12, 4)
        ..moveTo(15, 8.5)
        ..cubicTo(14, 7, 16, 6, 15, 4.8),
    );
  }

  /// Curio: a capsule, tilted, its two halves meeting in the middle.
  void _curio() {
    canvas.save();
    canvas.translate(12, 12);
    canvas.rotate(-math.pi / 4);
    final body = rrect(-8.6, -3.7, 8.6, 3.7, 3.7);
    if (selected) {
      // one half filled: the capsule's two colours
      canvas.save();
      canvas.clipRect(const Rect.fromLTRB(-9, -4, 0, 4));
      canvas.drawPath(body, Paint()..color = color.withValues(alpha: 0.42));
      canvas.restore();
    }
    stroke(body);
    line(0, -3.7, 0, 3.7);
    canvas.restore();
  }

  /// Hair: a circle of braid, drawn as a twist: short strokes all leaning the
  /// same way round the ring, between a fine inner and outer edge, and a flower
  /// tucked in at one o'clock.
  void _hair() {
    const r = 7.7, half = 1.35, flowerDeg = 22.5;
    final flowerA = flowerDeg * math.pi / 180 - math.pi / 2;
    const gap = 0.42;
    if (selected) {
      canvas.drawPath(
        Path.combine(
          PathOperation.difference,
          circle(12, 12, r + half),
          circle(12, 12, r - half),
        ),
        Paint()..color = color.withValues(alpha: 0.28),
      );
    }
    const n = 18;
    const span = 2 * math.pi - 2 * gap;
    for (var i = 0; i <= n; i++) {
      final a = flowerA + gap + span * i / n;
      final p1 = onRing(r - half, a - 0.16);
      final p2 = onRing(r + half, a + 0.16);
      line(p1.dx, p1.dy, p2.dx, p2.dy);
    }
    flower(onRing(r, flowerA), petal: 1.05, reach: 1.45);
  }

  /// Garden: a ring of vine with leaves along it and a blossom at one o'clock.
  void _garden() {
    const r = 7.6;
    const flowerA = -math.pi / 3;
    stroke(ringWithGap(r, flowerA - 0.4, flowerA + 0.4));
    var out = true;
    for (final deg in const [5.0, 55.0, 105.0, 155.0, 205.0, 255.0]) {
      final a = deg * math.pi / 180;
      final base = onRing(r, a);
      // each leaf lies along the vine (clockwise), leaning a little out of the
      // ring or into it in turn
      final tangent = Offset(-math.sin(a), math.cos(a));
      final radial = Offset(math.cos(a), math.sin(a));
      final tip = base + tangent * 3.1 + radial * (out ? 1.5 : -1.5);
      shape(leaf(base, tip, width: 1.1));
      out = !out;
    }
    flower(onRing(r, flowerA), n: 6, petal: 0.85, reach: 1.25);
  }

  /// Learn: an open book.
  void _learn() {
    shape(
      Path()
        ..moveTo(12, 7.2)
        ..quadraticBezierTo(8.2, 5.2, 3.4, 5.9)
        ..lineTo(3.4, 18.6)
        ..quadraticBezierTo(8.2, 17.9, 12, 19.8)
        ..close(),
    );
    shape(
      Path()
        ..moveTo(12, 7.2)
        ..quadraticBezierTo(15.8, 5.2, 20.6, 5.9)
        ..lineTo(20.6, 18.6)
        ..quadraticBezierTo(15.8, 17.9, 12, 19.8)
        ..close(),
    );
  }

  /// Cycle: a lotus, three petals over a low curve.
  void _cycle() {
    shape(
      Path()
        ..moveTo(12, 4.2)
        ..quadraticBezierTo(15.6, 9.2, 12, 16)
        ..quadraticBezierTo(8.4, 9.2, 12, 4.2)
        ..close(),
    );
    shape(
      Path()
        ..moveTo(11.4, 16)
        ..quadraticBezierTo(5.6, 14.6, 4.4, 8.6)
        ..quadraticBezierTo(8.6, 9.6, 11.4, 16)
        ..close(),
    );
    shape(
      Path()
        ..moveTo(12.6, 16)
        ..quadraticBezierTo(18.4, 14.6, 19.6, 8.6)
        ..quadraticBezierTo(15.4, 9.6, 12.6, 16)
        ..close(),
    );
    stroke(
      Path()
        ..moveTo(3.4, 15.6)
        ..quadraticBezierTo(12, 22.6, 20.6, 15.6),
    );
  }

  // ------------------------------------------------------------- the tabs

  void _profile() {
    shape(circle(12, 8.2, 3.7));
    shape(
      Path()
        ..moveTo(4.6, 20.4)
        ..cubicTo(5.4, 15.8, 8.4, 13.9, 12, 13.9)
        ..cubicTo(15.6, 13.9, 18.6, 15.8, 19.4, 20.4)
        ..close(),
    );
  }

  void _notebook() {
    shape(rrect(5.5, 3.5, 18.5, 20.5, 2));
    line(8.6, 3.5, 8.6, 20.5);
    line(11.4, 8.4, 15.8, 8.4);
    line(11.4, 11.6, 15.8, 11.6);
  }

  void _calendar() {
    shape(rrect(3.5, 5.2, 20.5, 20.5, 2.2));
    line(3.5, 9.6, 20.5, 9.6);
    line(8, 3.2, 8, 6.8);
    line(16, 3.2, 16, 6.8);
    for (final y in const [13.2, 17.0]) {
      for (final x in const [8.0, 12.0, 16.0]) {
        dot(x, y, 0.95);
      }
    }
  }

  void _chart() {
    line(3.5, 20.5, 20.5, 20.5);
    shape(rrect(5.4, 12.4, 8.6, 20.5, 1));
    shape(rrect(10.4, 5.4, 13.6, 20.5, 1));
    shape(rrect(15.4, 9.4, 18.6, 20.5, 1));
  }

  void _plants() {
    shape(
      Path()
        ..moveTo(7, 14.6)
        ..lineTo(17, 14.6)
        ..lineTo(15.8, 20.5)
        ..lineTo(8.2, 20.5)
        ..close(),
    );
    line(12, 14.6, 12, 8.4);
    shape(leaf(const Offset(12, 11.4), const Offset(6.2, 7.4), width: 1.5));
    shape(leaf(const Offset(12, 9.4), const Offset(17.6, 4.4), width: 1.5));
  }

  void _recipes() {
    shape(rrect(4.5, 4, 19.5, 20.5, 2));
    // a ribbon marking the page
    stroke(
      Path()
        ..moveTo(14.6, 4)
        ..lineTo(14.6, 9.2)
        ..lineTo(16.1, 8)
        ..lineTo(17.6, 9.2)
        ..lineTo(17.6, 4),
    );
    line(7.6, 12, 16.4, 12);
    line(7.6, 15, 16.4, 15);
    line(7.6, 18, 12.6, 18);
  }

  void _library() {
    line(3.5, 20.5, 20.5, 20.5);
    shape(rrect(5, 7.2, 8.6, 20.5, 0.8));
    shape(rrect(9.8, 4.6, 13.4, 20.5, 0.8));
    shape(
      Path()
        ..moveTo(14.5, 20.5)
        ..lineTo(17.6, 20.5)
        ..lineTo(20.6, 9.9)
        ..lineTo(17.5, 9.1)
        ..close(),
    );
    line(5, 10.2, 8.6, 10.2);
    line(9.8, 7.8, 13.4, 7.8);
  }

  void _nutrition() {
    // a fork
    for (final x in const [6.4, 8.3, 10.2]) {
      line(x, 3.6, x, 8);
    }
    stroke(
      Path()
        ..moveTo(6.4, 8)
        ..quadraticBezierTo(6.4, 10.6, 8.3, 10.6)
        ..quadraticBezierTo(10.2, 10.6, 10.2, 8),
    );
    line(8.3, 10.6, 8.3, 20.5);
    // a knife
    shape(
      Path()
        ..moveTo(16, 12.4)
        ..lineTo(16, 3.6)
        ..quadraticBezierTo(19.2, 5.4, 18.7, 12.4)
        ..close(),
    );
    line(16.6, 12.4, 16.6, 20.5);
  }

  void _fitness() {
    line(7, 12, 17, 12);
    shape(rrect(4.2, 7.4, 7, 16.6, 1));
    shape(rrect(17, 7.4, 19.8, 16.6, 1));
    line(2.6, 10, 2.6, 14);
    line(21.4, 10, 21.4, 14);
  }

  void _history() {
    const r = 8.2;
    const start = math.pi * 1.1;
    stroke(
      Path()..addArc(
        Rect.fromCircle(center: const Offset(12, 12), radius: r),
        start + 0.3,
        2 * math.pi - 0.6,
      ),
    );
    // the arrow at the start of the arc, turning back
    final p = onRing(r, start + 0.3);
    line(p.dx, p.dy, p.dx - 2.6, p.dy + 0.4);
    line(p.dx, p.dy, p.dx + 0.4, p.dy + 2.6);
    line(12, 12, 12, 7.6);
    line(12, 12, 15, 14);
  }

  void _weather() {
    // the sun peeping out behind the cloud
    final sun = const Offset(9, 8.6);
    stroke(
      Path()..addArc(
        Rect.fromCircle(center: sun, radius: 3.1),
        math.pi * 0.62,
        math.pi * 1.38,
      ),
    );
    for (final deg in const [180.0, 225.0, 270.0, 315.0]) {
      final a = deg * math.pi / 180;
      final p1 = sun + Offset(math.cos(a), math.sin(a)) * 4.6;
      final p2 = sun + Offset(math.cos(a), math.sin(a)) * 6.0;
      line(p1.dx, p1.dy, p2.dx, p2.dy);
    }
    shape(
      Path()
        ..moveTo(8, 19.8)
        ..cubicTo(4.6, 19.8, 4.4, 15, 7.8, 14.9)
        ..cubicTo(8.5, 11.4, 13.4, 10.6, 15.1, 13.7)
        ..cubicTo(18.9, 12.9, 21.4, 15.9, 20, 18.3)
        ..cubicTo(19.5, 19.3, 18.8, 19.8, 17.8, 19.8)
        ..close(),
    );
  }

  void _notes() {
    stroke(
      Path()
        ..moveTo(12, 5.5)
        ..lineTo(6.6, 5.5)
        ..quadraticBezierTo(4.5, 5.5, 4.5, 7.6)
        ..lineTo(4.5, 17.4)
        ..quadraticBezierTo(4.5, 19.5, 6.6, 19.5)
        ..lineTo(16.4, 19.5)
        ..quadraticBezierTo(18.5, 19.5, 18.5, 17.4)
        ..lineTo(18.5, 12),
    );
    shape(
      Path()
        ..moveTo(10.2, 14.8)
        ..lineTo(11, 11.8)
        ..lineTo(18.2, 4.6)
        ..lineTo(20.4, 6.8)
        ..lineTo(13.2, 14)
        ..close(),
    );
    line(16.8, 6, 19, 8.2);
  }
}
