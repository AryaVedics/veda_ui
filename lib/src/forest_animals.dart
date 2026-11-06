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
  // Season 2
  orangutan,
  horse,
  gorilla,
  dolphin,
  // the next round
  kiwi,
  stork,
  capybara,
  camel,
  penguin,
  falcon,
  monal,
  onager,
  jaguar,
}

/// The animals that come out to visit. A friend who is resting keeps a drawing
/// and a story, but does not appear (Milo, for now).
final List<ForestAnimal> kForestRotation = [
  for (final a in ForestAnimal.values)
    if (a != ForestAnimal.monkey) a,
];

/// The friend's name, for the share caption. Mei is the panda with her bamboo.
String friendNameOf(ForestAnimal a, {bool special = false}) => switch (a) {
  ForestAnimal.tiger => 'Tara',
  ForestAnimal.elephant => 'Nuru',
  ForestAnimal.panda => special ? 'Mei' : 'Bao',
  ForestAnimal.lion => 'Shumba',
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
  ForestAnimal.orangutan => 'Rimba',
  ForestAnimal.horse => 'Tulpar',
  ForestAnimal.gorilla => 'Mugisha',
  ForestAnimal.dolphin => 'Thalassa',
  ForestAnimal.kiwi => 'Aroha',
  ForestAnimal.stork => 'Vesna',
  ForestAnimal.capybara => 'Dengo',
  ForestAnimal.camel => 'Karvan',
  ForestAnimal.penguin => 'Eira',
  ForestAnimal.falcon => 'Saqr',
  ForestAnimal.monal => 'Danphe',
  ForestAnimal.onager => 'Gur',
  ForestAnimal.jaguar => 'Balam',
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
    case ForestAnimal.orangutan:
      _orangutan(canvas);
    case ForestAnimal.horse:
      _horse(canvas);
    case ForestAnimal.gorilla:
      _gorilla(canvas);
    case ForestAnimal.dolphin:
      _dolphin(canvas);
    case ForestAnimal.kiwi:
      _kiwi(canvas);
    case ForestAnimal.stork:
      _stork(canvas);
    case ForestAnimal.capybara:
      _capybara(canvas);
    case ForestAnimal.camel:
      _camel(canvas);
    case ForestAnimal.penguin:
      _penguin(canvas);
    case ForestAnimal.falcon:
      _falcon(canvas);
    case ForestAnimal.monal:
      _monal(canvas);
    case ForestAnimal.onager:
      _onager(canvas);
    case ForestAnimal.jaguar:
      _jaguar(canvas);
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

// ---- Season 2

void _orangutan(Canvas canvas) {
  const fur = Color(0xFFC9682D);
  const furDark = Color(0xFFA94F1E);
  const furLight = Color(0xFFE08A45);
  const skin = Color(0xFFE6B488);
  const pad = Color(0xFFD59A68);
  const muzzle = Color(0xFFF3D3AF);
  // a shaggy ring of tufts round the head, in two tones
  for (var i = 0; i < 18; i++) {
    final a = i * 2 * math.pi / 18;
    _oval(
      canvas,
      Offset(math.cos(a) * 0.84, math.sin(a) * 0.78 - 0.04),
      0.5,
      0.3,
      i.isEven ? fur : furDark,
      tilt: a + math.pi / 2,
    );
  }
  _oval(canvas, const Offset(0, -0.04), 1.78, 1.62, fur);
  // a taller topknot
  for (final dx in [-0.3, 0.0, 0.3]) {
    _oval(
      canvas,
      Offset(dx, -0.84 - (dx == 0 ? 0.06 : 0)),
      0.42,
      0.5,
      furLight,
      tilt: dx * 0.8,
    );
  }
  // soft cheek pads, as an orangutan has
  for (final sd in [-1.0, 1.0]) {
    _oval(canvas, Offset(sd * 0.6, 0.12), 0.46, 0.66, pad);
  }
  // the pale face
  _oval(canvas, const Offset(0, 0.06), 1.1, 1.12, skin);
  _oval(canvas, const Offset(0, 0.36), 0.74, 0.56, muzzle);
  // a small brow over each eye
  for (final sd in [-1.0, 1.0]) {
    _oval(
      canvas,
      Offset(sd * 0.25, -0.26),
      0.3,
      0.1,
      pad.withValues(alpha: 0.9),
      tilt: sd * -0.18,
    );
  }
  _eyes(canvas, gap: 0.5, y: -0.1, r: 0.088);
  for (final sd in [-1.0, 1.0]) {
    _oval(canvas, Offset(sd * 0.07, 0.28), 0.07, 0.05, const Color(0xFF8A5A3B));
  }
  _smile(canvas, 0.48, w: 0.2);
  for (final sd in [-1.0, 1.0]) {
    _oval(canvas, Offset(sd * 0.46, 0.3), 0.18, 0.11, _blush);
  }
}

void _horse(Canvas canvas) {
  const coat = Color(0xFFE2B462);
  const mane = Color(0xFFFFF0D2);
  const maneShade = Color(0xFFF0D8A6);
  const muzzle = Color(0xFFF2D5A8);
  const pink = Color(0xFFF0B9A8);
  // small, soft wings, a fan of feathers at each side: Tulpar is a flying horse
  // in the old stories, and only just remembers how
  for (final sd in [-1.0, 1.0]) {
    for (var k = 0; k < 3; k++) {
      final angle = sd * (0.55 + 0.42 * k);
      final reach = 0.62 - 0.06 * k;
      final base = Offset(sd * 0.74, -0.02 + 0.08 * k);
      canvas.save();
      canvas.translate(base.dx, base.dy);
      canvas.rotate(angle);
      _oval(
        canvas,
        Offset(0, -reach / 2),
        0.25,
        reach,
        k == 1 ? const Color(0xFFFFFFFF) : const Color(0xFFEAF3F8),
      );
      canvas.restore();
    }
  }
  // a long, soft mane falling on each side behind the head
  for (final sd in [-1.0, 1.0]) {
    for (var j = 0; j < 4; j++) {
      _oval(
        canvas,
        Offset(sd * (0.68 + 0.05 * j), -0.5 + 0.34 * j),
        0.36,
        0.62,
        j.isEven ? mane : maneShade,
        tilt: sd * 0.35,
      );
    }
  }
  // upright ears
  for (final sd in [-1.0, 1.0]) {
    canvas.drawPath(
      _smoothShape([
        Offset(sd * 0.26, -0.66),
        Offset(sd * 0.46, -1.3),
        Offset(sd * 0.74, -0.66),
        Offset(sd * 0.5, -0.46),
      ]),
      _fill(coat),
    );
    canvas.drawPath(
      _smoothShape([
        Offset(sd * 0.36, -0.72),
        Offset(sd * 0.47, -1.08),
        Offset(sd * 0.62, -0.72),
        Offset(sd * 0.48, -0.6),
      ]),
      _fill(pink),
    );
  }
  // the long head, wide at the brow and narrowing to the nose
  canvas.drawPath(
    _smoothShape(const [
      Offset(0, -0.9),
      Offset(0.6, -0.66),
      Offset(0.72, -0.02),
      Offset(0.6, 0.58),
      Offset(0.4, 0.98),
      Offset(0, 1.04),
      Offset(-0.4, 0.98),
      Offset(-0.6, 0.58),
      Offset(-0.72, -0.02),
      Offset(-0.6, -0.66),
    ]),
    _fill(coat),
  );
  // a pale blaze down the face
  _oval(canvas, const Offset(0, -0.2), 0.2, 1.0, const Color(0xFFFFF6E4));
  // the forelock between the ears
  for (final dx in [-0.18, 0.0, 0.18]) {
    _oval(
      canvas,
      Offset(dx, -0.8),
      0.26,
      0.5,
      dx == 0 ? mane : maneShade,
      tilt: dx * 0.7,
    );
  }
  // the muzzle, with its nostrils
  _oval(canvas, const Offset(0, 0.74), 0.84, 0.52, muzzle);
  for (final sd in [-1.0, 1.0]) {
    _oval(
      canvas,
      Offset(sd * 0.2, 0.66),
      0.1,
      0.15,
      const Color(0xFF7A5238),
      tilt: sd * 0.4,
    );
    _oval(canvas, Offset(sd * 0.52, 0.3), 0.2, 0.12, _blush);
  }
  _eyes(canvas, gap: 0.92, y: -0.1, r: 0.09);
  _smile(canvas, 0.92, w: 0.12);
}

void _onager(Canvas canvas) {
  // a Persian onager, the swift wild equid of the Iranian plateau: a sandy coat,
  // big upright ears, a short standing mane and a pale muzzle
  const coat = Color(0xFFCFA070);
  const coatDark = Color(0xFFA67B4E);
  const pale = Color(0xFFF6EAD3);
  const mane = Color(0xFF6E4E34);
  const pink = Color(0xFFEFB9A8);
  // big ears with dark tips
  for (final sd in [-1.0, 1.0]) {
    canvas.drawPath(
      _smoothShape([
        Offset(sd * 0.2, -0.62),
        Offset(sd * 0.4, -1.42),
        Offset(sd * 0.78, -0.7),
        Offset(sd * 0.5, -0.44),
      ]),
      _fill(coat),
    );
    canvas.drawPath(
      _smoothShape([
        Offset(sd * 0.3, -0.7),
        Offset(sd * 0.42, -1.12),
        Offset(sd * 0.64, -0.72),
        Offset(sd * 0.47, -0.58),
      ]),
      _fill(pink),
    );
    _oval(canvas, Offset(sd * 0.42, -1.3), 0.2, 0.22, mane, tilt: sd * 0.3);
  }
  // the short, standing mane between the ears
  for (var j = -2; j <= 2; j++) {
    _oval(
      canvas,
      Offset(j * 0.13, -0.86 + j.abs() * 0.05),
      0.2,
      0.46,
      mane,
      tilt: j * 0.18,
    );
  }
  // the head: broad at the brow, tapering to a pale muzzle
  canvas.drawPath(
    _smoothShape(const [
      Offset(0, -0.84),
      Offset(0.62, -0.62),
      Offset(0.7, -0.02),
      Offset(0.56, 0.56),
      Offset(0.38, 0.96),
      Offset(0, 1.02),
      Offset(-0.38, 0.96),
      Offset(-0.56, 0.56),
      Offset(-0.7, -0.02),
      Offset(-0.62, -0.62),
    ]),
    _fill(coat),
  );
  // the darker line of the brow and a pale ring round the eyes
  _oval(canvas, const Offset(0, -0.52), 0.5, 0.2, coatDark);
  for (final sd in [-1.0, 1.0]) {
    _oval(canvas, Offset(sd * 0.3, -0.12), 0.3, 0.22, pale, tilt: sd * -0.2);
  }
  // the pale muzzle, with its nostrils
  _oval(canvas, const Offset(0, 0.72), 0.86, 0.54, pale);
  for (final sd in [-1.0, 1.0]) {
    _oval(
      canvas,
      Offset(sd * 0.2, 0.64),
      0.1,
      0.14,
      const Color(0xFF7A5238),
      tilt: sd * 0.4,
    );
    _oval(canvas, Offset(sd * 0.5, 0.26), 0.2, 0.12, _blush);
  }
  _eyes(canvas, gap: 0.6, y: -0.12, r: 0.09);
  _smile(canvas, 0.9, w: 0.12);
}

void _jaguar(Canvas canvas) {
  // a jaguar of the Maya forests: golden coat, rosettes rather than stripes,
  // round ears and a broad, strong face
  const gold = Color(0xFFE8B24E);
  const cream = Color(0xFFFFF1D6);
  const spot = Color(0xFF4A3322);
  // round ears with dark backs
  for (final sd in [-1.0, 1.0]) {
    _disc(canvas, Offset(sd * 0.66, -0.64), 0.27, gold);
    _disc(canvas, Offset(sd * 0.66, -0.62), 0.15, spot);
  }
  _oval(canvas, Offset.zero, 1.8, 1.56, gold);
  // rosettes: a ring with a dot at its heart
  void rosette(Offset at, double r) {
    canvas.drawCircle(
      at,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.5
        ..color = spot,
    );
    _disc(canvas, at, r * 0.28, spot);
  }

  rosette(const Offset(0, -0.62), 0.1);
  for (final sd in [-1.0, 1.0]) {
    rosette(Offset(sd * 0.3, -0.58), 0.085);
    rosette(Offset(sd * 0.82, -0.14), 0.11);
    rosette(Offset(sd * 0.78, 0.2), 0.1);
    rosette(Offset(sd * 0.6, -0.4), 0.09);
    rosette(Offset(sd * 0.66, 0.46), 0.08);
  }
  // the broad cream muzzle and chin
  _oval(canvas, const Offset(0, 0.34), 1.0, 0.68, cream);
  for (final sd in [-1.0, 1.0]) {
    for (final dx in [0.14, 0.28, 0.4]) {
      _disc(canvas, Offset(sd * dx, 0.36 + dx * 0.1), 0.02, spot);
    }
  }
  _eyes(canvas, gap: 0.64, y: -0.06);
  _nose(canvas, const Offset(0, 0.2), const Color(0xFFD9786E));
  _smile(canvas, 0.4);
  _cheeks(canvas, x: 0.66, y: 0.2);
}

void _gorilla(Canvas canvas) {
  const fur = Color(0xFF3F3F49);
  const silver = Color(0xFFA6ACBB);
  const face = Color(0xFF6B6672);
  const muzzle = Color(0xFF8C848E);
  // small round ears
  for (final sd in [-1.0, 1.0]) {
    _disc(canvas, Offset(sd * 0.9, 0.04), 0.17, fur);
    _disc(canvas, Offset(sd * 0.9, 0.04), 0.09, face);
  }
  // the broad head, with a high domed crown
  _oval(canvas, const Offset(0, -0.04), 1.8, 1.66, fur);
  _oval(canvas, const Offset(0, -0.62), 1.14, 0.84, fur);
  // the silver of a silverback, across the top
  _oval(
    canvas,
    const Offset(0, -0.74),
    0.66,
    0.3,
    silver.withValues(alpha: 0.6),
  );
  // the lighter, wide face under a heavy brow
  _oval(canvas, const Offset(0, 0.12), 1.2, 1.1, face);
  _oval(canvas, const Offset(0, -0.2), 1.1, 0.3, fur);
  // the eyes: dark, under the brow, so they get a larger highlight
  for (final sd in [-1.0, 1.0]) {
    _disc(canvas, Offset(sd * 0.23, -0.06), 0.09, _ink);
    _disc(canvas, Offset(sd * 0.23 - 0.03, -0.09), 0.04, Colors.white);
  }
  // a big muzzle and wide nostrils
  _oval(canvas, const Offset(0, 0.4), 0.8, 0.62, muzzle);
  for (final sd in [-1.0, 1.0]) {
    _oval(canvas, Offset(sd * 0.15, 0.3), 0.16, 0.09, _ink, tilt: sd * 0.3);
    _oval(canvas, Offset(sd * 0.56, 0.3), 0.2, 0.12, _blush);
  }
  _smile(canvas, 0.55, w: 0.2);
}

void _dolphin(Canvas canvas) {
  // drawn in profile, facing right, and moved and shrunk to sit in the same
  // square as the rest
  canvas.save();
  canvas.translate(-0.1, 0.1);
  canvas.scale(0.94);
  const blue = Color(0xFF6FA2C8);
  const deep = Color(0xFF5887AF);
  const belly = Color(0xFFEAF3F8);
  const spray = Color(0xFFCFE6F3);
  // a few drops of spray above
  for (final d in const [
    (Offset(0.04, -1.08), 0.07),
    (Offset(0.3, -1.2), 0.055),
    (Offset(-0.22, -1.18), 0.05),
  ]) {
    _disc(canvas, d.$1, d.$2, spray);
  }
  // the dorsal fin, behind
  canvas.drawPath(
    _smoothShape(const [
      Offset(-0.5, -0.55),
      Offset(-0.8, -1.0),
      Offset(-1.0, -0.4),
      Offset(-0.7, -0.35),
    ]),
    _fill(deep),
  );
  // the pectoral fin, low at the side
  _oval(canvas, const Offset(-0.48, 0.66), 0.34, 0.74, deep, tilt: 0.7);
  // the round head and the body behind it
  _oval(canvas, const Offset(-0.2, -0.02), 1.7, 1.5, blue);
  // the pale underside and lower jaw
  canvas.drawPath(
    _smoothShape(const [
      Offset(-0.6, 0.55),
      Offset(0.1, 0.42),
      Offset(0.95, 0.3),
      Offset(0.7, 0.55),
      Offset(0.1, 0.78),
      Offset(-0.5, 0.8),
    ]),
    _fill(belly),
  );
  // the beak, rounded and a little lighter than the head
  canvas.drawPath(
    _smoothShape(const [
      Offset(0.5, -0.12),
      Offset(1.12, 0.0),
      Offset(1.26, 0.2),
      Offset(1.05, 0.34),
      Offset(0.5, 0.34),
    ]),
    _fill(const Color(0xFF84B3D4)),
  );
  // the broad, curved smile
  canvas.drawPath(
    Path()
      ..moveTo(1.2, 0.24)
      ..quadraticBezierTo(0.8, 0.4, 0.4, 0.2),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.04
      ..strokeCap = StrokeCap.round
      ..color = _ink,
  );
  // the eye, big and bright
  _bigEye(canvas, const Offset(0.28, -0.14), 0.115);
  _oval(canvas, const Offset(0.1, 0.2), 0.2, 0.12, _blush);
  // the blowhole on top
  _oval(canvas, const Offset(-0.08, -0.74), 0.12, 0.05, deep);
  canvas.restore();
}

// ---- the next round

void _kiwi(Canvas canvas) {
  const feather = Color(0xFF8C6B44);
  const dark = Color(0xFF6C5032);
  const light = Color(0xFFB18C5C);
  const beak = Color(0xFFEBD6A6);
  // a fluffy ring of feathers, in two tones
  for (var i = 0; i < 16; i++) {
    final a = i * 2 * math.pi / 16;
    _oval(
      canvas,
      Offset(math.cos(a) * 0.8, math.sin(a) * 0.74 - 0.04),
      0.44,
      0.28,
      i.isEven ? feather : dark,
      tilt: a + math.pi / 2,
    );
  }
  _oval(canvas, const Offset(0, -0.04), 1.72, 1.6, feather);
  _oval(canvas, const Offset(0, 0.06), 1.0, 0.9, light);
  // a few streaks of feather
  final streak = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 0.03
    ..color = dark.withValues(alpha: 0.55);
  for (final sd in [-1.0, 1.0]) {
    canvas.drawLine(Offset(sd * 0.55, -0.5), Offset(sd * 0.62, -0.28), streak);
    canvas.drawLine(Offset(sd * 0.3, -0.68), Offset(sd * 0.36, -0.5), streak);
    canvas.drawLine(Offset(sd * 0.86, 0.1), Offset(sd * 0.9, 0.3), streak);
  }
  _eyes(canvas, gap: 0.62, y: -0.12, r: 0.08);
  // the long, thin beak, with its nostril at the very tip
  canvas.drawPath(
    _smoothShape(const [
      Offset(-0.15, 0.1),
      Offset(0.15, 0.1),
      Offset(0.09, 0.9),
      Offset(0.0, 1.2),
      Offset(-0.07, 0.9),
    ]),
    _fill(beak),
  );
  _disc(canvas, const Offset(0.0, 1.08), 0.022, const Color(0xFF9F8A5E));
  for (final sd in [-1.0, 1.0]) {
    _oval(canvas, Offset(sd * 0.55, 0.24), 0.2, 0.12, _blush);
  }
}

void _stork(Canvas canvas) {
  // drawn in profile, facing right, and moved and shrunk to sit in the same
  // square as the rest
  canvas.save();
  canvas.translate(-0.34, 0.0);
  canvas.scale(0.88);
  const white = Color(0xFFFBFBF8);
  const red = Color(0xFFE0523A);
  const redDark = Color(0xFFBF3F2C);
  const black = Color(0xFF2E2D33);
  // the white neck, rising in a curve
  canvas.drawPath(
    Path()
      ..moveTo(-0.14, 1.25)
      ..cubicTo(-0.4, 0.62, 0.3, 0.4, 0.0, -0.1),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.52
      ..strokeCap = StrokeCap.round
      ..color = white,
  );
  // a little black at the edge of the wing
  _oval(canvas, const Offset(-0.38, 1.0), 0.3, 0.56, black, tilt: 0.3);
  // the round white head
  _disc(canvas, const Offset(0.04, -0.32), 0.46, white);
  // the long red beak, straight and a little heavy
  canvas.drawPath(
    _smoothShape(const [
      Offset(0.38, -0.48),
      Offset(1.5, -0.2),
      Offset(1.46, -0.12),
      Offset(0.4, -0.12),
    ]),
    _fill(red),
  );
  canvas.drawLine(
    const Offset(0.44, -0.3),
    const Offset(1.4, -0.17),
    Paint()
      ..strokeWidth = 0.03
      ..strokeCap = StrokeCap.round
      ..color = redDark,
  );
  // the eye, bright against the white, with its blush
  _disc(canvas, const Offset(0.2, -0.4), 0.08, _ink);
  _disc(canvas, const Offset(0.18, -0.43), 0.03, Colors.white);
  _oval(canvas, const Offset(0.0, -0.18), 0.22, 0.12, _blush);
  canvas.restore();
}

void _capybara(Canvas canvas) {
  const brown = Color(0xFFA67B50);
  const dark = Color(0xFF8A6340);
  const muzzle = Color(0xFFCDA97E);
  const nose = Color(0xFF4A3426);
  // small round ears on top
  for (final sd in [-1.0, 1.0]) {
    _disc(canvas, Offset(sd * 0.62, -0.6), 0.18, brown);
    _disc(canvas, Offset(sd * 0.62, -0.58), 0.1, const Color(0xFFC79A7B));
  }
  // a wide, blocky head
  _oval(canvas, Offset.zero, 1.86, 1.52, brown);
  _oval(canvas, const Offset(0, -0.36), 1.3, 0.5, dark.withValues(alpha: 0.5));
  // the great blunt muzzle
  _oval(canvas, const Offset(0, 0.36), 1.16, 0.8, muzzle);
  _oval(canvas, const Offset(0, 0.12), 0.44, 0.24, nose);
  _oval(canvas, const Offset(-0.06, 0.07), 0.12, 0.06, const Color(0x55FFFFFF));
  // small, calm eyes, set wide
  _eyes(canvas, gap: 0.86, y: -0.14, r: 0.075);
  // whisker dots
  for (final sd in [-1.0, 1.0]) {
    for (final p in const [(0.22, 0.34), (0.34, 0.42), (0.18, 0.46)]) {
      _disc(canvas, Offset(sd * p.$1, p.$2), 0.018, dark);
    }
  }
  _smile(canvas, 0.52, w: 0.16);
  for (final sd in [-1.0, 1.0]) {
    _oval(canvas, Offset(sd * 0.7, 0.2), 0.2, 0.12, _blush);
  }
  // a small orange sitting on his head, as capybaras are said to like
  const fruit = Offset(0.0, -0.84);
  _disc(canvas, fruit, 0.22, const Color(0xFFF2A238));
  _disc(
    canvas,
    fruit + const Offset(-0.07, -0.07),
    0.06,
    const Color(0x66FFFFFF),
  );
  _oval(
    canvas,
    fruit + const Offset(0.1, -0.22),
    0.16,
    0.08,
    const Color(0xFF7DB07E),
    tilt: -0.5,
  );
}

void _camel(Canvas canvas) {
  // a Bactrian camel, the shaggy, two-humped kind of the steppe and the cold
  // deserts of Mongolia and Central Asia: a thick coat, a woolly topknot and a
  // beard
  const fur = Color(0xFF8E6B46);
  const furDark = Color(0xFF6D4F33);
  const furLight = Color(0xFFB48B5C);
  const face = Color(0xFFCDA672);
  const muzzle = Color(0xFFE3C79B);
  const pink = Color(0xFFEFB9A8);
  // the two humps, rising behind the head
  for (final sd in [-1.0, 1.0]) {
    _oval(
      canvas,
      Offset(sd * 0.36, -1.02),
      0.62,
      0.7,
      furDark,
      tilt: sd * 0.12,
    );
    _oval(canvas, Offset(sd * 0.36, -1.0), 0.5, 0.56, fur, tilt: sd * 0.12);
  }
  // a shaggy ring of coat round the head, in two tones
  for (var i = 0; i < 20; i++) {
    final a = i * 2 * math.pi / 20;
    _oval(
      canvas,
      Offset(math.cos(a) * 0.78, math.sin(a) * 0.9 + 0.02),
      0.5,
      0.3,
      i.isEven ? fur : furDark,
      tilt: a + math.pi / 2,
    );
  }
  // little ears in the fur
  for (final sd in [-1.0, 1.0]) {
    _disc(canvas, Offset(sd * 0.56, -0.72), 0.17, fur);
    _disc(canvas, Offset(sd * 0.56, -0.7), 0.09, pink);
  }
  _oval(canvas, const Offset(0, 0.0), 1.56, 1.9, fur);
  // the woolly topknot between the ears
  for (final dx in [-0.3, -0.15, 0.0, 0.15, 0.3]) {
    _oval(
      canvas,
      Offset(dx, -0.9 + (dx.abs() * 0.3)),
      0.34,
      0.5,
      dx.abs() > 0.2 ? fur : furLight,
      tilt: dx * 0.9,
    );
  }
  // the long, gentle face inside the coat
  canvas.drawPath(
    _smoothShape(const [
      Offset(0, -0.72),
      Offset(0.5, -0.5),
      Offset(0.58, 0.0),
      Offset(0.48, 0.5),
      Offset(0.34, 0.9),
      Offset(0, 0.96),
      Offset(-0.34, 0.9),
      Offset(-0.48, 0.5),
      Offset(-0.58, 0.0),
      Offset(-0.5, -0.5),
    ]),
    _fill(face),
  );
  // heavy lids over the eyes, and the long lashes of a camel
  for (final sd in [-1.0, 1.0]) {
    _oval(
      canvas,
      Offset(sd * 0.34, -0.26),
      0.3,
      0.11,
      furLight,
      tilt: sd * -0.15,
    );
  }
  _eyes(canvas, gap: 0.68, y: -0.12, r: 0.09);
  final lash = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 0.028
    ..color = _ink;
  for (final sd in [-1.0, 1.0]) {
    final e = Offset(sd * 0.34, -0.12);
    canvas.drawLine(
      e + Offset(sd * 0.1, -0.09),
      e + Offset(sd * 0.17, -0.16),
      lash,
    );
    canvas.drawLine(
      e + Offset(sd * 0.04, -0.11),
      e + Offset(sd * 0.07, -0.2),
      lash,
    );
  }
  // the soft, split muzzle
  _oval(canvas, const Offset(0, 0.66), 0.74, 0.5, muzzle);
  for (final sd in [-1.0, 1.0]) {
    _oval(
      canvas,
      Offset(sd * 0.13, 0.54),
      0.1,
      0.06,
      const Color(0xFF7A5238),
      tilt: sd * -0.5,
    );
    _oval(canvas, Offset(sd * 0.44, 0.24), 0.18, 0.11, _blush);
  }
  canvas.drawLine(
    const Offset(0, 0.58),
    const Offset(0, 0.78),
    Paint()
      ..strokeWidth = 0.025
      ..strokeCap = StrokeCap.round
      ..color = furLight,
  );
  _smile(canvas, 0.84, w: 0.13);
  // the beard
  for (final dx in [-0.26, -0.1, 0.1, 0.26]) {
    _oval(
      canvas,
      Offset(dx, 1.0 - dx.abs() * 0.2),
      0.26,
      0.34,
      dx.abs() > 0.2 ? furDark : fur,
      tilt: dx * 0.6,
    );
  }
}

void _penguin(Canvas canvas) {
  const black = Color(0xFF2B2E3A);
  const white = Color(0xFFFAFAF7);
  const beak = Color(0xFFF2A23C);
  const patch = Color(0xFFF7CC5E);
  // the round dark head
  _oval(canvas, const Offset(0, -0.02), 1.72, 1.64, black);
  // the white face, a heart round the eyes
  _disc(canvas, const Offset(-0.3, -0.02), 0.46, white);
  _disc(canvas, const Offset(0.3, -0.02), 0.46, white);
  _oval(canvas, const Offset(0, 0.3), 0.92, 0.8, white);
  // the warm patches at the sides of the head
  for (final sd in [-1.0, 1.0]) {
    _oval(canvas, Offset(sd * 0.78, 0.04), 0.2, 0.34, patch, tilt: sd * 0.2);
  }
  _eyes(canvas, gap: 0.5, y: -0.1, r: 0.088);
  // a small, bright beak
  canvas.drawPath(
    _smoothShape(const [
      Offset(-0.15, 0.08),
      Offset(0.15, 0.08),
      Offset(0.12, 0.28),
      Offset(0.0, 0.42),
      Offset(-0.12, 0.28),
    ]),
    _fill(beak),
  );
  _smile(canvas, 0.52, w: 0.12);
  for (final sd in [-1.0, 1.0]) {
    _oval(canvas, Offset(sd * 0.5, 0.26), 0.2, 0.12, _blush);
  }
}

void _falcon(Canvas canvas) {
  const slate = Color(0xFF627086);
  const slateDark = Color(0xFF465266);
  const cream = Color(0xFFF5ECDD);
  const cere = Color(0xFFF1CA4F);
  const beak = Color(0xFF8E98A8);
  // a ring of feather tufts, in two tones
  for (var i = 0; i < 16; i++) {
    final a = i * 2 * math.pi / 16;
    _oval(
      canvas,
      Offset(math.cos(a) * 0.8, math.sin(a) * 0.74 - 0.04),
      0.44,
      0.28,
      i.isEven ? slate : slateDark,
      tilt: a + math.pi / 2,
    );
  }
  _oval(canvas, const Offset(0, -0.04), 1.72, 1.62, slate);
  // the darker cap
  _oval(canvas, const Offset(0, -0.46), 1.3, 0.62, slateDark);
  // the pale cheeks and throat
  _disc(canvas, const Offset(-0.36, 0.22), 0.5, cream);
  _disc(canvas, const Offset(0.36, 0.22), 0.5, cream);
  _oval(canvas, const Offset(0, 0.52), 0.94, 0.78, cream);
  // the dark moustache stripe under each eye
  final stripe = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 0.1
    ..color = const Color(0xFF2B2F3B);
  for (final sd in [-1.0, 1.0]) {
    canvas.drawPath(
      Path()
        ..moveTo(sd * 0.4, 0.04)
        ..quadraticBezierTo(sd * 0.5, 0.3, sd * 0.36, 0.58),
      stripe,
    );
  }
  // big dark eyes, each in a pale ring
  for (final sd in [-1.0, 1.0]) {
    _disc(canvas, Offset(sd * 0.31, -0.1), 0.15, const Color(0xFFF3E1A6));
    _bigEye(canvas, Offset(sd * 0.31, -0.1), 0.1);
  }
  // the hooked beak, with its yellow cere
  canvas.drawPath(
    _smoothShape(const [
      Offset(-0.14, 0.2),
      Offset(0.14, 0.2),
      Offset(0.1, 0.46),
      Offset(0.0, 0.7),
      Offset(-0.08, 0.5),
    ]),
    _fill(beak),
  );
  _oval(canvas, const Offset(0, 0.22), 0.3, 0.14, cere);
  for (final sd in [-1.0, 1.0]) {
    _disc(canvas, Offset(sd * 0.05, 0.22), 0.016, const Color(0xFF8A6B22));
  }
}

void _monal(Canvas canvas) {
  // the male Himalayan monal, in profile, facing right, and moved and shrunk to
  // sit in the same square as the rest: a shining green head with a crest of
  // little paddles, a blue patch round the eye, a neck that runs from fire to
  // gold, and the violet of his back below
  canvas.save();
  canvas.translate(-0.2, 0.06);
  canvas.scale(0.84);
  const violet = Color(0xFF6A55D6);
  const blue = Color(0xFF3F7FE0);
  const teal = Color(0xFF2FA8A0);
  // the neck: red under the head, through orange, to gold
  canvas.drawPath(
    Path()
      ..moveTo(0.04, 0.6)
      ..quadraticBezierTo(-0.08, 0.22, 0.0, -0.2),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.68
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFC92F2F), Color(0xFFEE7A2B), Color(0xFFF4C542)],
        stops: [0.25, 0.62, 1],
      ).createShader(const Rect.fromLTRB(-0.5, -0.3, 0.5, 0.74)),
  );
  // the pale collar over the foot of the neck, and the violet back rising
  // behind it, so the neck grows out of the bird
  _oval(canvas, const Offset(0.02, 0.6), 1.04, 0.32, const Color(0xFF9CC9B8));
  _oval(canvas, const Offset(-0.04, 1.0), 1.56, 0.7, violet);
  _oval(canvas, const Offset(-0.4, 0.96), 0.56, 0.28, blue, tilt: 0.3);
  // the crest: thin stems curling back, each ending in a little paddle
  final stem = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 0.035
    ..color = const Color(0xFF1F8C64);
  for (final c in const [
    (Offset(0.1, -0.84), Offset(0.14, -1.14), Offset(-0.02, -1.3)),
    (Offset(-0.02, -0.84), Offset(-0.04, -1.1), Offset(-0.24, -1.22)),
    (Offset(-0.12, -0.8), Offset(-0.2, -1.0), Offset(-0.44, -1.06)),
    (Offset(-0.2, -0.74), Offset(-0.34, -0.86), Offset(-0.58, -0.84)),
  ]) {
    canvas.drawPath(
      Path()
        ..moveTo(c.$1.dx, c.$1.dy)
        ..quadraticBezierTo(c.$2.dx, c.$2.dy, c.$3.dx, c.$3.dy),
      stem,
    );
    _oval(
      canvas,
      c.$3,
      0.2,
      0.11,
      const Color(0xFF39C486),
      tilt: (c.$3 - c.$2).direction,
    );
  }
  // the round head, shining
  canvas.drawCircle(
    const Offset(0.02, -0.38),
    0.52,
    Paint()
      ..shader =
          const RadialGradient(
            center: Alignment(-0.25, -0.5),
            radius: 1,
            colors: [Color(0xFF6FE7A0), Color(0xFF1F9C6E), Color(0xFF137066)],
            stops: [0, 0.55, 1],
          ).createShader(
            Rect.fromCircle(center: const Offset(0.02, -0.38), radius: 0.52),
          ),
  );
  // a touch of teal where the head meets the neck
  _oval(canvas, const Offset(-0.06, -0.02), 0.54, 0.16, teal);
  // the short, curved bill
  canvas.drawPath(
    _smoothShape(const [
      Offset(0.44, -0.5),
      Offset(0.76, -0.42),
      Offset(0.9, -0.22),
      Offset(0.72, -0.24),
      Offset(0.44, -0.24),
    ]),
    _fill(const Color(0xFFD9D3C2)),
  );
  // the bright blue skin round the eye, and the eye itself
  _disc(canvas, const Offset(0.22, -0.42), 0.17, blue);
  _bigEye(canvas, const Offset(0.23, -0.42), 0.1);
  _oval(canvas, const Offset(0.1, -0.16), 0.2, 0.11, const Color(0xAAFFA08F));
  canvas.restore();
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

  /// Whether friends visit at all. Off, nobody comes out, on Today or in Nature
  /// Mode, and the forest is only trees.
  static final visitsOn = ValueNotifier<bool>(true);

  /// Quiet mode: visits are rarer and slower, with no pairs, no floating heart
  /// and no firefly landing on Nuru.
  static bool calm = false;

  /// How long a friend takes to rise, and the same to sink.
  static double get edgeSeconds => calm ? kCalmEdgeSeconds : kEdgeSeconds;

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

