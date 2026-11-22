// The shopfront that Véda Garden's potting shed and Véda Learn's library
// share, in the spirit of Véda Curio's: a carved fascia with a gold
// nameplate, fluted posts with brass plaques and hanging baskets trailing ivy
// and flowers, a back wall of boards with a little arched window (the sky of
// the hour, and the day's friend looking out when the friends are on)
// between two lanterns, and a panelled counter. Also the things that fill it:
// plants drawn as their kinds, pots of many kinds, wood, and the little
// fairies and motes that drift about.
//
// Every size comes from one factor (the box's width over 360 and height over
// 520, the smaller), so it scales with the phone.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'forest_animals.dart';
import 'forest_friends.dart';
import 'vedafolk_visits.dart';

/// Where the shopfront's parts sit for one size.
class ShopFrame {
  ShopFrame(this.size, {required this.counterY, required this.windowBottom})
    : k = math
          .min(size.width / 360, size.height / 520)
          .clamp(0.55, 2.0)
          .toDouble();

  final Size size;
  final double k;

  /// The counter's top, where the lowest shelf's things stand.
  final double counterY;

  /// The foot of the little window at the back.
  final double windowBottom;

  double get w => size.width;
  double get h => size.height;

  double get postW => w * 0.075;
  double get fasciaH => h * 0.075;

  /// The open shop between the posts, under the fascia, down to the counter.
  Rect get inner => Rect.fromLTRB(postW, fasciaH, w - postW, counterY);

  /// The little window at the back.
  Rect get window => Rect.fromLTRB(w * 0.37, h * 0.115, w * 0.63, windowBottom);

  /// The lanterns, hanging either side of the window.
  List<Offset> get lanterns => [
    Offset(w * 0.235, h * 0.165),
    Offset(w * 0.765, h * 0.165),
  ];

  /// Where the day's friend looks out of the window.
  Offset get hostCentre => Offset(
    window.center.dx - window.width * 0.08,
    window.top + window.width * 0.62,
  );

  double get hostR => 30 * k;
}

/// A shelf across the shop at [y]: a board, its shadow below, and two
/// brackets.
void paintShopShelf(Canvas canvas, ShopFrame f, double y, {int seed = 3}) {
  final k = f.k, w = f.w;
  final inner = f.inner;
  paintBoard(
    canvas,
    Rect.fromLTRB(inner.left, y, inner.right, y + 8 * k),
    k,
    seed: seed,
  );
  canvas.drawRect(
    Rect.fromLTRB(inner.left, y + 8 * k, inner.right, y + 13 * k),
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.black.withValues(alpha: 0.35),
          Colors.black.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTRB(0, y + 8 * k, 1, y + 13 * k)),
  );
  for (final x in [inner.left + w * 0.05, inner.right - w * 0.05]) {
    final b = Path()
      ..moveTo(x - 4 * k, y + 8 * k)
      ..lineTo(x + 4 * k, y + 8 * k)
      ..lineTo(x + 4 * k, y + 16 * k)
      ..quadraticBezierTo(x, y + 12 * k, x - 4 * k, y + 22 * k)
      ..close();
    canvas.drawPath(b, Paint()..color = shopWoodDark);
  }
}

/// Whole days since the start of 2026: the day's number, the same all day.
int shopDayNumber(DateTime day) => DateTime.utc(
  day.year,
  day.month,
  day.day,
).difference(DateTime.utc(2026)).inDays;

/// [count] different friends for [day] from the everyday rotation, the same
/// all day and new the next, none twice: the friends who live in a shop.
List<ForestFriend> shopFriendsOf(DateTime day, int count) {
  final pool = [
    for (final f in kForestFriends)
      if (kForestRotation.contains(f.animal)) f,
  ];
  final start = shopDayNumber(day) * 5 + 2;
  final out = <ForestFriend>[];
  var step = 0;
  while (out.length < math.min(count, pool.length)) {
    final f = pool[(start + step * 7) % pool.length];
    if (!out.contains(f)) out.add(f);
    step++;
  }
  return out;
}

/// The default plaque glyph: a leaf, cut into the brass.
void paintLeafGlyph(Canvas canvas, Offset pc, double k) {
  final leaf = Path()
    ..moveTo(pc.dx, pc.dy - 9 * k)
    ..quadraticBezierTo(pc.dx + 6 * k, pc.dy, pc.dx, pc.dy + 9 * k)
    ..quadraticBezierTo(pc.dx - 6 * k, pc.dy, pc.dx, pc.dy - 9 * k);
  canvas.drawPath(leaf, Paint()..color = shopWoodDark.withValues(alpha: 0.75));
}

