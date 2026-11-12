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
/// it reads as depth rather than as a gradient.
class CanvasBackdrop extends StatelessWidget {
  const CanvasBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.4),
          radius: 1.3,
          colors: [colors.canvas, colors.canvas, colors.canvasDeep],
          stops: const [0, 0.5, 1],
        ),
      ),
      child: child,
    );
  }
}
