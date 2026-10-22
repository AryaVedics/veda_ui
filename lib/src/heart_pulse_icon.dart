// Véda's own Lifestyle tab icon (flutter_app/lib/widgets/lifestyle_tab_icon.dart),
// shared so the Lifestyle app's tab and the Véda tab are the same drawing: a
// heart with an EKG line, an outline when idle and solid with the line cut
// through it when selected. Same 24 x 24 grid as Phosphor's icons.

import 'package:flutter/material.dart';

import 'app_colors.dart';

class HeartPulseIcon extends StatelessWidget {
  const HeartPulseIcon({
    super.key,
    required this.selected,
    required this.color,
  });

  final bool selected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ekgColor = selected ? context.colors.onAccent : color;
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(
        painter: _HeartPulsePainter(
          filled: selected,
          heartColor: color,
          ekgColor: ekgColor,
        ),
      ),
    );
  }
}

Path _heartPath() => Path()
  ..moveTo(20.84, 4.61)
  ..arcToPoint(
    const Offset(13.06, 4.61),
    radius: const Radius.circular(5.5),
    clockwise: false,
  )
  ..lineTo(12, 5.67)
  ..lineTo(10.94, 4.61)
  ..arcToPoint(
    const Offset(3.16, 12.39),
    radius: const Radius.circular(5.5),
    clockwise: false,
  )
  ..lineTo(4.22, 13.45)
  ..lineTo(12, 21.23)
  ..lineTo(19.78, 13.45)
  ..lineTo(20.84, 12.39)
  ..arcToPoint(
    const Offset(20.84, 4.61),
    radius: const Radius.circular(5.5),
    clockwise: false,
  )
  ..close();

Path _ekgPath() => Path()
  ..moveTo(6, 13)
  ..relativeLineTo(2.5, 0)
  ..relativeLineTo(2, -5)
  ..relativeLineTo(3, 9)
  ..relativeLineTo(2, -4)
  ..relativeLineTo(2.5, 0);

class _HeartPulsePainter extends CustomPainter {
  _HeartPulsePainter({
    required this.filled,
    required this.heartColor,
    required this.ekgColor,
  });

  final bool filled;
  final Color heartColor;
  final Color ekgColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);

    canvas.drawPath(
      _heartPath(),
      Paint()
        ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
        ..strokeWidth = 1.7
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = heartColor,
    );

    canvas.drawPath(
      _ekgPath(),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = ekgColor,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_HeartPulsePainter old) =>
      old.filled != filled ||
      old.heartColor != heartColor ||
      old.ekgColor != ekgColor;
}
