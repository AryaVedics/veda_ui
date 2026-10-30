// Cartoon animal heads that can peek out from behind the trees of the day dial.
// Each is drawn flat, in soft muted colours, inside a square of side
// `2 * radius` centred on [centre], so the dial can scale and place them.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart'
    show ValueListenable, visibleForTesting;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;

enum ForestAnimal {
  tiger,
  elephant,
  panda,
  lion,
  bear,
  monkey,
  peacock,
  hippo,
  owl,
  fox,
  redPanda,
  polarBear,
  llama,
  crane,
  koala,
}

/// The friend's name, for the share caption. Mei is the panda with her bamboo.
String friendNameOf(ForestAnimal a, {bool special = false}) => switch (a) {
  ForestAnimal.tiger => 'Tara',
  ForestAnimal.elephant => 'Nuru',
  ForestAnimal.panda => special ? 'Mei' : 'Bao',
  ForestAnimal.lion => 'Leo',
  ForestAnimal.bear => 'Bela',
  ForestAnimal.monkey => 'Milo',
  ForestAnimal.peacock => 'Nazm',
  ForestAnimal.hippo => 'Hadi',
  ForestAnimal.owl => 'Luna',
  ForestAnimal.fox => 'Renard',
  ForestAnimal.redPanda => 'Pema',
  ForestAnimal.polarBear => 'Nanuq',
  ForestAnimal.llama => 'Illari',
  ForestAnimal.crane => 'Sora',
  ForestAnimal.koala => 'Jarrah',
};

const _ink = Color(0xFF2A211C);

void paintAnimalHead(
  Canvas canvas,
  ForestAnimal animal,
  Offset centre,
  double radius, {
  bool special = false,
}) {
  canvas.save();
  canvas.translate(centre.dx, centre.dy);
  canvas.scale(radius);
  switch (animal) {
    case ForestAnimal.tiger:
      _tiger(canvas);
    case ForestAnimal.elephant:
      _elephant(canvas);
    case ForestAnimal.panda:
      special ? _pandaWithBamboo(canvas) : _panda(canvas);
    case ForestAnimal.lion:
      _lion(canvas);
    case ForestAnimal.bear:
      _bear(canvas);
    case ForestAnimal.monkey:
      _monkey(canvas);
    case ForestAnimal.peacock:
      _peacock(canvas);
    case ForestAnimal.hippo:
      _hippo(canvas);
    case ForestAnimal.owl:
      _owl(canvas);
    case ForestAnimal.fox:
      _fox(canvas);
    case ForestAnimal.redPanda:
      _redPanda(canvas);
    case ForestAnimal.polarBear:
      _polarBear(canvas);
    case ForestAnimal.llama:
      _llama(canvas);
    case ForestAnimal.crane:
      _crane(canvas);
    case ForestAnimal.koala:
      _koala(canvas);
  }
  canvas.restore();
}

Paint _fill(Color c) => Paint()..color = c;

void _disc(Canvas canvas, Offset at, double r, Color c) =>
    canvas.drawCircle(at, r, _fill(c));

void _oval(
  Canvas canvas,
  Offset at,
  double w,
  double h,
  Color c, {
  double tilt = 0,
}) {
  canvas.save();
  canvas.translate(at.dx, at.dy);
  canvas.rotate(tilt);
  canvas.drawOval(
    Rect.fromCenter(center: Offset.zero, width: w, height: h),
    _fill(c),
  );
  canvas.restore();
}

/// Round dark eyes with a small highlight, [gap] apart at height [y].
void _eyes(
  Canvas canvas, {
  double gap = 0.36,
  double y = -0.08,
  double r = 0.085,
}) {
  for (final s in [-1.0, 1.0]) {
    final x = s * gap / 2;
    _disc(canvas, Offset(x, y), r, _ink);
    _disc(canvas, Offset(x - r * 0.3, y - r * 0.35), r * 0.35, Colors.white);
  }
}

void _cheeks(Canvas canvas, {double x = 0.5, double y = 0.2}) {
  for (final s in [-1.0, 1.0]) {
    _oval(
      canvas,
      Offset(s * x, y),
      0.2,
      0.13,
      const Color(0xFFFF9C8F).withValues(alpha: 0.45),
    );
  }
}

void _smile(Canvas canvas, double y, {double w = 0.16}) {
  final p = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.035
    ..strokeCap = StrokeCap.round
    ..color = _ink;
  canvas.drawPath(
    Path()
      ..moveTo(-w, y)
      ..quadraticBezierTo(-w / 2, y + 0.09, 0, y)
      ..quadraticBezierTo(w / 2, y + 0.09, w, y),
    p,
  );
}

void _nose(Canvas canvas, Offset at, Color c, {double w = 0.17}) {
  canvas.drawPath(
    Path()
      ..moveTo(at.dx - w / 2, at.dy - w * 0.35)
      ..lineTo(at.dx + w / 2, at.dy - w * 0.35)
      ..quadraticBezierTo(
        at.dx + w * 0.45,
        at.dy + w * 0.45,
        at.dx,
        at.dy + w * 0.5,
      )
      ..quadraticBezierTo(
        at.dx - w * 0.45,
        at.dy + w * 0.45,
        at.dx - w / 2,
        at.dy - w * 0.35,
      )
      ..close(),
    _fill(c),
  );
}

void _tiger(Canvas canvas) {
  const orange = Color(0xFFF0A24A);
  const cream = Color(0xFFFFF1DA);
  for (final s in [-1.0, 1.0]) {
    _disc(canvas, Offset(s * 0.62, -0.62), 0.26, orange);
    _disc(canvas, Offset(s * 0.62, -0.6), 0.14, const Color(0xFFFFD2B0));
  }
  _oval(canvas, Offset.zero, 1.7, 1.5, orange);
  // forehead and cheek stripes
  final stripe = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 0.075
    ..color = _ink;
  canvas.drawLine(const Offset(0, -0.72), const Offset(0, -0.45), stripe);
  for (final s in [-1.0, 1.0]) {
    canvas.drawLine(Offset(s * 0.2, -0.7), Offset(s * 0.16, -0.5), stripe);
    canvas.drawLine(Offset(s * 0.8, -0.1), Offset(s * 0.58, -0.04), stripe);
    canvas.drawLine(Offset(s * 0.8, 0.12), Offset(s * 0.58, 0.14), stripe);
    canvas.drawLine(Offset(s * 0.74, 0.34), Offset(s * 0.56, 0.3), stripe);
  }
  _oval(canvas, const Offset(0, 0.3), 0.95, 0.62, cream);
  _eyes(canvas, gap: 0.62, y: -0.06);
  _nose(canvas, const Offset(0, 0.2), const Color(0xFFE56F6F));
  _smile(canvas, 0.38);
  _cheeks(canvas, x: 0.62, y: 0.18);
}

