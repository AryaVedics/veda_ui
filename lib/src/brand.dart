// Who the app is: its name, its mark and the word under the header
// medallion. Every shared widget that shows the brand reads it from here,
// so an app sets it once at the top of the tree.

import 'package:flutter/material.dart';

import 'app_colors.dart';

class VedaBrand {
  const VedaBrand({
    required this.appName,
    required this.word,
    required this.markAsset,
    required this.ringTrack,
    this.watermarkScale = 1,
  });

  /// "Véda Sun".
  final String appName;

  /// The small capitals under the header medallion: "SUN".
  final String word;

  /// The app's own mark (its icon art on a transparent square).
  final String markAsset;

  /// How much bigger than the screen's width the mark is drawn as the faint
  /// background medallion. 1 for a mark whose medallion ring fills its square,
  /// like the other apps'. A mark with a night disc and fireflies round the
  /// medallion (Routine) is drawn larger, so its disc spans the full width.
  final double watermarkScale;

  /// The dark, unfilled band of the app's message ring: a deep shade from the
  /// app's own colour family, never Véda's gold-brown (see UI_RULES.md).
  final Color ringTrack;
}

class VedaBrandScope extends InheritedWidget {
  const VedaBrandScope({super.key, required this.brand, required super.child});

  final VedaBrand brand;

  static VedaBrand of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<VedaBrandScope>()!.brand;

  static VedaBrand? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<VedaBrandScope>()?.brand;

  @override
  bool updateShouldNotify(VedaBrandScope old) => old.brand != brand;
}

/// A very faint version of the app's mark at the bottom of the screen, the
/// same treatment as Véda's medallion watermark: 5% opacity, felt rather
/// than noticed.
///
/// On a Today screen, where a strong centerpiece sits right on top of it, the
/// mark is [quiet]: 40% of that strength (2%), so it stops competing with the
/// centerpiece. It fades between the two as the person changes tabs.
class BrandWatermark extends StatelessWidget {
  const BrandWatermark({super.key, this.quiet = false});

  /// 5% opacity normally.
  static const double opacity = 0.05;

  /// The share of [opacity] kept when [quiet].
  static const double quietShare = 0.4;

  final bool quiet;

  @override
  Widget build(BuildContext context) {
    final brand = VedaBrandScope.of(context);
    final asset = brand.markAsset;
    final scale = brand.watermarkScale;
    return IgnorePointer(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Transform.translate(
          offset: const Offset(0, 22),
          child: AnimatedOpacity(
            opacity: quiet ? opacity * quietShare : opacity,
            duration: const Duration(milliseconds: 250),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final side = constraints.maxWidth;
                return SizedBox(
                  width: side,
                  height: side,
                  // a larger mark grows from the same centre, past the edges
                  child: OverflowBox(
                    minWidth: side * scale,
                    maxWidth: side * scale,
                    minHeight: side * scale,
                    maxHeight: side * scale,
                    child: Image.asset(
                      asset,
                      width: side * scale,
                      height: side * scale,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// A soft vignette behind a screen's content: canvas toward the upper
/// middle, easing out to canvasDeep at the corners. Deliberately subtle, so
/// it reads as depth rather than as a gradient. A polished base (see
/// [AppColors.gleam]) also carries the sheen of shiny cookware.
class CanvasBackdrop extends StatelessWidget {
  const CanvasBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final decoration = BoxDecoration(
      gradient: RadialGradient(
        center: const Alignment(0, -0.4),
        radius: 1.3,
        colors: [colors.canvas, colors.canvas, colors.canvasDeep],
        stops: const [0, 0.5, 1],
      ),
    );
    if (!colors.gleam)
      return DecoratedBox(decoration: decoration, child: child);
    return Stack(
      children: [
        Positioned.fill(child: DecoratedBox(decoration: decoration)),
        // the sheen sits over the colour and under the content
        Positioned.fill(
          child: IgnorePointer(child: CustomPaint(painter: _GleamPainter())),
        ),
        // the content sits above the sheen
        Positioned.fill(child: child),
      ],
    );
  }
}

/// The sheen of polished copper: a broad soft light from the upper left, two
/// bright streaks slanting across, and a darker edge, all faint enough that
/// text on it keeps its contrast.
class _GleamPainter extends CustomPainter {
  const _GleamPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    // the sheen is held back from the top of the screen, where the message box
    // sits, so the words there stay easy to read: it fades in below it
    canvas.saveLayer(r, Paint());
    // a bloom of light where the lamp would catch the metal
    canvas.drawRect(
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.7, -0.8),
          radius: 1.0,
          colors: [
            const Color(0xFFFFE9CF).withValues(alpha: 0.3),
            const Color(0xFFFFE9CF).withValues(alpha: 0.07),
            const Color(0x00FFE9CF),
          ],
          stops: const [0, 0.45, 1],
        ).createShader(r),
    );
    // two slanting streaks, a broad soft one and a narrow bright one beside it
    for (final (centre, width, alpha) in const [
      (0.30, 0.10, 0.17),
      (0.36, 0.025, 0.28),
      (0.72, 0.06, 0.1),
    ]) {
      canvas.drawRect(
        r,
        Paint()
          ..shader = LinearGradient(
            begin: const Alignment(-1, -0.55),
            end: const Alignment(1, 0.55),
            colors: [
              const Color(0x00FFFFFF),
              Colors.white.withValues(alpha: alpha),
              const Color(0x00FFFFFF),
            ],
            stops: [
              (centre - width).clamp(0.0, 1.0),
              centre,
              (centre + width).clamp(0.0, 1.0),
            ],
          ).createShader(r),
      );
    }
    // the metal darkens toward the lower right, as a curved surface does
    canvas.drawRect(
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.9, 1.0),
          radius: 0.9,
          colors: [
            Colors.black.withValues(alpha: 0.18),
            const Color(0x00000000),
          ],
        ).createShader(r),
    );
    // keep only what is below the message box
    canvas.drawRect(
      r,
      Paint()
        ..blendMode = BlendMode.dstIn
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00FFFFFF), Color(0x00FFFFFF), Color(0xFFFFFFFF)],
          stops: [0, 0.27, 0.4],
        ).createShader(r),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GleamPainter old) => false;
}
