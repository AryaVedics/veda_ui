// The "readout" bars: each row is a label and its number on one line, with a
// thicker track beneath it, short brackets marking the track's 0 and 100, and
// the same gold-into-identity wash, vein and glowing tip as every other bar.
// This is the look of Véda's own Lifestyle tab, and the one Véda Lifestyle
// uses for all of its bar charts (a firmer, more instrument-like read than
// the slim rows the other apps use).

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'data_reveal.dart';
import 'metric_ghost.dart' show ghostFraction;
import 'metric_info.dart';

/// Space between rows: roomier for a handful, tighter for a full set.
double hudRowGap(int rows) => rows <= 5 ? 18 : 10;

/// One row's height (label line, gap, track), without the space after it.
const kHudRowHeight = 37.0;

/// Height of [rows] rows with their gaps.
double hudBarsHeight(int rows) =>
    rows * kHudRowHeight + (rows - 1) * hudRowGap(rows);

class HudBarsView extends StatelessWidget {
  const HudBarsView({
    super.key,
    required this.scores,
    required this.colors,
    required this.onTap,
  });

  final Map<String, double> scores;
  final AppColors colors;
  final void Function(String key) onTap;

  @override
  Widget build(BuildContext context) {
    final entries = scores.entries.toList();
    final gap = hudRowGap(entries.length);
    return DataReveal(
      builder: (context, tAt) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < entries.length; i++)
            InkWell(
              onTap: () => onTap(entries[i].key),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: i == entries.length - 1 ? 0 : gap,
                ),
                child: _row(entries[i], tAt(i, entries.length)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _row(MapEntry<String, double> e, double reveal) {
    final info = metricInfoByKey[e.key];
    final identity = info?.identityColor ?? colors.textMuted;
    final shown = e.value * reveal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                info?.name ?? e.key,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ),
            Text(
              shown.toStringAsFixed(0),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colors.accentText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        SizedBox(
          height: 14,
          child: LayoutBuilder(
            builder: (context, constraints) => CustomPaint(
              size: Size(constraints.maxWidth, 14),
              painter: _HudBarPainter(
                fraction: (shown / 100).clamp(0.0, 1.0),
                trackColor: colors.cardSunken,
                bracketColor: colors.accentDim,
                fillColor: colors.accent,
                veinColor: identity,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HudBarPainter extends CustomPainter {
  _HudBarPainter({
    required this.fraction,
    required this.trackColor,
    required this.bracketColor,
    required this.fillColor,
    required this.veinColor,
  });

  final double fraction;
  final Color trackColor;
  final Color bracketColor;
  final Color fillColor;
  final Color veinColor;

  static const _trackHeight = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    final trackTop = (size.height - _trackHeight) / 2;
    const radius = _trackHeight / 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, trackTop, size.width, _trackHeight),
        const Radius.circular(radius),
      ),
      Paint()..color = trackColor,
    );
    _brackets(canvas, size, bracketColor);

    final fillWidth = size.width * fraction.clamp(0.0, 1.0);
    if (fillWidth <= 0) return;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, trackTop, fillWidth, _trackHeight),
        const Radius.circular(radius),
      ),
      Paint()
        ..shader = ui.Gradient.linear(Offset.zero, Offset(fillWidth, 0), [
          fillColor,
          veinColor.withValues(alpha: 0.75),
        ]),
    );

    const inset = radius * 0.8;
    if (fillWidth > inset * 2) {
      final y = trackTop + _trackHeight / 2;
      canvas.drawLine(
        Offset(inset, y),
        Offset(fillWidth - inset, y),
        Paint()
          ..color = veinColor
          ..strokeWidth = 1.3
          ..strokeCap = StrokeCap.round,
      );
    }

    final capX = (fillWidth - 1).clamp(0.0, size.width - 1);
    canvas.drawLine(
      Offset(capX, trackTop - 1),
      Offset(capX, trackTop + _trackHeight + 1),
      Paint()
        ..strokeWidth = _trackHeight * 0.9
        ..strokeCap = StrokeCap.round
        ..color = kMarkerWhite.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawLine(
      Offset(capX, trackTop - 1),
      Offset(capX, trackTop + _trackHeight + 1),
      Paint()
        ..strokeWidth = _trackHeight * 0.35
        ..strokeCap = StrokeCap.round
        ..color = kMarkerWhite,
    );
  }

  @override
  bool shouldRepaint(_HudBarPainter old) =>
      old.fraction != fraction ||
      old.trackColor != trackColor ||
      old.fillColor != fillColor ||
      old.veinColor != veinColor;
}

void _brackets(Canvas canvas, Size size, Color color) {
  final bracket = Paint()
    ..strokeWidth = 1.4
    ..color = color;
  canvas.drawLine(const Offset(0.7, 0), Offset(0.7, size.height), bracket);
  canvas.drawLine(
    Offset(size.width - 0.7, 0),
    Offset(size.width - 0.7, size.height),
    bracket,
  );
}

/// The same rows before there is data: a breathing ghost fill and "–".
class HudGhostBars extends StatefulWidget {
  const HudGhostBars({super.key, required this.colors, required this.infos});

  final AppColors colors;
  final List<MetricInfo> infos;

  @override
  State<HudGhostBars> createState() => _HudGhostBarsState();
}

class _HudGhostBarsState extends State<HudGhostBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3400),
  )..repeat(reverse: true);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Holds still when the phone asks for reduced motion.
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse
        ..stop()
        ..value = 0.5;
    } else if (!_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final gap = hudRowGap(widget.infos.length);
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final glowT = Curves.easeInOut.transform(_pulse.value);
        final alpha = 0.28 + 0.14 * glowT;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < widget.infos.length; i++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: i == widget.infos.length - 1 ? 0 : gap,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.infos[i].name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          '–',
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    SizedBox(
                      height: 14,
                      child: LayoutBuilder(
                        builder: (context, constraints) => CustomPaint(
                          size: Size(constraints.maxWidth, 14),
                          painter: _HudGhostPainter(
                            fraction: ghostFraction(i),
                            trackColor: colors.cardSunken,
                            bracketColor: colors.textMuted.withValues(
                              alpha: 0.35,
                            ),
                            goldColor: colors.accent,
                            identityColor: widget.infos[i].identityColor,
                            alpha: alpha,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _HudGhostPainter extends CustomPainter {
  _HudGhostPainter({
    required this.fraction,
    required this.trackColor,
    required this.bracketColor,
    required this.goldColor,
    required this.identityColor,
    required this.alpha,
  });

  final double fraction;
  final Color trackColor;
  final Color bracketColor;
  final Color goldColor;
  final Color identityColor;
  final double alpha;

  static const _trackHeight = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    final trackTop = (size.height - _trackHeight) / 2;
    const radius = _trackHeight / 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, trackTop, size.width, _trackHeight),
        const Radius.circular(radius),
      ),
      Paint()..color = trackColor,
    );
    _brackets(canvas, size, bracketColor);

    final ghostWidth = size.width * fraction;
    if (ghostWidth <= 0) return;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, trackTop, ghostWidth, _trackHeight),
        const Radius.circular(radius),
      ),
      Paint()
        ..shader = ui.Gradient.linear(Offset.zero, Offset(ghostWidth, 0), [
          goldColor.withValues(alpha: alpha * 0.75),
          identityColor.withValues(alpha: alpha),
        ]),
    );
  }

  @override
  bool shouldRepaint(_HudGhostPainter old) =>
      old.fraction != fraction ||
      old.alpha != alpha ||
      old.identityColor != identityColor ||
      old.trackColor != trackColor;
}