void _elephant(Canvas canvas) {
  const grey = Color(0xFF9DAAB8);
  const inner = Color(0xFFF2B7B7);
  for (final s in [-1.0, 1.0]) {
    _disc(canvas, Offset(s * 0.82, -0.05), 0.5, grey);
    _disc(canvas, Offset(s * 0.82, -0.02), 0.34, inner);
  }
  _oval(canvas, Offset.zero, 1.4, 1.5, grey);
  // trunk
  canvas.drawPath(
    Path()
      ..moveTo(-0.2, 0.05)
      ..lineTo(0.2, 0.05)
      ..quadraticBezierTo(0.26, 0.7, 0.1, 0.95)
      ..quadraticBezierTo(0.0, 1.02, -0.1, 0.92)
      ..quadraticBezierTo(-0.04, 0.7, -0.2, 0.05)
      ..close(),
    _fill(const Color(0xFF8E9BAA)),
  );
  for (final y in [0.35, 0.55, 0.75]) {
    canvas.drawLine(
      Offset(-0.15, y),
      Offset(0.17, y),
      Paint()
        ..strokeWidth = 0.025
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF7B8896),
    );
  }
  _eyes(canvas, gap: 0.62, y: -0.14);
  _cheeks(canvas, x: 0.5, y: 0.1);
}

/// A big, sparkly eye: dark, with two highlights.
void _bigEye(Canvas canvas, Offset at, double r) {
  _disc(canvas, at, r, _ink);
  _disc(canvas, at + Offset(-r * 0.3, -r * 0.35), r * 0.42, Colors.white);
  _disc(canvas, at + Offset(r * 0.35, r * 0.3), r * 0.2, Colors.white);
}

const _blush = Color(0x66FF8F8F);

void _panda(Canvas canvas) {
  const white = Color(0xFFFBF7EF);
  const black = Color(0xFF2F2F33);
  for (final s in [-1.0, 1.0]) {
    _disc(canvas, Offset(s * 0.72, -0.62), 0.3, black);
    _disc(canvas, Offset(s * 0.72, -0.62), 0.13, const Color(0xFF55555C));
  }
  _oval(canvas, const Offset(0, 0.05), 1.9, 1.62, white);
  for (final s in [-1.0, 1.0]) {
    _oval(canvas, Offset(s * 0.42, 0.02), 0.52, 0.6, black, tilt: s * 0.45);
    _bigEye(canvas, Offset(s * 0.42, 0), 0.15);
    _oval(canvas, Offset(s * 0.72, 0.3), 0.24, 0.15, _blush);
  }
  _nose(canvas, const Offset(0, 0.26), _ink, w: 0.15);
  _smile(canvas, 0.4, w: 0.11);
}

/// The panda's rarer look: chubbier, holding a bamboo shoot.
void _pandaWithBamboo(Canvas canvas) {
  const white = Color(0xFFFBF7EF);
  const black = Color(0xFF2F2F33);
  for (final s in [-1.0, 1.0]) {
    _disc(canvas, Offset(s * 0.78, -0.55), 0.27, black);
  }
  _oval(canvas, Offset.zero, 2.0, 1.5, white);
  for (final s in [-1.0, 1.0]) {
    _oval(canvas, Offset(s * 0.5, 0.04), 0.4, 0.5, black, tilt: s * 0.6);
    _bigEye(canvas, Offset(s * 0.5, 0.03), 0.12);
    _oval(canvas, Offset(s * 0.82, 0.32), 0.22, 0.14, _blush);
  }
  _nose(canvas, const Offset(0, 0.2), _ink, w: 0.13);
  // the happy open smile with a tiny tongue
  canvas.drawPath(
    Path()
      ..moveTo(-0.12, 0.36)
      ..quadraticBezierTo(0, 0.5, 0.12, 0.36)
      ..close(),
    _fill(const Color(0xFFE56F7A)),
  );
  _smile(canvas, 0.34, w: 0.12);
  final stalk = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(
    const Offset(-0.15, 0.8),
    const Offset(0.55, 0.45),
    stalk
      ..strokeWidth = 0.1
      ..color = const Color(0xFF7FB06A),
  );
  canvas.drawLine(
    const Offset(-0.1, 0.76),
    const Offset(0.5, 0.42),
    stalk
      ..strokeWidth = 0.025
      ..color = const Color(0xFF5E9050),
  );
  canvas.drawPath(
    Path()
      ..moveTo(0.55, 0.45)
      ..quadraticBezierTo(0.85, 0.2, 0.95, 0.1)
      ..quadraticBezierTo(0.75, 0.35, 0.55, 0.45),
    _fill(const Color(0xFF6DAA5A)),
  );
  for (final x in [-0.25, 0.05]) {
    _oval(canvas, Offset(x, 0.86), 0.3, 0.22, black);
  }
  // a small coral flower tucked by her ear
  const flower = Offset(-0.7, -0.62);
  for (var i = 0; i < 5; i++) {
    final a = i * 2 * math.pi / 5;
    _disc(
      canvas,
      flower + Offset(math.cos(a), math.sin(a)) * 0.1,
      0.1,
      const Color(0xFFE2735B),
    );
  }
  _disc(canvas, flower, 0.06, const Color(0xFFE5A53A));
}