/// The back of the shop: the boarded wall in [wall]'s colours (top, bottom),
/// the window with the sky of the hour and [host] looking out, and the
/// lanterns' light on the wall.
void paintShopBack(
  Canvas canvas,
  ShopFrame f, {
  required DateTime now,
  required AppColors colors,
  required List<Color> wall,
  ForestFriend? host,
}) {
  final k = f.k, w = f.w, h = f.h;
  final inner = f.inner;
  final gold = colors.accent;

  // the back wall: boards, painted, worn
  final wallBox = Rect.fromLTRB(inner.left, inner.top, inner.right, f.counterY);
  canvas.drawRect(
    wallBox,
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: wall,
      ).createShader(wallBox),
  );
  final seam = Paint()
    ..strokeWidth = 1 * k
    ..color = Colors.black.withValues(alpha: 0.28);
  for (var x = wallBox.left + w * 0.07; x < wallBox.right; x += w * 0.07) {
    canvas.drawLine(Offset(x, wallBox.top), Offset(x, wallBox.bottom), seam);
  }

  // the window and the sky of the hour
  final win = f.window;
  final archR = win.width / 2;
  final arch = Path()
    ..moveTo(win.left, win.bottom)
    ..lineTo(win.left, win.top + archR)
    ..arcToPoint(
      Offset(win.right, win.top + archR),
      radius: Radius.circular(archR),
    )
    ..lineTo(win.right, win.bottom)
    ..close();
  final day = now.hour >= 6 && now.hour < 19;
  canvas.drawPath(
    arch,
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: day
            ? const [Color(0xFF8DB8D8), Color(0xFFE8D9A8)]
            : const [Color(0xFF14204A), Color(0xFF2C3A6A)],
      ).createShader(win),
  );
  final orb = Offset(win.center.dx + archR * 0.5, win.top + archR * 0.5);
  if (day) {
    canvas.drawCircle(
      orb,
      archR * 0.7,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFF3C4).withValues(alpha: 0.9),
            const Color(0xFFFFF3C4).withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: orb, radius: archR * 0.7)),
    );
    canvas.drawCircle(
      orb,
      archR * 0.2,
      Paint()..color = const Color(0xFFFFF1B8),
    );
  } else {
    final stars = math.Random(3);
    for (var j = 0; j < 9; j++) {
      canvas.drawCircle(
        Offset(
          win.left + win.width * stars.nextDouble(),
          win.top + win.height * 0.7 * stars.nextDouble() + archR * 0.2,
        ),
        0.9 * k,
        Paint()..color = Colors.white.withValues(alpha: 0.7),
      );
    }
    canvas.saveLayer(
      Rect.fromCircle(center: orb, radius: archR * 0.4),
      Paint(),
    );
    canvas.drawCircle(
      orb,
      archR * 0.22,
      Paint()..color = const Color(0xFFF4EBC8),
    );
    canvas.drawCircle(
      orb + Offset(archR * 0.1, -archR * 0.06),
      archR * 0.19,
      Paint()..blendMode = BlendMode.clear,
    );
    canvas.restore();
  }
  // distant treetops through the glass
  final trees = Path();
  for (var j = 0; j < 6; j++) {
    final x = win.left + win.width * (j + 0.5) / 6;
    trees.addOval(
      Rect.fromCenter(
        center: Offset(x, win.bottom - win.height * 0.08),
        width: win.width * 0.26,
        height: win.height * 0.28,
      ),
    );
  }
  canvas.save();
  canvas.clipPath(arch);
  canvas.drawPath(
    trees,
    Paint()..color = day ? const Color(0xFF4E7F4E) : const Color(0xFF1E2F2A),
  );
  canvas.restore();
  // the host, looking out of the window (the glass behind them, the frame
  // and the plants in front)
  if (host != null) {
    canvas.save();
    canvas.clipPath(arch);
    paintVedafolkHead(canvas, host, f.hostCentre, f.hostR, turn: -0.06);
    canvas.restore();
  }
  // frame and glazing bars
  canvas.drawPath(
    arch,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4 * k
      ..color = shopWoodLight,
  );
  final bar = Paint()
    ..strokeWidth = 1.6 * k
    ..color = shopWood;
  canvas.drawLine(
    Offset(win.center.dx, win.top),
    Offset(win.center.dx, win.bottom),
    bar,
  );
  canvas.drawLine(
    Offset(win.left, win.top + archR),
    Offset(win.right, win.top + archR),
    bar,
  );

  // the lanterns' light on the wall
  for (final c in f.lanterns) {
    final pool = Rect.fromCircle(
      center: c + Offset(0, h * 0.06),
      radius: w * 0.26,
    );
    canvas.drawOval(
      pool,
      Paint()
        ..shader = RadialGradient(
          colors: [gold.withValues(alpha: 0.22), gold.withValues(alpha: 0)],
        ).createShader(pool),
    );
  }
}