/// How long, in seconds, a friend takes to rise into view, and the same to sink
/// back: slow enough to watch, so they glide rather than pop.
const double kEdgeSeconds = 2.4;

/// The same, for quiet mode: a little slower still.
const double kCalmEdgeSeconds = 3.2;

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
    duration: const Duration(milliseconds: 7500),
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

  double get _rise =>
      (ForestPeeker.edgeSeconds / (_visit.inMilliseconds / 1000)).clamp(
        0.05,
        0.45,
      );

  /// How long this visit lasts. The rare ones stay longer, so there is time to
  /// enjoy them, and to take a screenshot.
  var _visit = const Duration(milliseconds: 7500);
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
    ForestPeeker.visitsOn.addListener(_visitsChanged);
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
  void _adoptRunningVisit() => _resumeFromOther();

  /// Whether this forest is on screen: a forest covered by Nature Mode is not.
  var _wasShown = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final shown = TickerMode.valuesOf(context).enabled;
    if (shown && !_wasShown) _resumeFromOther();
    _wasShown = shown;
  }

  /// Shown again (on entering, or coming back from Nature Mode): the visit the
  /// other forest is playing carries on here, at the point it has reached, so
  /// the animals are exactly where the person left them.
  void _resumeFromOther() {
    for (final other in ForestPeeker._running) {
      if (identical(other, this) || !other._visiting || other._peeks.isEmpty) {
        continue;
      }
      _takeOverFrom(other);
      return;
    }
  }

  void _takeOverFrom(_ForestPeekerState other) {
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

  /// Turned on or off from the Friends card: off stops the next visit, on starts
  /// the wait for one again.
  void _visitsChanged() {
    if (!mounted) return;
    if (!ForestPeeker.visitsOn.value) {
      _timer?.cancel();
    } else if (!_visiting && !(_timer?.isActive ?? false)) {
      _schedule(8 + _rnd.nextInt(8));
    }
  }

  void _end() {
    widget.friend?.value = null;
    _visiting = false;
    if (mounted) {
      final gap = widget.eager ? 20 + _rnd.nextInt(11) : 20 + _rnd.nextInt(26);
      _schedule(
        ForestPeeker.calm ? (gap * 1.5).round() : gap,
        afterVisit: true,
      );
    }
  }

  void _schedule(int seconds, {bool afterVisit = false}) {
    _timer?.cancel();
    if (!ForestPeeker.visitsOn.value) return;
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
        !ForestPeeker.calm &&
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
        for (final a in kForestRotation)
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
      _visit = Duration(milliseconds: mei ? 15000 : 7500);
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
    ForestPeeker.visitsOn.removeListener(_visitsChanged);
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
    final rise = (ForestPeeker.edgeSeconds / total).clamp(0.05, 0.45);
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: sky)));
    final heads = <Offset>[];
    for (final peek in list) {
      final p = ((visit - peek.delay) / (1 - peek.delay)).clamp(0.0, 1.0);
      if (p <= 0 || p >= 1) continue;
      // up, a pause with a small sway, then down: both ends glide with the same
      // soft curve, so nothing pops in or out
      final e = p < rise
          ? Curves.easeInOutCubic.transform(p / rise)
          : p < 1 - rise
          ? 1.0
          : 1 - Curves.easeInOutCubic.transform((p - (1 - rise)) / rise);
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
      if (peek.animal == ForestAnimal.elephant && !ForestPeeker.calm) {
        _firefly(canvas, r, p);
      }
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
    if (!ForestPeeker.calm &&
        list.length == 2 &&
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