void _peacock(Canvas canvas) {
  const teal = Color(0xFF1F7A6B);
  const rim = Color(0xFF3FB59A);
  const blue = Color(0xFF2F80C8);
  // the fan: nine feathers with a gold, blue and dark eye at each tip
  for (var i = 0; i < 9; i++) {
    final a = (-170 + i * 20) * math.pi / 180;
    final dir = Offset(math.cos(a), math.sin(a));
    final centre = Offset(0, 0.15) + dir * 0.72;
    canvas.save();
    canvas.translate(centre.dx, centre.dy);
    canvas.rotate(a);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 0.86, height: 0.36),
      _fill(rim),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 0.8, height: 0.3),
      _fill(teal),
    );
    canvas.restore();
    final eye = Offset(0, 0.15) + dir * 1.02;
    _disc(canvas, eye, 0.1, const Color(0xFFE8B84A));
    _disc(canvas, eye, 0.068, const Color(0xFF2A6FB0));
    _disc(canvas, eye, 0.032, const Color(0xFF14283A));
  }
  _oval(canvas, const Offset(0, 0.8), 0.72, 0.9, const Color(0xFF2873B3));
  // crest: three fine stems, each with a small round tip
  final stem = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.03
    ..strokeCap = StrokeCap.round
    ..color = const Color(0xFF14506A);
  for (final deg in [-112.0, -90.0, -68.0]) {
    final a = deg * math.pi / 180;
    final tip = Offset(math.cos(a), math.sin(a)) * 0.6 + const Offset(0, -0.2);
    canvas.drawLine(const Offset(0, -0.2), tip, stem);
    _disc(canvas, tip, 0.075, const Color(0xFF9BE8F7));
  }
  _oval(canvas, const Offset(0, 0.18), 1.0, 1.04, blue);
  for (final sd in [-1.0, 1.0]) {
    _oval(
      canvas,
      Offset(sd * 0.26, 0.06),
      0.3,
      0.17,
      const Color(0xFFF8F4EA),
      tilt: sd * -0.25,
    );
    _bigEye(canvas, Offset(sd * 0.26, 0.07), 0.08);
    _oval(canvas, Offset(sd * 0.4, 0.34), 0.18, 0.11, _blush);
  }
  canvas.drawPath(
    Path()
      ..moveTo(-0.075, 0.2)
      ..lineTo(0.075, 0.2)
      ..lineTo(0, 0.37)
      ..close(),
    _fill(const Color(0xFFE8B84A)),
  );
}

void _hippo(Canvas canvas) {
  const grey = Color(0xFF9AA3C4);
  const snout = Color(0xFFBBC2DC);
  const pink = Color(0xFFF2B9C8);
  // small round ears on top
  for (final sd in [-1.0, 1.0]) {
    _disc(canvas, Offset(sd * 0.55, -0.62), 0.2, grey);
    _disc(canvas, Offset(sd * 0.55, -0.6), 0.11, pink);
  }
  _oval(canvas, const Offset(0, -0.05), 1.7, 1.5, grey);
  // eyes sit on little bumps, as a hippo's do
  for (final sd in [-1.0, 1.0]) {
    _disc(canvas, Offset(sd * 0.36, -0.42), 0.22, grey);
    _bigEye(canvas, Offset(sd * 0.36, -0.36), 0.115);
  }
  // the great soft snout
  _oval(canvas, const Offset(0, 0.36), 1.45, 0.92, snout);
  for (final sd in [-1.0, 1.0]) {
    _oval(canvas, Offset(sd * 0.27, 0.16), 0.16, 0.1, const Color(0xFF4A4660));
    _oval(canvas, Offset(sd * 0.66, 0.4), 0.2, 0.13, _blush);
  }
  _smile(canvas, 0.58, w: 0.2);
}

void _owl(Canvas canvas) {
  const plum = Color(0xFF6C4F73);
  const dark = Color(0xFF4E3A56);
  const face = Color(0xFFEBDDBF);
  // ear tufts, full and softly rounded
  for (final sd in [-1.0, 1.0]) {
    final tuft = Path()
      ..moveTo(sd * 0.3, -0.7)
      ..lineTo(sd * 0.85, -1.15)
      ..lineTo(sd * 0.95, -0.4)
      ..close();
    canvas.drawPath(tuft, _fill(plum));
    canvas.drawPath(
      tuft,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.12
        ..strokeJoin = StrokeJoin.round
        ..color = plum,
    );
  }
  _oval(canvas, Offset.zero, 2.1, 2.0, plum);
  // the pale face disc round the eyes
  _disc(canvas, const Offset(-0.38, -0.02), 0.5, face);
  _disc(canvas, const Offset(0.38, -0.02), 0.5, face);
  for (final sd in [-1.0, 1.0]) {
    _disc(canvas, Offset(sd * 0.38, -0.02), 0.36, Colors.white);
    _disc(canvas, Offset(sd * 0.38, -0.02), 0.25, const Color(0xFFE5A53A));
    _disc(canvas, Offset(sd * 0.38, -0.02), 0.15, _ink);
    _disc(canvas, Offset(sd * 0.38 - 0.06, -0.09), 0.05, Colors.white);
    _oval(canvas, Offset(sd * 0.7, 0.34), 0.2, 0.12, _blush);
  }
  canvas.drawPath(
    Path()
      ..moveTo(-0.1, 0.12)
      ..lineTo(0.1, 0.12)
      ..lineTo(0, 0.34)
      ..close(),
    _fill(const Color(0xFFE59A3A)),
  );
  // a few feather scallops on the chest
  final feather = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.03
    ..color = dark.withValues(alpha: 0.7);
  for (final x in [-0.3, 0.0, 0.3]) {
    canvas.drawArc(
      Rect.fromCenter(center: Offset(x, 0.74), width: 0.26, height: 0.2),
      0.2,
      2.7,
      false,
      feather,
    );
  }
}

/// A closed, smoothly rounded shape through [p] (Catmull-Rom curves).
Path _smoothShape(List<Offset> p) {
  final n = p.length;
  Offset at(int i) => p[((i % n) + n) % n];
  final path = Path()..moveTo(at(0).dx, at(0).dy);
  for (var i = 0; i < n; i++) {
    final p0 = at(i - 1), p1 = at(i), p2 = at(i + 1), p3 = at(i + 2);
    final c1 = p1 + (p2 - p0) / 6;
    final c2 = p2 - (p3 - p1) / 6;
    path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
  }
  return path..close();
}