/// The front of the shop: the counter, the posts with their plaques, the
/// fascia with [name] on its plate, ivy, the lanterns and the hanging
/// baskets. [plaqueGlyph] is cut into the posts' plaques (a leaf by default).
void paintShopFront(
  Canvas canvas,
  ShopFrame f, {
  required AppColors colors,
  String? font,
  required String name,
  void Function(Canvas canvas, Offset centre, double k)? plaqueGlyph,
}) {
  final k = f.k, w = f.w, h = f.h;
  final gold = colors.accent;

  // the counter: a thick top and a panelled front
  final cy = f.counterY;
  final top = Rect.fromLTRB(f.postW * 0.5, cy, w - f.postW * 0.5, cy + 11 * k);
  paintBoard(canvas, top, k, seed: 11);
  canvas.drawLine(
    Offset(top.left, top.top + 0.6 * k),
    Offset(top.right, top.top + 0.6 * k),
    Paint()
      ..strokeWidth = 1.2 * k
      ..color = gold.withValues(alpha: 0.35),
  );
  final front = Rect.fromLTRB(f.postW * 0.7, top.bottom, w - f.postW * 0.7, h);
  canvas.drawRect(
    front,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [shopWoodDark, Color(0xFF2E1D10)],
      ).createShader(front),
  );
  // its sunk panels
  final panelW = front.width / 3;
  for (var j = 0; j < 3; j++) {
    final p = Rect.fromLTWH(
      front.left + panelW * j + 6 * k,
      front.top + 5 * k,
      panelW - 12 * k,
      front.height - 10 * k,
    );
    if (p.height <= 4 * k) break;
    final rr = RRect.fromRectAndRadius(p, Radius.circular(3 * k));
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2 * k
        ..color = Colors.black.withValues(alpha: 0.35),
    );
    canvas.drawRRect(
      rr.shift(Offset(0.8 * k, 0.8 * k)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8 * k
        ..color = shopWoodLight.withValues(alpha: 0.35),
    );
  }

  // the posts
  for (final left in const [true, false]) {
    final r = left
        ? Rect.fromLTRB(0, f.fasciaH, f.postW, h)
        : Rect.fromLTRB(w - f.postW, f.fasciaH, w, h);
    paintBoard(canvas, r, k, seed: left ? 21 : 22, vertical: true);
    // flutes
    for (final f in const [0.3, 0.5, 0.7]) {
      canvas.drawLine(
        Offset(r.left + r.width * f, r.top + 14 * k),
        Offset(r.left + r.width * f, r.bottom - 14 * k),
        Paint()
          ..strokeWidth = 1.4 * k
          ..color = Colors.black.withValues(alpha: 0.28),
      );
    }
    // a brass plaque, with the shop's glyph
    final pc = Offset(r.center.dx, h * 0.5);
    final plaque = RRect.fromRectAndRadius(
      Rect.fromCenter(center: pc, width: r.width * 0.62, height: 30 * k),
      Radius.circular(3 * k),
    );
    canvas.drawRRect(plaque, Paint()..color = gold);
    canvas.drawRRect(
      plaque,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1 * k
        ..color = shopWoodDark,
    );
    (plaqueGlyph ?? paintLeafGlyph)(canvas, pc, k);
  }

  // the fascia, with its nameplate
  final fascia = Rect.fromLTRB(0, 0, w, f.fasciaH);
  paintBoard(canvas, fascia, k, seed: 31);
  canvas.drawLine(
    Offset(0, fascia.bottom - 1 * k),
    Offset(w, fascia.bottom - 1 * k),
    Paint()
      ..strokeWidth = 2 * k
      ..color = gold.withValues(alpha: 0.6),
  );
  final plate = RRect.fromRectAndRadius(
    Rect.fromCenter(
      center: fascia.center,
      width: w * 0.5,
      height: fascia.height * 0.62,
    ),
    Radius.circular(4 * k),
  );
  canvas.drawRRect(plate, Paint()..color = shopWoodDark);
  canvas.drawRRect(
    plate,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2 * k
      ..color = gold,
  );
  final title = TextPainter(
    text: TextSpan(
      text: name,
      style: TextStyle(
        fontFamily: font,
        fontSize: 13 * k,
        letterSpacing: 3.2 * k,
        color: colors.accentText,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  title.paint(
    canvas,
    fascia.center - Offset(title.width / 2, title.height / 2),
  );
  // a sprig of three leaves either side of the nameplate
  for (final s in const [-1.0, 1.0]) {
    final c = fascia.center + Offset(s * w * 0.30, 0);
    final leaf = Paint()..color = gold.withValues(alpha: 0.85);
    for (final a in const [-0.55, 0.0, 0.55]) {
      final ang = (s > 0 ? 0.0 : math.pi) + a;
      final d = Offset(math.cos(ang), math.sin(ang));
      final tip = c + d * 13 * k;
      final mid = Offset.lerp(c, tip, 0.5)!;
      final nrm = Offset(-d.dy, d.dx) * 3.6 * k;
      canvas.drawPath(
        Path()
          ..moveTo(c.dx, c.dy)
          ..quadraticBezierTo(mid.dx + nrm.dx, mid.dy + nrm.dy, tip.dx, tip.dy)
          ..quadraticBezierTo(mid.dx - nrm.dx, mid.dy - nrm.dy, c.dx, c.dy),
        leaf,
      );
    }
    canvas.drawCircle(c, 2 * k, leaf);
  }

  // ivy along the underside of the fascia
  final ivy = math.Random(41);
  for (var j = 0; j < 26; j++) {
    final x = w * (j + ivy.nextDouble()) / 26;
    final len = (6 + ivy.nextDouble() * (j % 4 == 0 ? 26 : 10)) * k;
    final c = Offset(x, f.fasciaH + len * 0.5);
    canvas.drawLine(
      Offset(x, f.fasciaH),
      Offset(x, f.fasciaH + len),
      Paint()
        ..strokeWidth = 0.8 * k
        ..color = shopGreens[0],
    );
    for (var q = 0; q < 3; q++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: c + Offset((q - 1) * 3 * k, (q - 1) * len * 0.35),
          width: 6 * k,
          height: 4.5 * k,
        ),
        Paint()..color = shopGreens[(j + q) % 3],
      );
    }
  }

  // the lanterns, hanging from the fascia
  for (final c in f.lanterns) {
    canvas.drawLine(
      Offset(c.dx, f.fasciaH),
      c - Offset(0, 14 * k),
      Paint()
        ..strokeWidth = 1 * k
        ..color = shopWoodDark,
    );
    final glow = Rect.fromCircle(center: c, radius: 26 * k);
    canvas.drawOval(
      glow,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFE3A0).withValues(alpha: 0.55),
            const Color(0xFFFFE3A0).withValues(alpha: 0),
          ],
        ).createShader(glow),
    );
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: c, width: 14 * k, height: 18 * k),
      Radius.circular(4 * k),
    );
    canvas.drawRRect(body, Paint()..color = const Color(0xFFFFE7A8));
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6 * k
        ..color = gold,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: c - Offset(0, 11 * k),
        width: 16 * k,
        height: 3 * k,
      ),
      Paint()..color = gold,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: c + Offset(0, 11 * k),
        width: 16 * k,
        height: 3 * k,
      ),
      Paint()..color = gold,
    );
  }

  // hanging baskets on the posts, trailing ivy and flowers down them
  for (final left in const [true, false]) {
    final s = left ? 1.0 : -1.0;
    final c = Offset(left ? f.postW + 10 * k : w - f.postW - 10 * k, h * 0.205);
    canvas.drawLine(
      Offset(c.dx, f.fasciaH),
      c - Offset(0, 8 * k),
      Paint()
        ..strokeWidth = 0.9 * k
        ..color = shopWoodDark,
    );
    final rnd = math.Random(left ? 51 : 52);
    // trailing strands
    for (var j = 0; j < 4; j++) {
      final len = h * (0.16 + rnd.nextDouble() * 0.16);
      final x0 = c.dx + (j - 1.5) * 5 * k;
      final path = Path()..moveTo(x0, c.dy);
      final pts = <Offset>[];
      for (var q = 0; q <= 10; q++) {
        final u = q / 10;
        final p = Offset(
          x0 - s * u * 6 * k + 3 * k * math.sin(u * 7 + j),
          c.dy + u * len,
        );
        pts.add(p);
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9 * k
          ..color = shopGreens[0],
      );
      for (var q = 1; q < pts.length; q++) {
        final p = pts[q];
        canvas.drawOval(
          Rect.fromCenter(
            center: p + Offset((q.isEven ? 3 : -3) * k, 0),
            width: 6.5 * k,
            height: 4.5 * k,
          ),
          Paint()..color = shopGreens[(q + j) % 3],
        );
        if ((q + j) % 4 == 0) {
          final fc = p + Offset((q.isEven ? -3 : 3) * k, 1 * k);
          for (var pe = 0; pe < 5; pe++) {
            final a = pe * math.pi * 2 / 5;
            canvas.drawCircle(
              fc + Offset(math.cos(a), math.sin(a)) * 2.2 * k,
              1.8 * k,
              Paint()
                ..color = j.isEven
                    ? const Color(0xFFE77FA0)
                    : const Color(0xFFF7F2E6),
            );
          }
          canvas.drawCircle(
            fc,
            1.1 * k,
            Paint()..color = const Color(0xFFF2C14E),
          );
        }
      }
    }
    // the basket
    final basket = Path()
      ..moveTo(c.dx - 17 * k, c.dy - 4 * k)
      ..quadraticBezierTo(c.dx, c.dy + 22 * k, c.dx + 17 * k, c.dy - 4 * k)
      ..close();
    canvas.drawPath(basket, Paint()..color = const Color(0xFF8A6238));
    for (var q = 0; q < 4; q++) {
      canvas.drawLine(
        Offset(c.dx - 15 * k + q * 2 * k, c.dy + q * 3 * k - 2 * k),
        Offset(c.dx + 15 * k - q * 2 * k, c.dy + q * 3 * k - 2 * k),
        Paint()
          ..strokeWidth = 0.8 * k
          ..color = shopWoodDark.withValues(alpha: 0.7),
      );
    }
    // the leaves and flowers on top
    for (var j = 0; j < 9; j++) {
      final a = -math.pi * (0.1 + 0.8 * j / 8);
      final p = c + Offset(math.cos(a) * 14 * k, math.sin(a) * 9 * k - 3 * k);
      canvas.drawOval(
        Rect.fromCenter(center: p, width: 9 * k, height: 6 * k),
        Paint()..color = shopGreens[j % 3],
      );
    }
    for (var j = 0; j < 3; j++) {
      final fc = c + Offset((j - 1) * 9 * k, -9 * k - (j == 1 ? 3 * k : 0));
      for (var pe = 0; pe < 5; pe++) {
        final a = pe * math.pi * 2 / 5;
        canvas.drawCircle(
          fc + Offset(math.cos(a), math.sin(a)) * 3 * k,
          2.6 * k,
          Paint()..color = const Color(0xFFE77FA0),
        );
      }
      canvas.drawCircle(fc, 1.6 * k, Paint()..color = const Color(0xFFF2C14E));
    }
  }
}

