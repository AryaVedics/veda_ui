// The shelf's centrepiece: your products as bottles around a ring, eight to a
// shelf (a ninth starts a second ring below, a seventeenth a third). A thin
// gold arc around each bottle is how much of its own use-by time is left; a
// bottle with no use-by date has a plain thin outline instead. The arcs only
// inform: nothing turns red and nothing warns. Tap a bottle to see its name in
// the middle, and tap that to edit it.
//
// Shared by the apps that keep a shelf (Routine, Hair). Each draws it in its
// own sky ([ShelfSky]) and gives its bottles their shapes ([BottleShape]).

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'breathing.dart';
import 'common.dart';
import 'shelf_item.dart';
import 'theme.dart';

/// The colours of the ring's night sky and of the little sky each bottle sits
/// in: lit from above, darker below.
class ShelfSky {
  const ShelfSky({
    required this.top,
    required this.mid,
    required this.bottom,
    required this.bottleTop,
  });

  final Color top, mid, bottom;

  /// The lit top of a bottle's own sky.
  final Color bottleTop;

  /// Routine's: the deep blue night of its centrepiece.
  static const night = ShelfSky(
    top: Color(0xFF1F5A6B),
    mid: Color(0xFF16305E),
    bottom: Color(0xFF0A1433),
    bottleTop: Color(0xFF2E8294),
  );

  /// Hair's: the dark copper of its forest at night.
  static const copper = ShelfSky(
    top: Color(0xFF7A3A1E),
    mid: Color(0xFF4A2210),
    bottom: Color(0xFF26110A),
    bottleTop: Color(0xFF8C4A2A),
  );
}

const _perShelf = 8;

class ShelfRings extends StatefulWidget {
  const ShelfRings({
    super.key,
    required this.items,
    required this.soonCount,
    required this.today,
    required this.onEdit,
    this.sky = ShelfSky.night,
    this.fireflies = true,
  });

  /// The products on the shelf, in the order they should sit.
  final List<ShelfItem> items;

  /// How many are within a month of their use-by date.
  final int soonCount;
  final DateTime today;
  final void Function(ShelfItem) onEdit;
  final ShelfSky sky;

  /// Fireflies in the empty space round the bottles (off in a quiet mode).
  final bool fireflies;

  @override
  State<ShelfRings> createState() => _ShelfRingsState();
}

