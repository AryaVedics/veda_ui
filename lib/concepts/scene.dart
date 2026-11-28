// The painter every concept scene starts from: a 360 x 420 drawing surface
// fitted into whatever room Today gives it, with the family's glow, forest and
// ground.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../veda_ui.dart';

import 'model.dart';

abstract class Scene extends CustomPainter {
  Scene(this.data, this.now, this.colors, this.t);

  final ConceptData data;
  final DateTime now;
  final AppColors colors;

  /// 0 to 1, looping every twelve seconds.
  final double t;

  static const w = 360.0, h = 420.0;

  Color get gold => colors.accent;
  Color get shade => colors.canvasDeep;
  Color get trees => Color.lerp(colors.canvasDeep, Colors.black, 0.22)!;

  /// The last seven days, oldest first: noted or not.
  List<bool> get week => [for (final d in data.week(now)) d != null];

  Paint fill(Color c) => Paint()..color = c;

  Paint line(Color c, double width) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..strokeWidth = width
    ..color = c;

  void glow(Canvas c, Offset at, double r, [double alpha = 0.35]) {
    final rect = Rect.fromCircle(center: at, radius: r);
    c.drawCircle(
      at,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [
            gold.withValues(alpha: alpha),
            gold.withValues(alpha: 0),
          ],
        ).createShader(rect),
    );
  }

  /// Trees at both sides, standing on [base].
  void forest(Canvas c, double base) {
    for (final side in [0.0, 1.0]) {
      for (var i = 0; i < 4; i++) {
        final x = side == 0 ? 8.0 + i * 24 : w - 8.0 - i * 24;
        final tall = 150.0 - i * 26;
        c.drawPath(
          deciduousTree(
            Offset(x, base),
            tall,
            tall * 0.62,
            math.Random(i * 7 + side.toInt() * 31 + 3),
          ),
          fill(trees.withValues(alpha: 0.9 - i * 0.08)),
        );
      }
    }
  }

  void ground(Canvas c, double y) {
    c.drawOval(
      Rect.fromCenter(
        center: Offset(w / 2, y + 16),
        width: w * 1.15,
        height: 46,
      ),
      fill(trees),
    );
  }

  void fireflies(Canvas c, int count) {
    final r = math.Random(11);
    for (var i = 0; i < count; i++) {
      final x = 20 + r.nextDouble() * (w - 40);
      final y = 40 + r.nextDouble() * (h - 110);
      final phase = r.nextDouble();
      final a = 0.25 + 0.55 * math.sin((t * 3 + phase) * 2 * math.pi).abs();
      c.drawCircle(
        Offset(
          x + math.sin((t + phase) * 2 * math.pi) * 5,
          y + math.cos((t * 2 + phase) * 2 * math.pi) * 3,
        ),
        1.5,
        fill(gold.withValues(alpha: a)),
      );
    }
  }

  void draw(Canvas c);

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width / w, size.height / h);
    canvas.save();
    canvas.translate((size.width - w * s) / 2, (size.height - h * s) / 2);
    canvas.scale(s);
    draw(canvas);
    canvas.restore();
  }

  @override
  bool shouldRepaint(Scene old) =>
      old.t != t || old.data != data || old.now.day != now.day;
}

/// "Last noted today", or an invitation.
String lastNoted(ConceptData d, DateTime now) {
  final days = d.within(now, 3650);
  if (days.isEmpty) return 'Nothing noted yet';
  final ago = dayOf(now).difference(parseDayKey(days.first.day)).inDays;
  return 'Last noted ${ago <= 0
      ? 'today'
      : ago == 1
      ? 'yesterday'
      : '$ago days ago'}';
}