/// Dust and pollen drifting in the lamplight.
void paintShopMotes(Canvas canvas, ShopFrame f, double t, AppColors colors) {
  final k = f.k, inner = f.inner;
  final r = math.Random(77);
  for (var j = 0; j < 14; j++) {
    final home = Offset(
      inner.left + inner.width * r.nextDouble(),
      inner.top + inner.height * r.nextDouble(),
    );
    final a = (t * 2 + r.nextDouble()) * math.pi * 2;
    final p = home + Offset(math.sin(a) * 8 * k, math.cos(a * 2) * 5 * k);
    final glow = 0.4 + 0.6 * (0.5 + 0.5 * math.sin(a * 3));
    canvas.drawCircle(
      p,
      1.1 * k,
      Paint()..color = colors.accentText.withValues(alpha: 0.6 * glow),
    );
  }
}

/// Little fairies flitting between the plants, each trailing light.
void paintShopFairies(Canvas canvas, ShopFrame f, double t) =>
    paintFairiesIn(canvas, f.inner, f.k, t);

/// Little fairies flitting about [inner], each trailing light; [k] is the
/// size factor. Any centrepiece can have them (Today's clock does).
void paintFairiesIn(Canvas canvas, Rect inner, double k, double t) {
  const tints = [
    Color(0xFFF7C6DA),
    Color(0xFFC9E8C0),
    Color(0xFFD9CCF5),
    Color(0xFFFFE6A8),
  ];
  // whole numbers of loops in one turn of [t], so the paths close
  const loops = [(1, 2, 0.1), (2, 3, 0.45), (1, 3, 0.7), (3, 2, 0.25)];
  Offset at(int j, double tt) {
    final (mx, my, ph) = loops[j];
    final cx = inner.left + inner.width * (0.2 + 0.6 * ((j * 0.37) % 1));
    final cy = inner.top + inner.height * (0.25 + 0.5 * ((j * 0.61) % 1));
    return Offset(
      cx + inner.width * 0.3 * math.sin((tt * mx + ph) * math.pi * 2),
      cy + inner.height * 0.18 * math.sin((tt * my + ph * 2) * math.pi * 2),
    );
  }

  for (var j = 0; j < loops.length; j++) {
    final tint = tints[j];
    // the trail of light behind
    for (var q = 1; q <= 10; q++) {
      final p = at(j, t - q * 0.0025);
      canvas.drawCircle(
        p,
        (1.6 - q * 0.1) * k,
        Paint()..color = tint.withValues(alpha: 0.5 * (1 - q / 11)),
      );
    }
    final p = at(j, t);
    final ahead = at(j, t + 0.002);
    final facing = ahead.dx >= p.dx ? 1.0 : -1.0;
    canvas.save();
    canvas.translate(p.dx, p.dy);
    canvas.scale(1.4);
    canvas.translate(-p.dx, -p.dy);
    // the glow
    final glow = Rect.fromCircle(center: p, radius: 14 * k);
    canvas.drawOval(
      glow,
      Paint()
        ..shader = RadialGradient(
          colors: [tint.withValues(alpha: 0.55), tint.withValues(alpha: 0)],
        ).createShader(glow),
    );
    // wings, beating
    final beat = 0.35 + 0.65 * math.sin(t * 160 * math.pi + j).abs();
    final wing = Paint()..color = Colors.white.withValues(alpha: 0.55);
    for (final s in const [-1.0, 1.0]) {
      for (final (dy, ww, hh) in const [(-1.5, 6.0, 4.0), (1.5, 4.5, 3.0)]) {
        canvas.save();
        canvas.translate(p.dx + s * 1.5 * k, p.dy + dy * k);
        canvas.rotate(s * (dy < 0 ? -0.5 : 0.4));
        canvas.scale(1, beat);
        canvas.drawOval(
          Rect.fromLTWH(s > 0 ? 0 : -ww * k, -hh * k / 2, ww * k, hh * k),
          wing,
        );
        canvas.restore();
      }
    }
    // the fairy herself: a dress of her colour, a head, a spark of light
    final dress = Path()
      ..moveTo(p.dx, p.dy - 2.5 * k)
      ..lineTo(p.dx + 2.6 * k, p.dy + 4 * k)
      ..lineTo(p.dx - 2.6 * k, p.dy + 4 * k)
      ..close();
    canvas.drawPath(
      dress,
      Paint()..color = Color.lerp(tint, Colors.white, 0.2)!,
    );
    canvas.drawCircle(
      p - Offset(0, 4 * k),
      1.8 * k,
      Paint()..color = const Color(0xFFFFF3E0),
    );
    canvas.drawCircle(
      p + Offset(facing * 3.5 * k, -1 * k),
      1.0 * k,
      Paint()..color = Colors.white,
    );
    canvas.restore();
  }
}

// ======================================================================
// plants

enum PlantKind {
  broad,
  monstera,
  fern,
  bushy,
  spiky,
  trailing,
  flowering,
  cactus,
  succulent,
}

/// A plant's kind, read from its name, so it always looks like itself.
PlantKind plantKindFor(String name) {
  final n = name.toLowerCase();
  bool has(List<String> words) => words.any(n.contains);
  if (has(['cactus', 'cacti'])) return PlantKind.cactus;
  if (has(['succulent', 'jade', 'echeveria', 'haworthia'])) {
    return PlantKind.succulent;
  }
  if (has(['aloe', 'snake', 'sansevieria', 'spider', 'lemongrass', 'grass'])) {
    return PlantKind.spiky;
  }
  if (has(['money', 'pothos', 'ivy', 'philodendron', 'creeper', 'vine'])) {
    return PlantKind.trailing;
  }
  if (has(['fern', 'curry'])) return PlantKind.fern;
  if (has(['monstera', 'rubber', 'fig', 'banana', 'peace lily'])) {
    return PlantKind.monstera;
  }
  if (has([
    'rose',
    'hibiscus',
    'jasmine',
    'mogra',
    'marigold',
    'genda',
    'orchid',
    'lily',
    'geranium',
    'flower',
    'bougainvillea',
    'chrysanth',
    'periwinkle',
    'daisy',
    'tulip',
    'lavender',
  ])) {
    return PlantKind.flowering;
  }
  if (has([
    'tulsi',
    'basil',
    'mint',
    'pudina',
    'coriander',
    'dhania',
    'oregano',
    'thyme',
    'rosemary',
    'parsley',
    'methi',
    'herb',
  ])) {
    return PlantKind.bushy;
  }
  return PlantKind.broad;
}