void _fox(Canvas canvas) {
  const orange = Color(0xFFEE8A3C);
  const cream = Color(0xFFFFF2DE);
  const sock = Color(0xFF4B3A33);
  // tall, broad ears with a dark inside
  for (final sd in [-1.0, 1.0]) {
    canvas.drawPath(
      _smoothShape([
        Offset(sd * 0.25, -0.7),
        Offset(sd * 0.95, -1.2),
        Offset(sd * 1.1, -0.25),
        Offset(sd * 0.6, -0.2),
      ]),
      _fill(orange),
    );
    canvas.drawPath(
      _smoothShape([
        Offset(sd * 0.5, -0.6),
        Offset(sd * 0.88, -0.95),
        Offset(sd * 0.92, -0.4),
        Offset(sd * 0.65, -0.35),
      ]),
      _fill(sock),
    );
  }
  // a fox's own head: wide across the cheeks, narrowing to a pointed chin
  canvas.drawPath(
    _smoothShape(const [
      Offset(0, -0.85),
      Offset(0.8, -0.5),
      Offset(1.15, 0.3),
      Offset(0.5, 0.85),
      Offset(0, 1.0),
      Offset(-0.5, 0.85),
      Offset(-1.15, 0.3),
      Offset(-0.8, -0.5),
    ]),
    _fill(orange),
  );
  // the cream cheeks and muzzle
  canvas.drawPath(
    _smoothShape(const [
      Offset(0, 0.1),
      Offset(0.9, 0.35),
      Offset(0.45, 0.9),
      Offset(0, 1.0),
      Offset(-0.45, 0.9),
      Offset(-0.9, 0.35),
    ]),
    _fill(cream),
  );
  _eyes(canvas, gap: 0.84, y: -0.1);
  _nose(canvas, const Offset(0, 0.45), sock, w: 0.17);
  _smile(canvas, 0.62, w: 0.14);
  for (final sd in [-1.0, 1.0]) {
    _oval(canvas, Offset(sd * 0.78, 0.3), 0.2, 0.12, _blush);
  }
}

void _redPanda(Canvas canvas) {
  const rust = Color(0xFFC2532F);
  const white = Color(0xFFFFF4EA);
  const dark = Color(0xFF3B2A28);
  // round ears edged in white
  for (final sd in [-1.0, 1.0]) {
    _disc(canvas, Offset(sd * 0.66, -0.62), 0.3, white);
    _disc(canvas, Offset(sd * 0.66, -0.6), 0.22, rust);
    _disc(canvas, Offset(sd * 0.66, -0.58), 0.1, dark);
  }
  _oval(canvas, Offset.zero, 1.78, 1.56, rust);
  // white brows and cheeks
  for (final sd in [-1.0, 1.0]) {
    _oval(canvas, Offset(sd * 0.4, -0.34), 0.34, 0.16, white, tilt: sd * 0.3);
    _oval(canvas, Offset(sd * 0.62, 0.2), 0.56, 0.5, white);
  }
  _oval(canvas, const Offset(0, 0.32), 0.62, 0.46, white);
  // the tear marks that run down from each eye
  final tear = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.06
    ..strokeCap = StrokeCap.round
    ..color = const Color(0xFF7A3A28);
  for (final sd in [-1.0, 1.0]) {
    canvas.drawLine(Offset(sd * 0.34, 0.0), Offset(sd * 0.46, 0.34), tear);
  }
  _eyes(canvas, gap: 0.58, y: -0.1);
  _nose(canvas, const Offset(0, 0.22), dark, w: 0.2);
  _smile(canvas, 0.42, w: 0.12);
}

void _polarBear(Canvas canvas) {
  const white = Color(0xFFF6F8FC);
  const shade = Color(0xFFDCE6F2);
  for (final sd in [-1.0, 1.0]) {
    _disc(canvas, Offset(sd * 0.62, -0.62), 0.27, white);
    _disc(canvas, Offset(sd * 0.62, -0.6), 0.14, const Color(0xFFD7C9D0));
  }
  _oval(canvas, Offset.zero, 1.74, 1.56, white);
  // a hint of cold blue in the cheeks and brow
  for (final sd in [-1.0, 1.0]) {
    _oval(canvas, Offset(sd * 0.7, 0.22), 0.5, 0.4, shade);
  }
  _oval(canvas, const Offset(0, 0.3), 0.72, 0.54, const Color(0xFFFFFFFF));
  _eyes(canvas, gap: 0.6, y: -0.1);
  _nose(canvas, const Offset(0, 0.2), _ink, w: 0.22);
  _smile(canvas, 0.38, w: 0.14);
  for (final sd in [-1.0, 1.0]) {
    _oval(canvas, Offset(sd * 0.66, 0.3), 0.2, 0.12, _blush);
  }
}

void _llama(Canvas canvas) {
  const wool = Color(0xFFEAD9BE);
  const dark = Color(0xFFC8AE86);
  // tall banana ears, each with a bright tassel as Andean llamas wear
  for (final sd in [-1.0, 1.0]) {
    canvas.save();
    canvas.translate(sd * 0.5, -0.78);
    canvas.rotate(sd * 0.22);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 0.34, height: 0.78),
      _fill(wool),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 0.18, height: 0.56),
      _fill(const Color(0xFFF0C4C0)),
    );
    canvas.restore();
    final tassel = Offset(sd * 0.74, -0.38);
    _disc(canvas, tassel, 0.075, const Color(0xFFE5586B));
    _disc(
      canvas,
      tassel + Offset(sd * 0.0, 0.13),
      0.065,
      const Color(0xFFF2B63A),
    );
    _disc(
      canvas,
      tassel + Offset(sd * 0.0, 0.25),
      0.055,
      const Color(0xFF3FA79B),
    );
  }
  // the woolly topknot
  for (final dx in [-0.16, 0.0, 0.16]) {
    _disc(canvas, Offset(dx, -0.72), 0.17, wool);
  }
  _oval(canvas, const Offset(0, -0.02), 1.5, 1.55, wool);
  _oval(canvas, const Offset(0, 0.34), 0.84, 0.66, const Color(0xFFF7EEDC));
  _eyes(canvas, gap: 0.62, y: -0.14);
  for (final sd in [-1.0, 1.0]) {
    _oval(canvas, Offset(sd * 0.1, 0.22), 0.1, 0.08, dark);
    _oval(canvas, Offset(sd * 0.56, 0.2), 0.2, 0.12, _blush);
  }
  _smile(canvas, 0.46, w: 0.15);
}

