// The fade every chart in the apps uses: faint at the start, the chart's own
// colour at the tip (where the glowing cap sits). It is what the Wellness ring
// and Véda's rings already do; this keeps lines, bars and progress bars the
// same, so a chart never reads as a flat block of colour.
//
// House rule: a fill that shows how far something has got (a ring, a bar, a
// line over time) fades this way. Categorical colour (the four phases of the
// cycle, the UV bands) stays as separate solid colours.

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// How strong the faint end of a fade is.
const double kFadeStartAlpha = 0.35;

/// [c] as the faint start of a fade.
Color fadeStart(Color c) => c.withValues(alpha: kFadeStartAlpha);

/// A gradient from the faint start to the full colour, left to right.
LinearGradient fadeAcross(Color c) => LinearGradient(colors: [fadeStart(c), c]);

/// A progress bar in the apps' look: a quiet track, a fill that fades up to
/// [color], and a small glowing cap at the tip. [fraction] is 0 to 1.
class GradientProgressBar extends StatelessWidget {
  const GradientProgressBar({
    super.key,
    required this.fraction,
    required this.color,
    this.height = 8,
  });

  final double fraction;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _BarPainter(
          fraction: fraction.clamp(0.0, 1.0).toDouble(),
          color: color,
          track: colors.cardSunken,
        ),
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter({
    required this.fraction,
    required this.color,
    required this.track,
  });

  final double fraction;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Radius.circular(size.height / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, r),
      Paint()..color = track,
    );
    final w = size.width * fraction;
    if (w <= 0) return;
    final rect = Rect.fromLTWH(0, 0, w, size.height);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, r),
      Paint()..shader = fadeAcross(color).createShader(rect),
    );
    // the cap at the tip
    final x = (w - 1).clamp(0.0, size.width - 1);
    canvas.drawLine(
      Offset(x, -0.5),
      Offset(x, size.height + 0.5),
      Paint()
        ..strokeWidth = size.height * 0.8
        ..strokeCap = StrokeCap.round
        ..color = kMarkerWhite.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );
    canvas.drawLine(
      Offset(x, 0),
      Offset(x, size.height),
      Paint()
        ..strokeWidth = 1.6
        ..color = kMarkerWhite,
    );
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.fraction != fraction || old.color != color || old.track != track;
}