/// The colour of a plant's flowers, read from its name.
Color flowerFor(String name, int seed) {
  final n = name.toLowerCase();
  if (n.contains('marigold') || n.contains('genda')) {
    return const Color(0xFFF0A030);
  }
  if (n.contains('jasmine') || n.contains('mogra') || n.contains('lily')) {
    return const Color(0xFFF7F2E6);
  }
  if (n.contains('hibiscus')) return const Color(0xFFD8323C);
  if (n.contains('lavender') || n.contains('periwinkle')) {
    return const Color(0xFFA889D6);
  }
  const choices = [
    Color(0xFFE77FA0),
    Color(0xFFD8323C),
    Color(0xFFF3B6C8),
    Color(0xFFB97AD9),
    Color(0xFFF2C14E),
  ];
  return choices[seed % choices.length];
}

int stableSeed(String s) =>
    s.codeUnits.fold<int>(7, (a, c) => (a * 31 + c) & 0x7fffffff);

/// Greens for leaves: dark, mid, light.
const shopGreens = [Color(0xFF2E6A3A), Color(0xFF3F8A4A), Color(0xFF6CB466)];

/// Paints one plant's foliage growing up from [base] (the middle of its pot's
/// rim), [size] tall at most. [t] sways it; [lit] lights it gold.
class PlantArt {
  PlantArt({
    required this.kind,
    required this.seed,
    required this.size,
    required this.k,
    this.t = 0,
    this.lit = false,
    this.gold = const Color(0xFFD9B863),
    this.flower = const Color(0xFFE77FA0),
  });

  final PlantKind kind;
  final int seed;
  final double size;
  final double k;
  final double t;
  final bool lit;
  final Color gold;
  final Color flower;

  Color _green(int j) {
    final c = shopGreens[j % 3];
    return lit ? Color.lerp(c, gold, 0.5)! : c;
  }

  double _sway(int j) =>
      0.05 * math.sin((t * 4 + j * 0.17 + seed % 7 * 0.13) * math.pi * 2);

  Path _blade(Offset start, double ang, double len, double fat) {
    final tip = start + Offset(math.cos(ang), math.sin(ang)) * len;
    final mid = Offset.lerp(start, tip, 0.5)!;
    final nrm = Offset(-math.sin(ang), math.cos(ang)) * (len * fat);
    return Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(mid.dx + nrm.dx, mid.dy + nrm.dy, tip.dx, tip.dy)
      ..quadraticBezierTo(mid.dx - nrm.dx, mid.dy - nrm.dy, start.dx, start.dy)
      ..close();
  }

  void _vein(Canvas canvas, Offset a, Offset b) {
    canvas.drawLine(
      a,
      b,
      Paint()
        ..strokeWidth = 0.8 * k
        ..color = Colors.black.withValues(alpha: 0.22),
    );
  }

  void _leaf(
    Canvas canvas,
    Offset start,
    double ang,
    double len,
    double fat,
    int j,
  ) {
    canvas.drawPath(_blade(start, ang, len, fat), Paint()..color = _green(j));
    _vein(
      canvas,
      start,
      start + Offset(math.cos(ang), math.sin(ang)) * len * 0.85,
    );
  }