void _crane(Canvas canvas) {
  // drawn long, so it is moved and shrunk to sit in the same square as the rest
  canvas.save();
  canvas.translate(-0.32, -0.02);
  canvas.scale(0.82);
  _craneDrawing(canvas);
  canvas.restore();
}

void _craneDrawing(Canvas canvas) {
  const white = Color(0xFFFBFBF8);
  const black = Color(0xFF2E2D33);
  const beak = Color(0xFFE6CF8E);
  // the long white neck, rising in a gentle curve from below
  final neck = Path()
    ..moveTo(0.22, 1.2)
    ..cubicTo(0.46, 0.6, -0.34, 0.5, -0.12, -0.1);
  canvas.drawPath(
    neck,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.46
      ..strokeCap = StrokeCap.round
      ..color = white,
  );
  // the dark band down the side of the neck
  canvas.drawPath(
    neck,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.17
      ..strokeCap = StrokeCap.round
      ..color = black.withValues(alpha: 0.9),
  );
  // the head, in profile, looking to the right
  _disc(canvas, const Offset(-0.12, -0.34), 0.44, white);
  // black throat and cheek
  _oval(canvas, const Offset(0.0, -0.1), 0.62, 0.34, black, tilt: -0.15);
  // the red crown
  _oval(canvas, const Offset(-0.18, -0.7), 0.4, 0.2, const Color(0xFFD83A3A));
  // a long, straight, pale beak
  canvas.drawPath(
    Path()
      ..moveTo(0.22, -0.46)
      ..lineTo(1.2, -0.3)
      ..lineTo(0.24, -0.16)
      ..close(),
    _fill(beak),
  );
  canvas.drawLine(
    const Offset(0.26, -0.31),
    const Offset(1.08, -0.3),
    Paint()
      ..strokeWidth = 0.025
      ..color = const Color(0xFFB59F62),
  );
  // the eye, bright against the white
  _disc(canvas, const Offset(0.02, -0.4), 0.075, _ink);
  _disc(canvas, const Offset(0.0, -0.43), 0.028, Colors.white);
}

void _koala(Canvas canvas) {
  const grey = Color(0xFF9EA3AA);
  const fluff = Color(0xFFEDEBE6);
  // the big round ears, a koala's best feature
  for (final sd in [-1.0, 1.0]) {
    _disc(canvas, Offset(sd * 0.82, -0.5), 0.42, grey);
    _disc(canvas, Offset(sd * 0.82, -0.48), 0.28, fluff);
  }
  _oval(canvas, const Offset(0, 0.02), 1.6, 1.5, grey);
  _eyes(canvas, gap: 0.6, y: -0.12, r: 0.075);
  // a large, dark, leathery nose
  _oval(canvas, const Offset(0, 0.2), 0.34, 0.5, const Color(0xFF3F3A3E));
  _oval(canvas, const Offset(-0.06, 0.08), 0.1, 0.08, const Color(0x55FFFFFF));
  _oval(canvas, const Offset(0, 0.74), 0.9, 0.36, fluff);
  _smile(canvas, 0.58, w: 0.14);
  for (final sd in [-1.0, 1.0]) {
    _oval(canvas, Offset(sd * 0.62, 0.3), 0.2, 0.12, _blush);
  }
  // a eucalyptus leaf, brought from home
  const base = Offset(0.78, 0.6);
  const tip = Offset(1.3, -0.05);
  final mid = Offset.lerp(base, tip, 0.5)!;
  const bend = Offset(0.2, 0.14);
  canvas.drawPath(
    Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(mid.dx + bend.dx, mid.dy + bend.dy, tip.dx, tip.dy)
      ..quadraticBezierTo(mid.dx - bend.dx, mid.dy - bend.dy, base.dx, base.dy),
    _fill(const Color(0xFF7DB07E)),
  );
  canvas.drawLine(
    base,
    tip,
    Paint()
      ..color = const Color(0xFFB4D6A8)
      ..strokeWidth = 0.025
      ..strokeCap = StrokeCap.round,
  );
}

void _lion(Canvas canvas) {
  const mane = Color(0xFFB7692E);
  const maneLight = Color(0xFFD08A45);
  const face = Color(0xFFF2C06B);
  const cream = Color(0xFFFFF0CF);
  for (var i = 0; i < 14; i++) {
    final a = i * 2 * math.pi / 14;
    _disc(
      canvas,
      Offset(math.cos(a), math.sin(a)) * 0.78,
      0.32,
      i.isEven ? mane : maneLight,
    );
  }
  _disc(canvas, Offset.zero, 0.84, mane);
  for (final s in [-1.0, 1.0]) {
    _disc(canvas, Offset(s * 0.5, -0.58), 0.2, face);
    _disc(canvas, Offset(s * 0.5, -0.57), 0.1, const Color(0xFFFFD2B0));
  }
  _oval(canvas, Offset.zero, 1.2, 1.15, face);
  _oval(canvas, const Offset(0, 0.26), 0.7, 0.5, cream);
  _eyes(canvas, gap: 0.5, y: -0.1);
  _nose(canvas, const Offset(0, 0.14), const Color(0xFF8A4B33));
  _smile(canvas, 0.3);
  _cheeks(canvas, x: 0.46, y: 0.16);
}

void _bear(Canvas canvas) {
  const brown = Color(0xFF9A6A47);
  const tan = Color(0xFFE2C39A);
  for (final s in [-1.0, 1.0]) {
    _disc(canvas, Offset(s * 0.6, -0.62), 0.27, brown);
    _disc(canvas, Offset(s * 0.6, -0.6), 0.14, tan);
  }
  _oval(canvas, Offset.zero, 1.7, 1.55, brown);
  _oval(canvas, const Offset(0, 0.3), 0.68, 0.5, tan);
  _eyes(canvas, gap: 0.58, y: -0.1);
  _nose(canvas, const Offset(0, 0.2), _ink, w: 0.2);
  _smile(canvas, 0.36);
  _cheeks(canvas, x: 0.62, y: 0.2);
  // a little jasmine flower tucked by her ear (bela is a kind of jasmine)
  const flower = Offset(0.5, -0.5);
  for (var i = 0; i < 5; i++) {
    final a = i * 2 * math.pi / 5 - math.pi / 2;
    _disc(
      canvas,
      flower + Offset(math.cos(a), math.sin(a)) * 0.085,
      0.07,
      const Color(0xFFFFFBF0),
    );
  }
  _disc(canvas, flower, 0.04, const Color(0xFFF2C14E));
}