class _ShelfRingsState extends State<ShelfRings> {
  String? _selected;
  final PageController _pages = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shelves = <List<ShelfItem>>[
      for (var i = 0; i < widget.items.length; i += _perShelf)
        widget.items.sublist(i, math.min(i + _perShelf, widget.items.length)),
    ];
    ShelfItem? selected;
    for (final p in widget.items) {
      if (p.id == _selected) selected = p;
    }
    _Ring ring(int i) => _Ring(
      items: shelves[i],
      index: i,
      total: widget.items.length,
      soonCount: widget.soonCount,
      today: widget.today,
      selected: selected,
      sky: widget.sky,
      fireflies: widget.fireflies,
      onSelect: (p) =>
          setState(() => _selected = _selected == p.id ? null : p.id),
      onEdit: widget.onEdit,
    );
    // one shelf at a time: a single shelf sits still; more than one are swiped
    // through, with dots showing which one is showing
    if (shelves.length <= 1) {
      return shelves.isEmpty ? const SizedBox.shrink() : ring(0);
    }
    final colors = context.colors;
    return Column(
      children: [
        SizedBox(
          height: _Ring.box,
          child: PageView(
            controller: _pages,
            onPageChanged: (i) => setState(() => _page = i),
            children: [
              for (var i = 0; i < shelves.length; i++) Center(child: ring(i)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < shelves.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _page ? 14 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _page
                      ? colors.accent
                      : colors.textMuted.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({
    required this.items,
    required this.index,
    required this.total,
    required this.soonCount,
    required this.today,
    required this.selected,
    required this.sky,
    required this.fireflies,
    required this.onSelect,
    required this.onEdit,
  });

  final List<ShelfItem> items;
  final int index;
  final int total;
  final int soonCount;
  final DateTime today;
  final ShelfItem? selected;
  final ShelfSky sky;
  final bool fireflies;
  final void Function(ShelfItem) onSelect;
  final void Function(ShelfItem) onEdit;

  static const double box = 325; // 25% larger than the first size
  static const double radius = 92;
  static const double node = 25;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final here = selected != null && items.any((p) => p.id == selected!.id);
    Widget centre;
    if (here) {
      final p = selected!;
      final by = p.useBy;
      centre = SizedBox(
        width: 126,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              p.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14.5, color: colors.textPrimary),
            ),
            const SizedBox(height: 3),
            Text(
              by == null
                  ? p.kindLabel
                  : '${p.kindLabel} · use by ${shortDate(by)}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, color: colors.textMuted),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => onEdit(p),
              child: Text(
                'Edit',
                style: TextStyle(fontSize: 12.5, color: colors.accentText),
              ),
            ),
          ],
        ),
      );
    } else if (index == 0) {
      centre = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$total',
            style: TextStyle(
              fontSize: 40,
              fontFamily: kDisplayFont,
              height: 1.05,
              color: colors.textPrimary,
            ),
          ),
          Text(
            'ON YOUR SHELF',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 1.3,
              color: colors.textMuted,
            ),
          ),
          if (soonCount > 0) ...[
            const SizedBox(height: 4),
            Text(
              soonCount == 1 ? '1 to use soon' : '$soonCount to use soon',
              style: TextStyle(fontSize: 12.5, color: colors.accentText),
            ),
          ],
        ],
      );
    } else {
      centre = Text(
        'Shelf ${index + 1}',
        style: TextStyle(
          fontSize: 18,
          fontFamily: kDisplayFont,
          color: colors.textSecondary,
        ),
      );
    }
    final n = items.length;
    return SizedBox(
      width: box,
      height: box,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // fireflies in the empty space round the bottles: faint, twinkling,
          // and never in the way of a tap
          if (fireflies)
            IgnorePointer(
              child: Breathing(
                builder: (context, t) => CustomPaint(
                  size: const Size(box, box),
                  painter: _ShelfFliesPainter(t),
                ),
              ),
            ),
          CustomPaint(
            size: const Size(box, box),
            painter: _GuidePainter(colors.divider, sky),
          ),
          centre,
          for (var i = 0; i < n; i++)
            Builder(
              builder: (context) {
                final ang = (-90 + i * 360 / n) * math.pi / 180;
                final p = items[i];
                return Transform.translate(
                  offset: Offset(
                    radius * math.cos(ang),
                    radius * math.sin(ang),
                  ),
                  child: Semantics(
                    button: true,
                    label: '${p.name}, ${p.kindLabel}',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onSelect(p),
                      child: SizedBox(
                        width: node * 2 + 14,
                        height: node * 2 + 14,
                        child: CustomPaint(
                          painter: _BottlePainter(
                            left: shelfTimeLeft(p, today),
                            shape: p.shape,
                            chosen: selected?.id == p.id,
                            sky: sky,
                            gold: colors.accent,
                            dim: colors.accentDim,
                            line: colors.divider,
                            body: colors.textSecondary,
                            cap: colors.accentText,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _GuidePainter extends CustomPainter {
  _GuidePainter(this.color, this.sky);
  final Color color;
  final ShelfSky sky;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    // the shelf's night sky, the same as the centrepiece's, with a light
    // scatter of stars
    canvas.drawCircle(
      c,
      _Ring.radius,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [sky.top, sky.mid, sky.bottom],
        ).createShader(Rect.fromCircle(center: c, radius: _Ring.radius)),
    );
    final rnd = math.Random(4);
    final star = Paint();
    for (var k = 0; k < 34; k++) {
      final a = rnd.nextDouble() * math.pi * 2;
      final d = math.sqrt(rnd.nextDouble()) * (_Ring.radius - 6);
      star.color = const Color(0xFFFFFDF5)
          .withValues(alpha: 0.12 + 0.4 * rnd.nextDouble());
      canvas.drawCircle(
        c + Offset(math.cos(a), math.sin(a)) * d,
        0.5 + 0.6 * rnd.nextDouble(),
        star,
      );
    }
    canvas.drawCircle(
      c,
      _Ring.radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_GuidePainter old) => old.color != color || old.sky != sky;
}

class _BottlePainter extends CustomPainter {
  _BottlePainter({
    required this.left,
    required this.shape,
    required this.chosen,
    required this.sky,
    required this.gold,
    required this.dim,
    required this.line,
    required this.body,
    required this.cap,
  });

  final double? left;
  final BottleShape shape;
  final bool chosen;
  final ShelfSky sky;
  final Color gold, dim, line, body, cap;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    const r = _Ring.node;
    // each bottle sits in a little night sky, lit from above, like the centre
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.5),
          colors: [sky.bottleTop, sky.mid, sky.bottom],
          stops: const [0, 0.55, 1],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    final arc = Rect.fromCircle(center: c, radius: r + 3.5);
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = chosen ? 3.0 : 2.2
      ..strokeCap = StrokeCap.round;
    if (left == null) {
      canvas.drawArc(
        arc,
        0,
        math.pi * 2,
        false,
        ring..color = chosen ? gold : line,
      );
    } else {
      canvas.drawArc(arc, 0, math.pi * 2, false, ring..color = dim);
      if (left! > 0) {
        canvas.drawArc(
          arc,
          -math.pi / 2,
          math.pi * 2 * left!,
          false,
          ring..color = gold,
        );
      }
    }
    _drawShape(canvas, c);
  }

  /// The product itself, in a line drawing: [shape].
  void _drawShape(Canvas canvas, Offset c) {
    final capPaint = Paint()..color = cap;
    final fillBody = Paint()..color = body;
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = body;
    RRect box(double l, double t, double r, double b, double rad) =>
        RRect.fromRectAndRadius(
          Rect.fromLTRB(c.dx + l, c.dy + t, c.dx + r, c.dy + b),
          Radius.circular(rad),
        );
    switch (shape) {
      case BottleShape.bottle:
        // cap, neck, body
        canvas.drawRRect(box(-4.5, -15.5, 4.5, -10.5, 1.6), capPaint);
        canvas.drawRect(
          Rect.fromCenter(center: c.translate(0, -8), width: 5, height: 4),
          fillBody,
        );
        canvas.drawRRect(box(-9, -6, 9, 14, 4), outline);
      case BottleShape.jar:
        // a wide lid on a short, wide body
        canvas.drawRRect(box(-10, -11, 10, -6.5, 1.8), capPaint);
        canvas.drawRRect(box(-10.5, -5, 10.5, 12, 5), outline);
      case BottleShape.dropper:
        // a rubber bulb on a narrow neck over a rounded body
        canvas.drawRRect(box(-3.5, -17, 3.5, -9.5, 3.5), capPaint);
        canvas.drawRect(
          Rect.fromCenter(center: c.translate(0, -7.5), width: 7, height: 3),
          fillBody,
        );
        canvas.drawRRect(box(-7.5, -6, 7.5, 14, 6), outline);
      case BottleShape.spray:
        // a nozzle and trigger head on a slim can
        canvas.drawRRect(box(-6.5, -16, 6, -11.5, 1.6), capPaint);
        canvas.drawRect(
          Rect.fromCenter(center: c.translate(0, -9), width: 5, height: 4),
          fillBody,
        );
        canvas.drawRRect(box(-8, -7, 8, 14, 3.5), outline);
      case BottleShape.comb:
        // a handle and a row of teeth
        canvas.drawRRect(box(-11, -11, 11, -6, 2), capPaint);
        final tooth = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..strokeCap = StrokeCap.round
          ..color = body;
        for (var i = 0; i < 6; i++) {
          final x = -8.5 + i * 3.4;
          canvas.drawLine(c.translate(x, -4), c.translate(x, 13), tooth);
        }
    }
  }

  @override
  bool shouldRepaint(_BottlePainter old) =>
      old.left != left ||
      old.shape != shape ||
      old.chosen != chosen ||
      old.gold != gold ||
      old.sky != sky;
}

/// Fireflies in a loose ring outside the bottles: each one glows on its own
/// beat, so the ring twinkles rather than blinking in step.
class _ShelfFliesPainter extends CustomPainter {
  _ShelfFliesPainter(this.t);

  final double t;

  static const _glow = Color(0xFFF4FFB8);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final rnd = math.Random(17);
    for (var i = 0; i < 26; i++) {
      // evenly round the ring, with a little give so it does not look drawn
      final a = i * math.pi * 2 / 26 + (rnd.nextDouble() - 0.5) * 0.12;
      final r = 118 + rnd.nextDouble() * 34;
      final phase = rnd.nextDouble();
      final lit = 0.5 + 0.5 * math.sin(2 * math.pi * (t + phase));
      final at = c + Offset(math.cos(a), math.sin(a)) * r;
      canvas.drawCircle(
        at,
        4.5,
        Paint()
          ..color = _glow.withValues(alpha: 0.22 * lit)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      canvas.drawCircle(
        at,
        1.4,
        Paint()..color = _glow.withValues(alpha: 0.35 + 0.5 * lit),
      );
    }
  }

  @override
  bool shouldRepaint(_ShelfFliesPainter old) => old.t != t;
}