  /// A rounded leaf (a heart or an oval) centred at [c], pointing along
  /// [ang].
  void _roundLeaf(Canvas canvas, Offset c, double ang, double r, int j) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(ang + math.pi / 2);
    final p = Path()
      ..moveTo(0, r)
      ..cubicTo(r * 1.3, r * 0.2, r * 0.7, -r * 1.1, 0, -r * 0.55)
      ..cubicTo(-r * 0.7, -r * 1.1, -r * 1.3, r * 0.2, 0, r)
      ..close();
    canvas.drawPath(p, Paint()..color = _green(j));
    canvas.drawLine(
      Offset(0, r * 0.8),
      Offset(0, -r * 0.4),
      Paint()
        ..strokeWidth = 0.7 * k
        ..color = Colors.black.withValues(alpha: 0.2),
    );
    canvas.restore();
  }

  void _blossom(Canvas canvas, Offset c, double r) {
    final petal = Paint()..color = flower;
    for (var j = 0; j < 5; j++) {
      final a = j * math.pi * 2 / 5 + seed % 5 * 0.3;
      canvas.drawCircle(
        c + Offset(math.cos(a), math.sin(a)) * r * 0.62,
        r * 0.55,
        petal,
      );
    }
    canvas.drawCircle(c, r * 0.32, Paint()..color = const Color(0xFFF2C14E));
  }

  void paint(Canvas canvas, Offset base) {
    final r = math.Random(seed);
    if (lit) {
      final glow = Rect.fromCenter(
        center: base - Offset(0, size * 0.45),
        width: size * 1.6,
        height: size * 1.4,
      );
      canvas.drawOval(
        glow,
        Paint()
          ..shader = RadialGradient(
            colors: [gold.withValues(alpha: 0.30), gold.withValues(alpha: 0)],
          ).createShader(glow),
      );
    }
    switch (kind) {
      case PlantKind.broad:
        final n = 5 + r.nextInt(3);
        for (var j = 0; j < n; j++) {
          final f = j / (n - 1);
          final ang = -math.pi / 2 + (f - 0.5) * 1.9 + _sway(j);
          final len =
              size *
              (0.6 + 0.4 * math.sin(f * math.pi)) *
              (0.85 + r.nextDouble() * 0.25);
          _leaf(
            canvas,
            base + Offset((f - 0.5) * 12 * k, 0),
            ang,
            len,
            0.22,
            j,
          );
        }
      case PlantKind.monstera:
        final n = 4 + r.nextInt(2);
        for (var j = 0; j < n; j++) {
          final f = j / (n - 1);
          final ang = -math.pi / 2 + (f - 0.5) * 1.6 + _sway(j);
          final len = size * (0.55 + 0.35 * math.sin(f * math.pi));
          final end = base + Offset(math.cos(ang), math.sin(ang)) * len;
          canvas.drawLine(
            base,
            end,
            Paint()
              ..strokeWidth = 1.6 * k
              ..color = _green(0),
          );
          final lr = size * 0.24;
          _roundLeaf(canvas, end, ang, lr, j);
          // the monstera's splits
          for (final s in const [-1.0, 1.0]) {
            for (var q = 0; q < 2; q++) {
              final a = ang + s * (0.9 + q * 0.5);
              canvas.drawLine(
                end + Offset(math.cos(a), math.sin(a)) * lr * 0.35,
                end + Offset(math.cos(a), math.sin(a)) * lr * 0.95,
                Paint()
                  ..strokeWidth = 1.4 * k
                  ..color = Colors.black.withValues(alpha: 0.35),
              );
            }
          }
        }
      case PlantKind.fern:
        final n = 7;
        for (var j = 0; j < n; j++) {
          final f = j / (n - 1);
          final ang = -math.pi / 2 + (f - 0.5) * 2.6 + _sway(j);
          final len = size * (0.65 + 0.35 * math.sin(f * math.pi));
          final droop = (f - 0.5) * len * 0.5;
          final tip =
              base +
              Offset(
                math.cos(ang) * len,
                math.sin(ang) * len + droop.abs() * 0.6,
              );
          final ctrl =
              base +
              Offset(math.cos(ang) * len * 0.5, math.sin(ang) * len * 0.75);
          final rib = Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.1 * k
            ..color = _green(0);
          canvas.drawPath(
            Path()
              ..moveTo(base.dx, base.dy)
              ..quadraticBezierTo(ctrl.dx, ctrl.dy, tip.dx, tip.dy),
            rib,
          );
          for (var q = 1; q < 9; q++) {
            final u = q / 9;
            final a = Offset.lerp(
              Offset.lerp(base, ctrl, u)!,
              Offset.lerp(ctrl, tip, u)!,
              u,
            )!;
            final d =
                (Offset.lerp(ctrl, tip, u)! - Offset.lerp(base, ctrl, u)!);
            final l = d.distance == 0 ? 1.0 : d.distance;
            final along = math.atan2(d.dy, d.dx);
            final pl = size * 0.11 * (1 - u * 0.7);
            for (final s in const [-1.0, 1.0]) {
              canvas.drawPath(
                _blade(a, along + s * 1.0, pl, 0.3),
                Paint()..color = _green(1 + (q % 2)),
              );
            }
            if (l == 0) break;
          }
        }
      case PlantKind.bushy:
        final stems = 7;
        for (var j = 0; j < stems; j++) {
          final f = j / (stems - 1);
          final ang = -math.pi / 2 + (f - 0.5) * 1.7 + _sway(j);
          final len =
              size *
              (0.62 + 0.38 * math.sin(f * math.pi)) *
              (0.9 + r.nextDouble() * 0.15);
          final start = base + Offset((f - 0.5) * 10 * k, 0);
          final dir = Offset(math.cos(ang), math.sin(ang));
          final tip = start + dir * len;
          canvas.drawLine(
            start,
            tip,
            Paint()
              ..strokeWidth = 1.1 * k
              ..color = _green(0),
          );
          // pairs of leaves up the stem, smaller towards the tip
          for (var q = 1; q <= 4; q++) {
            final u = q / 4.6;
            final at = Offset.lerp(start, tip, u)!;
            final lr = size * 0.10 * (1.15 - u * 0.5);
            for (final side in const [-1.0, 1.0]) {
              _roundLeaf(
                canvas,
                at + Offset(-dir.dy, dir.dx) * side * lr * 0.8,
                ang + side * 1.0,
                lr,
                j + q,
              );
            }
          }
          _roundLeaf(canvas, tip, ang, size * 0.07, j);
          if (seed % 3 == 0 && j.isOdd) {
            // a purple flower spike, as tulsi has
            for (var q = 0; q < 4; q++) {
              canvas.drawCircle(
                tip + dir * (q * 3.0 * k + 2 * k),
                1.5 * k,
                Paint()..color = const Color(0xFF8A5A9A),
              );
            }
          }
        }
      case PlantKind.spiky:
        final n = 7;
        for (var j = 0; j < n; j++) {
          final f = j / (n - 1);
          final ang = -math.pi / 2 + (f - 0.5) * 1.3 + _sway(j) * 0.5;
          final len = size * (0.65 + 0.35 * math.sin(f * math.pi));
          _leaf(
            canvas,
            base + Offset((f - 0.5) * 16 * k, 0),
            ang,
            len,
            0.11,
            j,
          );
          // pale flecks along the blade
          final tip = base + Offset(math.cos(ang), math.sin(ang)) * len;
          for (var q = 1; q < 4; q++) {
            canvas.drawCircle(
              Offset.lerp(base, tip, q / 4.5)!,
              0.9 * k,
              Paint()..color = Colors.white.withValues(alpha: 0.25),
            );
          }
        }
      case PlantKind.trailing:
        for (var j = 0; j < 4; j++) {
          final a = -math.pi / 2 + (j - 1.5) * 0.5 + _sway(j);
          _roundLeaf(
            canvas,
            base + Offset(math.cos(a), math.sin(a)) * size * 0.32,
            a,
            size * 0.14,
            j,
          );
        }
        // vines spilling over the rim and down
        for (final s in const [-1.0, 1.0]) {
          final vine = Path()..moveTo(base.dx + s * 10 * k, base.dy);
          final pts = <Offset>[];
          for (var q = 0; q <= 8; q++) {
            final u = q / 8;
            final p =
                base +
                Offset(
                  s * (14 * k + u * size * 0.25) +
                      3 * k * math.sin((t * 4 + u) * math.pi * 2) * u,
                  u * size * 0.5,
                );
            pts.add(p);
            vine.lineTo(p.dx, p.dy);
          }
          canvas.drawPath(
            vine,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.0 * k
              ..color = _green(0),
          );
          for (var q = 1; q < pts.length; q += 2) {
            _roundLeaf(
              canvas,
              pts[q] + Offset(s * 3 * k, 0),
              s > 0 ? 0.3 : math.pi - 0.3,
              size * 0.09,
              q,
            );
          }
        }
      case PlantKind.flowering:
        final n = 7;
        for (var j = 0; j < n; j++) {
          final f = j / (n - 1);
          final ang = -math.pi / 2 + (f - 0.5) * 2.0 + _sway(j);
          _leaf(canvas, base, ang, size * 0.55, 0.3, j);
        }
        for (var j = 0; j < 4; j++) {
          final a = -math.pi / 2 + (j - 1.5) * 0.45;
          _blossom(
            canvas,
            base + Offset(math.cos(a) * size * 0.55, math.sin(a) * size * 0.7),
            size * 0.13,
          );
        }
      case PlantKind.cactus:
        final body = RRect.fromRectAndRadius(
          Rect.fromLTRB(
            base.dx - size * 0.13,
            base.dy - size * 0.8,
            base.dx + size * 0.13,
            base.dy + 2,
          ),
          Radius.circular(size * 0.13),
        );
        canvas.drawRRect(body, Paint()..color = _green(1));
        for (final s in const [-1.0, 1.0]) {
          final arm = Path()
            ..moveTo(base.dx + s * size * 0.1, base.dy - size * 0.35)
            ..lineTo(base.dx + s * size * 0.28, base.dy - size * 0.35)
            ..lineTo(
              base.dx + s * size * 0.28,
              base.dy - size * (s > 0 ? 0.62 : 0.55),
            );
          canvas.drawPath(
            arm,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = size * 0.11
              ..strokeCap = StrokeCap.round
              ..strokeJoin = StrokeJoin.round
              ..color = _green(1),
          );
        }
        for (final f in const [-0.06, 0.0, 0.06]) {
          canvas.drawLine(
            Offset(base.dx + size * f, base.dy - size * 0.75),
            Offset(base.dx + size * f, base.dy - 2),
            Paint()
              ..strokeWidth = 0.7 * k
              ..color = Colors.black.withValues(alpha: 0.25),
          );
        }
        _blossom(canvas, Offset(base.dx, base.dy - size * 0.82), size * 0.08);
      case PlantKind.succulent:
        for (var ring = 0; ring < 3; ring++) {
          final n = 7 - ring;
          for (var j = 0; j < n; j++) {
            final f = n == 1 ? 0.5 : j / (n - 1);
            final ang = -math.pi / 2 + (f - 0.5) * (2.6 - ring * 0.7);
            _leaf(
              canvas,
              base + Offset(0, -ring * 3 * k),
              ang,
              size * (0.42 - ring * 0.1),
              0.28,
              j + ring,
            );
          }
        }
    }
  }
}