void _monkey(Canvas canvas) {
  const brown = Color(0xFF7D5236);
  const face = Color(0xFFF1CFA4);
  for (final s in [-1.0, 1.0]) {
    _disc(canvas, Offset(s * 0.86, -0.02), 0.3, brown);
    _disc(canvas, Offset(s * 0.86, -0.02), 0.18, face);
  }
  _oval(canvas, const Offset(0, -0.04), 1.6, 1.5, brown);
  // heart-shaped face mask
  _disc(canvas, const Offset(-0.26, -0.1), 0.34, face);
  _disc(canvas, const Offset(0.26, -0.1), 0.34, face);
  _oval(canvas, const Offset(0, 0.28), 0.9, 0.72, face);
  _eyes(canvas, gap: 0.5, y: -0.1);
  for (final s in [-1.0, 1.0]) {
    _disc(canvas, Offset(s * 0.05, 0.14), 0.03, const Color(0xFF9B6C4B));
  }
  _smile(canvas, 0.42, w: 0.22);
  _cheeks(canvas, x: 0.5, y: 0.26);
}

/// Every so often one animal peeks out from the dense foliage round the rim of
/// the dial, looks in at the clearing, and ducks back. Never while the phone
/// asks for reduced motion, while another page or sheet is on top, or while the
/// tab is hidden. [inner] gives the sky's radius for a canvas of a given size.
class ForestPeeker extends StatefulWidget {
  const ForestPeeker({
    super.key,
    required this.inner,
    this.eager = false,
    this.friend,
    this.onMeet,
    this.hold,
    this.expectancy,
  });

  final double Function(Size size) inner;

  /// How near the next friend is, 0 to 1, kept up to date while the forest
  /// runs: empty halfway between two visits, building from there as the next
  /// one nears, full while a friend is out, and falling back over the first
  /// half of the gap after they leave. Nature Mode's camera glows with it.
  final ValueNotifier<double>? expectancy;

  /// Nature Mode: called when a friend that is out is tapped. Without it the
  /// forest ignores touches.
  final void Function(ForestAnimal animal, bool special)? onMeet;

  /// While true, the visit waits with the friend fully out, and carries on
  /// when it turns false again.
  final ValueListenable<bool>? hold;

  /// Where the tappable heads were last drawn, for tests.
  @visibleForTesting
  static var heads = <Offset>[];

  /// Who is out right now ("Bao and Mei"), or null; Nature Mode shows its
  /// share button while there is someone.
  final ValueNotifier<String?>? friend;

  /// Where the dice come from; tests swap in a stand-in.
  @visibleForTesting
  static math.Random Function() random = math.Random.new;

  /// The forests that are alive right now. Opening Nature Mode from Today puts
  /// a second one on screen; it takes over a visit already in progress.
  static final _running = <_ForestPeekerState>{};

  /// Whether Bao and Mei may come out together. An app can hold the pair back
  /// (Routine does, for a person's first visits); by default it is allowed.
  static bool Function() pairAllowed = () => true;

  /// Told each time a visit starts, so an app can count them.
  static void Function() onVisit = () {};

  /// Zen mode: a friend peeks out sooner and more often.
  final bool eager;

  @override
  State<ForestPeeker> createState() => _ForestPeekerState();
}

/// One animal on its way up and down: which one, where on the rim, and how far
/// into the visit it waits before it starts (0 to 1 of the visit).
class _Peek {
  const _Peek(this.animal, this.special, this.angle, {this.delay = 0});

  final ForestAnimal animal;
  final bool special;
  final double angle;
  final double delay;
}

