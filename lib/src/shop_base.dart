// The foot of a shop centrepiece (Garden's potting shed, Learn's library): a
// plank of the same wood as the posts with one or two brass nameplates set
// into it, each with two screws and engraved lettering. They are the page's
// buttons, built into the picture instead of standing under it. A plate
// brightens and sinks a little when pressed.

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// One nameplate on a [ShopBase].
class ShopPlate {
  const ShopPlate({required this.label, this.onTap, this.plateKey});

  /// The lettering, which is also what a screen reader says (without any
  /// leading "+").
  final String label;
  final VoidCallback? onTap;

  /// The key the plate's button is findable by in tests.
  final Key? plateKey;
}

class ShopBase extends StatelessWidget {
  const ShopBase({super.key, required this.plates});

  final List<ShopPlate> plates;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: CustomPaint(painter: _PlankPainter())),
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, box) {
              final h = box.maxHeight;
              final ph = math.min(h * 0.68, 38.0);
              final maxW = plates.length == 1 ? 300.0 : 190.0;
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  box.maxWidth * 0.08,
                  2,
                  box.maxWidth * 0.08,
                  0,
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < plates.length; i++) ...[
                        if (i > 0) const SizedBox(width: 12),
                        Flexible(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: maxW),
                            child: SizedBox(
                              height: ph,
                              child: _PlateButton(
                                key: plates[i].plateKey,
                                plate: plates[i],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PlankPainter extends CustomPainter {
  const _PlankPainter();

  static const _wood = Color(0xFF3A2416);
  static const _woodLight = Color(0xFF6A4A2E);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_woodLight, _wood, Color(0xFF281810)],
          stops: [0, 0.12, 1],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );
    canvas.drawLine(
      Offset.zero,
      Offset(w, 0),
      Paint()
        ..strokeWidth = 1.5
        ..color = const Color(0x55FFE2B0),
    );
    final grain = Paint()
      ..strokeWidth = 0.8
      ..color = const Color(0x22000000);
    for (final f in const [0.28, 0.52, 0.76]) {
      canvas.drawLine(Offset(0, h * f), Offset(w, h * f), grain);
    }
  }

  @override
  bool shouldRepaint(_PlankPainter old) => false;
}

class _PlateButton extends StatefulWidget {
  const _PlateButton({super.key, required this.plate});

  final ShopPlate plate;

  @override
  State<_PlateButton> createState() => _PlateButtonState();
}

class _PlateButtonState extends State<_PlateButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.plate.label.replaceFirst(RegExp(r'^\+\s*'), ''),
      excludeSemantics: true,
      onTap: widget.plate.onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.plate.onTap,
        child: CustomPaint(
          painter: _PlatePainter(widget.plate.label, _pressed),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _PlatePainter extends CustomPainter {
  _PlatePainter(this.label, this.pressed);

  final String label;
  final bool pressed;

  static const _brass = Color(0xFFC9A24B);
  static const _ink = Color(0xFF2B1D0E);

  @override
  void paint(Canvas canvas, Size size) {
    final r = (Offset.zero & size).translate(0, pressed ? 1.5 : 0);
    final rr = RRect.fromRectAndRadius(r, const Radius.circular(8));
    if (!pressed) {
      canvas.drawRRect(
        rr.shift(const Offset(0, 2)),
        Paint()..color = const Color(0x66000000),
      );
    }
    canvas.drawRRect(
      rr,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: pressed
              ? const [Color(0xFFF0D585), Color(0xFFD9B456)]
              : const [Color(0xFFE3C26C), _brass, Color(0xFFAA8238)],
        ).createShader(r),
    );
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0xFF7A5A28),
    );
    canvas.drawRRect(
      rr.deflate(3),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = const Color(0x99F3DC9A),
    );
    for (final dx in [r.left + 13, r.right - 13]) {
      final c = Offset(dx, r.center.dy);
      canvas.drawCircle(c, 3.0, Paint()..color = const Color(0xFF8A6A30));
      canvas.drawCircle(
        c - const Offset(0.6, 0.6),
        2.0,
        Paint()..color = const Color(0xFFE9D08A),
      );
      canvas.drawLine(
        c - const Offset(1.7, -0.6),
        c + const Offset(1.7, -0.6),
        Paint()
          ..strokeWidth = 0.7
          ..color = const Color(0xFF5A4220),
      );
    }
    var fontSize = 16.0;
    final fitW = r.width - 50;
    late TextPainter tp;
    for (var attempt = 0; attempt < 10; attempt++) {
      tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            fontFamily: 'Georgia',
            fontFamilyFallback: const ['serif'],
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            color: _ink,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      if (tp.width <= fitW || fontSize <= 9) break;
      fontSize *= fitW / tp.width * 0.97;
    }
    tp.paint(
      canvas,
      Offset(r.center.dx - tp.width / 2, r.center.dy - tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(_PlatePainter old) =>
      old.label != label || old.pressed != pressed;
}