/// The kinds of pot in the shed.
enum PotStyle {
  /// Plain terracotta.
  terracotta,

  /// Terracotta painted with a band of white dots and a zigzag, as village
  /// pots are.
  painted,

  /// A glazed pot in a deep colour, with a pale band round it.
  glazed,

  /// White with blue flowers, after Jaipur's blue pottery.
  bluePottery,

  /// A round brass bowl on a little foot, polished.
  brass,

  /// A woven basket.
  basket,
}

/// A pot for a plant, the same every time for the same plant.
PotStyle potStyleFor(int seed) =>
    PotStyle.values[seed % PotStyle.values.length];

const _glazes = [
  Color(0xFF2F4F8F), // indigo
  Color(0xFF2E7A78), // teal
  Color(0xFF8FB8A0), // celadon
  Color(0xFFC9962E), // mustard
  Color(0xFF7A3A52), // plum
];

/// A pot standing on [base] (the middle of its foot), [h] tall, [wTop] wide at
/// the rim, in [style]. [rimLight] edges the rim (a plant tended today).
void paintPot(
  Canvas canvas,
  Offset base,
  double h,
  double wTop,
  double k, {
  PotStyle style = PotStyle.terracotta,
  int seed = 0,
  Color? rimLight,
}) {
  final top = base.dy - h;
  final box = Rect.fromLTRB(
    base.dx - wTop / 2,
    top,
    base.dx + wTop / 2,
    base.dy,
  );
  // its shadow on the shelf, under it
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(base.dx, base.dy + 1.5 * k),
      width: wTop * 0.95,
      height: 4 * k,
    ),
    Paint()..color = Colors.black.withValues(alpha: 0.3),
  );

  // the body's shape
  final Path body;
  switch (style) {
    case PotStyle.brass:
      // a round bowl on a short foot
      body = Path()
        ..moveTo(base.dx - wTop / 2, top + h * 0.12)
        ..cubicTo(
          base.dx - wTop * 0.62,
          top + h * 0.75,
          base.dx - wTop * 0.25,
          base.dy - h * 0.12,
          base.dx - wTop * 0.18,
          base.dy - h * 0.12,
        )
        ..lineTo(base.dx - wTop * 0.22, base.dy)
        ..lineTo(base.dx + wTop * 0.22, base.dy)
        ..lineTo(base.dx + wTop * 0.18, base.dy - h * 0.12)
        ..cubicTo(
          base.dx + wTop * 0.25,
          base.dy - h * 0.12,
          base.dx + wTop * 0.62,
          top + h * 0.75,
          base.dx + wTop / 2,
          top + h * 0.12,
        )
        ..close();
    case PotStyle.bluePottery:
      // straighter, a little rounded at the foot
      body = Path()
        ..moveTo(base.dx - wTop * 0.46, top)
        ..lineTo(base.dx + wTop * 0.46, top)
        ..quadraticBezierTo(
          base.dx + wTop * 0.5,
          base.dy,
          base.dx + wTop * 0.3,
          base.dy,
        )
        ..lineTo(base.dx - wTop * 0.3, base.dy)
        ..quadraticBezierTo(
          base.dx - wTop * 0.5,
          base.dy,
          base.dx - wTop * 0.46,
          top,
        )
        ..close();
    default:
      final wBot = wTop * (style == PotStyle.basket ? 0.82 : 0.74);
      body = Path()
        ..moveTo(base.dx - wTop / 2, top)
        ..lineTo(base.dx + wTop / 2, top)
        ..lineTo(base.dx + wBot / 2, base.dy)
        ..lineTo(base.dx - wBot / 2, base.dy)
        ..close();
  }

  // its colour, lit from the left
  List<Color> shades(Color c) => [
    Color.lerp(c, Colors.black, 0.25)!,
    Color.lerp(c, Colors.white, 0.22)!,
    c,
    Color.lerp(c, Colors.black, 0.4)!,
  ];
  final List<Color> fill;
  switch (style) {
    case PotStyle.terracotta:
    case PotStyle.painted:
      fill = const [
        Color(0xFF8E4A2C),
        Color(0xFFC0714A),
        Color(0xFF9A5233),
        Color(0xFF6E361F),
      ];
    case PotStyle.glazed:
      fill = shades(_glazes[(seed ~/ 7) % _glazes.length]);
    case PotStyle.bluePottery:
      fill = const [
        Color(0xFFD9D6CC),
        Color(0xFFFBF8F0),
        Color(0xFFEDE8DC),
        Color(0xFFBDB8AA),
      ];
    case PotStyle.brass:
      fill = const [
        Color(0xFF8A6A22),
        Color(0xFFF2D98A),
        Color(0xFFC9A048),
        Color(0xFF6E5218),
      ];
    case PotStyle.basket:
      fill = const [
        Color(0xFF8A6238),
        Color(0xFFC49A62),
        Color(0xFFA67C48),
        Color(0xFF6E4A26),
      ];
  }
  canvas.drawPath(
    body,
    Paint()
      ..shader = LinearGradient(
        colors: fill,
        stops: const [0.0, 0.35, 0.7, 1.0],
      ).createShader(box),
  );

  // its decoration
  canvas.save();
  canvas.clipPath(body);
  switch (style) {
    case PotStyle.painted:
      final y = top + h * 0.5;
      final white = Paint()..color = const Color(0xFFF3E6D0);
      final zig = Path()..moveTo(box.left, y);
      for (var j = 0; j <= 10; j++) {
        zig.lineTo(box.left + box.width * j / 10, y + (j.isEven ? -3 : 3) * k);
      }
      canvas.drawPath(
        zig,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2 * k
          ..color = const Color(0xFFF3E6D0),
      );
      for (var j = 0; j < 7; j++) {
        canvas.drawCircle(
          Offset(box.left + box.width * (j + 0.5) / 7, y + h * 0.22),
          1.3 * k,
          white,
        );
      }
    case PotStyle.glazed:
      canvas.drawRect(
        Rect.fromLTRB(box.left, top + h * 0.42, box.right, top + h * 0.56),
        Paint()..color = Colors.white.withValues(alpha: 0.28),
      );
      // the glaze's shine
      canvas.drawLine(
        Offset(box.left + box.width * 0.28, top + h * 0.2),
        Offset(box.left + box.width * 0.32, base.dy - h * 0.15),
        Paint()
          ..strokeWidth = 2 * k
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withValues(alpha: 0.35),
      );
    case PotStyle.bluePottery:
      const blue = Color(0xFF2B4F9A);
      final c = Offset(base.dx, top + h * 0.55);
      // a flower and two leaves, in blue
      for (var j = 0; j < 6; j++) {
        final a = j * math.pi / 3;
        canvas.drawOval(
          Rect.fromCenter(
            center: c + Offset(math.cos(a), math.sin(a)) * 3.6 * k,
            width: 4 * k,
            height: 4 * k,
          ),
          Paint()..color = blue,
        );
      }
      canvas.drawCircle(c, 1.6 * k, Paint()..color = const Color(0xFF6FA8D8));
      for (final sgn in const [-1.0, 1.0]) {
        canvas.drawOval(
          Rect.fromCenter(
            center: c + Offset(sgn * 10 * k, 1 * k),
            width: 7 * k,
            height: 3 * k,
          ),
          Paint()..color = const Color(0xFF3F78B8),
        );
      }
      final band = Paint()
        ..strokeWidth = 1.2 * k
        ..color = blue;
      canvas.drawLine(
        Offset(box.left, top + h * 0.2),
        Offset(box.right, top + h * 0.2),
        band,
      );
      canvas.drawLine(
        Offset(box.left, base.dy - h * 0.12),
        Offset(box.right, base.dy - h * 0.12),
        band,
      );
    case PotStyle.brass:
      canvas.drawLine(
        Offset(box.left + box.width * 0.3, top + h * 0.25),
        Offset(box.left + box.width * 0.34, top + h * 0.7),
        Paint()
          ..strokeWidth = 2.4 * k
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withValues(alpha: 0.55),
      );
      // an engraved line round it
      canvas.drawLine(
        Offset(box.left, top + h * 0.42),
        Offset(box.right, top + h * 0.42),
        Paint()
          ..strokeWidth = 0.9 * k
          ..color = const Color(0xFF6E5218).withValues(alpha: 0.7),
      );
    case PotStyle.basket:
      final weave = Paint()
        ..strokeWidth = 0.8 * k
        ..color = const Color(0xFF5A3A1C).withValues(alpha: 0.6);
      for (var y = top + 3 * k; y < base.dy; y += 3.4 * k) {
        canvas.drawLine(Offset(box.left, y), Offset(box.right, y), weave);
      }
      for (var j = 0; j < 9; j++) {
        final x = box.left + box.width * (j + 0.5) / 9;
        canvas.drawLine(
          Offset(x, top),
          Offset(x + (j.isEven ? 1 : -1) * 1.5 * k, base.dy),
          weave,
        );
      }
    case PotStyle.terracotta:
      break;
  }
  canvas.restore();

  // the rim
  if (style == PotStyle.brass) {
    final lip = Rect.fromCenter(
      center: Offset(base.dx, top + h * 0.12),
      width: wTop * 1.04,
      height: h * 0.16,
    );
    canvas.drawOval(lip, Paint()..color = const Color(0xFFE2C26A));
    canvas.drawOval(
      lip,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (rimLight != null ? 1.2 : 0.8) * k
        ..color = rimLight ?? const Color(0xFF6E5218),
    );
    return;
  }
  final rimColours = switch (style) {
    PotStyle.glazed => shades(
      _glazes[(seed ~/ 7) % _glazes.length],
    ).sublist(0, 3),
    PotStyle.bluePottery => const [
      Color(0xFF2B4F9A),
      Color(0xFF4A72BE),
      Color(0xFF22407E),
    ],
    PotStyle.basket => const [
      Color(0xFF7A5430),
      Color(0xFFB0874F),
      Color(0xFF6A4624),
    ],
    _ => const [Color(0xFF9E5636), Color(0xFFD08458), Color(0xFF8A4529)],
  };
  final rim = RRect.fromRectAndRadius(
    Rect.fromCenter(
      center: Offset(base.dx, top + h * 0.08),
      width: wTop * (style == PotStyle.bluePottery ? 0.98 : 1.12),
      height: h * 0.2,
    ),
    Radius.circular(2 * k),
  );
  canvas.drawRRect(
    rim,
    Paint()
      ..shader = LinearGradient(colors: rimColours).createShader(rim.outerRect),
  );
  if (rimLight != null) {
    canvas.drawRRect(
      rim,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2 * k
        ..color = rimLight,
    );
  }
}