class _ForestPeekerState extends State<ForestPeeker>
    with TickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 5200),
  );
  final _rnd = ForestPeeker.random();
  Timer? _timer;
  var _lastWasPair = false;
  var _peeks = <_Peek>[];
  var _holding = false;
  late final _PeekPainter _painter = _PeekPainter(
    progress: _c,
    peeks: () => _peeks,
    visitSeconds: () => _visit.inMilliseconds / 1000,
    inner: widget.inner,
  );

  double get _rise => (1.3 / (_visit.inMilliseconds / 1000)).clamp(0.05, 0.3);

  /// How long this visit lasts. The rare ones stay longer, so there is time to
  /// enjoy them, and to take a screenshot.
  var _visit = const Duration(milliseconds: 5200);
  ForestAnimal? _last;
  double _angle = 0;

  /// Where on the rim an animal may appear, in radians (0 = 3 o'clock,
  /// clockwise): the two lower sides, clear of the sun above and the moon below.
  static const _ranges = [
    (-0.12 * math.pi, 0.36 * math.pi),
    (0.64 * math.pi, 1.12 * math.pi),
  ];

  /// How far apart, round the rim, Bao and Mei sit when they come together.
  static const _together = 0.44;

  // The anticipation: time as the ticker counts it, so it follows the same
  // clock as everything else on screen (and a test's).
  Ticker? _tick;
  var _elapsed = Duration.zero;
  var _gapStart = Duration.zero;
  var _gapEnd = Duration.zero;

  /// Whether this gap follows a visit (so it starts full and falls), or the
  /// forest has only just begun (so it starts empty).
  var _fromPeak = false;
  var _visiting = false;

  @override
  void initState() {
    super.initState();
    _schedule(widget.eager ? 4 + _rnd.nextInt(4) : 8 + _rnd.nextInt(8));
    _c.addListener(_waitIfHeld);
    widget.hold?.addListener(_holdChanged);
    final n = widget.expectancy;
    if (n != null) {
      _tick = createTicker((e) {
        _elapsed = e;
        n.value = _expectancy();
      })..start();
    }
    ForestPeeker._running.add(this);
    _adoptRunningVisit();
  }

  /// A friend who is already out in another forest (Today, when Nature Mode
  /// opens) stays out here, in the same place and at the same point of the
  /// visit, instead of the forest starting again.
  void _adoptRunningVisit() {
    for (final other in ForestPeeker._running) {
      if (identical(other, this) || !other._visiting || other._peeks.isEmpty) {
        continue;
      }
      _peeks = [...other._peeks];
      _visit = other._visit;
      _angle = other._angle;
      _last = other._last;
      _lastWasPair = other._lastWasPair;
      _visiting = true;
      _timer?.cancel();
      _c.duration = _visit;
      _c.forward(from: other._c.value).whenComplete(_end);
      // told once the first frame is built: the screen is still being built
      // now, and its listeners may not be changed in the middle of that
      final name = _peeks.length > 1
          ? 'Bao and Mei'
          : friendNameOf(_peeks.first.animal, special: _peeks.first.special);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _visiting) widget.friend?.value = name;
      });
      return;
    }
  }

  static double _smooth(double x) {
    final c = x.clamp(0.0, 1.0);
    return c * c * (3 - 2 * c);
  }

  /// 1 while a friend is out. In the gap between visits it is shaped like a
  /// V: falling from the last visit for the first half (if there was one),
  /// empty at the halfway point, and rising to the next visit for the rest.
  double _expectancy() {
    if (_visiting) return 1;
    final total = (_gapEnd - _gapStart).inMicroseconds;
    if (total <= 0) return 0;
    final x = (_elapsed - _gapStart).inMicroseconds / total;
    if (x < 0.5) return _fromPeak ? 1 - _smooth(x / 0.5) : 0;
    return _smooth((x - 0.5) / 0.5);
  }

  /// Stops the visit once every head is fully out, while someone is reading.
  void _waitIfHeld() {
    if (!_holding || !_c.isAnimating) return;
    var full = 0.0;
    for (final p in _peeks) {
      full = math.max(full, p.delay + (1 - p.delay) * _rise);
    }
    if (_c.value >= full) _c.stop();
  }

  void _holdChanged() {
    _holding = widget.hold?.value ?? false;
    if (_holding) {
      _waitIfHeld();
    } else if (!_c.isAnimating && _c.value > 0 && _c.value < 1) {
      _c.forward().whenComplete(_end);
    }
  }

  void _end() {
    widget.friend?.value = null;
    _visiting = false;
    if (mounted) {
      _schedule(
        widget.eager ? 12 + _rnd.nextInt(11) : 20 + _rnd.nextInt(26),
        afterVisit: true,
      );
    }
  }

  void _schedule(int seconds, {bool afterVisit = false}) {
    _timer?.cancel();
    _gapStart = _elapsed;
    _gapEnd = _elapsed + Duration(seconds: seconds);
    _fromPeak = afterVisit;
    _timer = Timer(Duration(seconds: seconds), _fire);
  }

  /// A spot on the rim at least [clear] from the last one, with room for
  /// [span] more to the right of it.
  double _spot(double span) {
    final lastAngle = _angle;
    double a;
    var tries = 0;
    do {
      final (from, to) = _ranges[_rnd.nextInt(_ranges.length)];
      a = from + (to - from - span) * _rnd.nextDouble();
      // a few tries at most: never wait for a spot that may not come
    } while ((a - lastAngle).abs() < 0.5 && ++tries < 12);
    return a;
  }

  void _fire() {
    if (!mounted) return;
    final quiet =
        MediaQuery.disableAnimationsOf(context) ||
        !TickerMode.valuesOf(context).enabled ||
        !(ModalRoute.of(context)?.isCurrent ?? true);
    if (quiet) {
      _schedule(10);
      return;
    }
    ForestPeeker.onVisit();
    // very rarely (about 1 visit in 80 on Today, 1 in 100 in Nature Mode, and
    // never twice running, and only once the app allows it) Bao and Mei peek
    // out side by side, Mei a moment later
    if (!_lastWasPair &&
        ForestPeeker.pairAllowed() &&
        _rnd.nextInt(widget.eager ? 100 : 80) == 0) {
      _lastWasPair = true;
      _angle = _spot(_together);
      final meiLeft = _rnd.nextBool();
      _peeks = [
        _Peek(ForestAnimal.panda, meiLeft, _angle),
        _Peek(ForestAnimal.panda, !meiLeft, _angle + _together, delay: 0.1),
      ];
      _last = ForestAnimal.panda;
      _visit = const Duration(seconds: 25);
      widget.friend?.value = 'Bao and Mei';
    } else {
      _lastWasPair = false;
      final pool = [
        for (final a in ForestAnimal.values)
          if (a != _last) a,
      ];
      final animal = pool[_rnd.nextInt(pool.length)];
      _last = animal;
      _angle = _spot(0);
      // the shy panda, Mei, only now and then comes out with her bamboo
      // Mei, shy, one panda visit in about eight
      final mei = animal == ForestAnimal.panda && _rnd.nextInt(8) == 0;
      _peeks = [_Peek(animal, mei, _angle)];
      widget.friend?.value = friendNameOf(animal, special: mei);
      _visit = Duration(milliseconds: mei ? 15000 : 5200);
    }
    _visiting = true;
    _c.duration = _visit;
    _c.forward(from: 0).whenComplete(_end);
  }

  @override
  void dispose() {
    ForestPeeker._running.remove(this);
    _timer?.cancel();
    _tick?.dispose();
    widget.hold?.removeListener(_holdChanged);
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final meet = widget.onMeet;
    if (meet == null) {
      return Positioned.fill(
        child: IgnorePointer(child: CustomPaint(painter: _painter)),
      );
    }
    // only a head that is out answers a touch; every other tap goes through
    return Positioned.fill(
      child: GestureDetector(
        onTapUp: (d) {
          final who = _painter.headAt(d.localPosition);
          if (who != null) meet(who.animal, who.special);
        },
        child: CustomPaint(painter: _painter),
      ),
    );
  }
}