// ======================================================================
// wood

const shopWood = Color(0xFF5C3B22);
const shopWoodDark = Color(0xFF3B2615);
const shopWoodLight = Color(0xFF7E5533);

/// A board of wood: a gradient, grain, and light along its top edge.
void paintBoard(
  Canvas canvas,
  Rect r,
  double k, {
  int seed = 1,
  bool vertical = false,
}) {
  canvas.drawRect(
    r,
    Paint()
      ..shader = LinearGradient(
        begin: vertical ? Alignment.centerLeft : Alignment.topCenter,
        end: vertical ? Alignment.centerRight : Alignment.bottomCenter,
        colors: const [shopWoodLight, shopWood, shopWoodDark],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(r),
  );
  final g = math.Random(seed);
  final grain = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.7 * k;
  final n = ((vertical ? r.width : r.height) / (3.5 * k)).floor().clamp(2, 40);
  for (var j = 0; j < n; j++) {
    final f = (j + g.nextDouble()) / n;
    grain.color = (g.nextBool() ? Colors.black : shopWoodLight).withValues(
      alpha: 0.12 + g.nextDouble() * 0.12,
    );
    final path = Path();
    if (vertical) {
      final x = r.left + r.width * f;
      path.moveTo(x, r.top);
      path.quadraticBezierTo(
        x + (g.nextDouble() - 0.5) * 4 * k,
        r.center.dy,
        x,
        r.bottom,
      );
    } else {
      final y = r.top + r.height * f;
      path.moveTo(r.left, y);
      path.quadraticBezierTo(
        r.center.dx,
        y + (g.nextDouble() - 0.5) * 3 * k,
        r.right,
        y,
      );
    }
    canvas.drawPath(path, grain);
  }
}