class _PeekPainter extends CustomPainter {
  _PeekPainter({
    required this.progress,
    required this.peeks,
    required this.visitSeconds,
    required this.inner,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final List<_Peek> Function() peeks;
  final double Function() visitSeconds;
  final double Function(Size) inner;

  /// The heads that are out and not yet leaving, and how big they are.
  final _out = <(_Peek, Offset)>[];
  var _outRadius = 0.0;

  /// Who is at [at], if a friend that is out is there.
  _Peek? headAt(Offset at) {
    _Peek? best;
    var bestD = _outRadius * 1.5;
    for (final (peek, centre) in _out) {
      final d = (centre - at).distance;
      if (d < bestD) {
        bestD = d;
        best = peek;
      }
    }
    return best;
  }

  @override
  bool? hitTest(Offset position) => headAt(position) != null;

  @override
  void paint(Canvas canvas, Size size) {
    _out.clear();
    ForestPeeker.heads = [];
    final visit = progress.value;
    if (visit <= 0 || visit >= 1) return;
    final c = size.center(Offset.zero);
    final sky = inner(size);
    final r = sky * 0.153;
    final list = peeks();
    final total = visitSeconds();
    // rising and sinking always take the same time; only the pause between
    // them grows in the longer visits
    final rise = (1.3 / total).clamp(0.05, 0.3);
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: sky)));
    final heads = <Offset>[];
    for (final peek in list) {
      final p = ((visit - peek.delay) / (1 - peek.delay)).clamp(0.0, 1.0);
      if (p <= 0 || p >= 1) continue;
      // up (with a little overshoot), a pause with a small sway, then down
      final e = p < rise
          ? Curves.easeOutBack.transform(p / rise)
          : p < 1 - rise
          ? 1.0
          : 1 - Curves.easeInCubic.transform((p - (1 - rise)) / rise);
      final a = peek.angle;
      final dir = Offset(math.cos(a), math.sin(a));
      final dist = sky + r * 1.2 - e * (sky * 0.40 + r * 1.2);
      final at = c + dir * dist;
      heads.add(at);
      if (e >= 0.85 && p < 1 - rise) {
        _out.add((peek, at));
        _outRadius = r;
        ForestPeeker.heads.add(at);
      }
      final sway = p >= rise && p < 1 - rise
          ? math.sin((p - rise) * total * 2 * math.pi / 0.87) * 0.06
          : 0.0;
      // a pair lean towards each other
      final lean = list.length == 2 ? (peek == list.first ? 0.18 : -0.18) : 0.0;
      final tilt = (a - math.pi / 2).clamp(-0.6, 0.6) + sway + lean;

      canvas.save();
      canvas.translate(at.dx, at.dy);
      canvas.rotate(tilt);
      // a little dimmed, so the head belongs to the night around it
      canvas.saveLayer(
        Rect.fromCircle(center: Offset.zero, radius: r * 2),
        Paint()..color = const Color(0xD9FFFFFF),
      );
      paintAnimalHead(
        canvas,
        peek.animal,
        Offset.zero,
        r,
        special: peek.special,
      );
      canvas.restore();
      if (peek.animal == ForestAnimal.elephant) _firefly(canvas, r, p);
      canvas.restore();
      // the dense foliage at the rim swallows the base of the head
      canvas.save();
      canvas.clipPath(
        Path()..addOval(Rect.fromCircle(center: at, radius: r * 1.5)),
      );
      canvas.drawCircle(
        c,
        sky * 1.05,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFF040F0C).withValues(alpha: 0),
              const Color(0xFF040F0C).withValues(alpha: 0),
              const Color(0xFF040F0C).withValues(alpha: 0.97),
            ],
            stops: const [0, 0.82, 0.96],
          ).createShader(Rect.fromCircle(center: c, radius: sky * 1.05)),
      );
      canvas.restore();
    }
    // together, they share a small heart that floats up between them
    // (a new one every few seconds while they stay)
    final secs = visit * total;
    if (list.length == 2 &&
        heads.length == 2 &&
        secs > 1.8 &&
        secs < total - 1.4) {
      final t = ((secs - 1.8) % 3.2) / 3.2;
      final mid = Offset.lerp(heads[0], heads[1], 0.5)!;
      final towards = (c - mid) / (c - mid).distance;
      _heart(
        canvas,
        mid + towards * (r * (0.9 + 1.1 * t)),
        r * 0.34,
        const Color(0xFFFF8FA3).withValues(alpha: math.sin(t * math.pi)),
      );
    }
    canvas.restore();
  }

  /// Nuru's favourite: a firefly drifts in and settles on the tip of her
  /// trunk, glowing, then flits off as she ducks away. [r] is the head's
  /// radius, [p] how far through her visit she is.
  void _firefly(Canvas canvas, double r, double p) {
    if (p < 0.2 || p > 0.8) return;
    final land = Curves.easeInOut.transform(((p - 0.2) / 0.25).clamp(0.0, 1.0));
    final leave = Curves.easeIn.transform(((p - 0.65) / 0.15).clamp(0.0, 1.0));
    final rest = Offset(0.03 * r, 0.93 * r);
    var at = Offset.lerp(Offset(0.95 * r, 0.1 * r), rest, land)!;
    at = Offset.lerp(at, Offset(0.95 * r, -0.5 * r), leave)!;
    final glow = 0.6 + 0.4 * math.sin(p * 2 * math.pi * 9);
    final fade = 1 - leave;
    final col = const Color(0xFFE6F7A0);
    canvas.drawCircle(
      at,
      r * 0.2,
      Paint()
        ..color = col.withValues(alpha: 0.5 * glow * fade)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.12),
    );
    canvas.drawCircle(
      at,
      r * 0.045,
      Paint()..color = col.withValues(alpha: fade),
    );
  }

  void _heart(Canvas canvas, Offset at, double s, Color color) {
    canvas.drawPath(
      Path()
        ..moveTo(at.dx, at.dy + s * 0.9)
        ..cubicTo(
          at.dx - s * 1.6,
          at.dy - s * 0.2,
          at.dx - s * 0.7,
          at.dy - s * 1.3,
          at.dx,
          at.dy - s * 0.4,
        )
        ..cubicTo(
          at.dx + s * 0.7,
          at.dy - s * 1.3,
          at.dx + s * 1.6,
          at.dy - s * 0.2,
          at.dx,
          at.dy + s * 0.9,
        )
        ..close(),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_PeekPainter old) => false;
}
