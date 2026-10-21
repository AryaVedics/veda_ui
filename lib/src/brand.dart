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
  });

  /// "Véda Sun".
  final String appName;

  /// The small capitals under the header medallion: "SUN".
  final String word;

  /// The app's own mark (its icon art on a transparent square).
  final String markAsset;
}

class VedaBrandScope extends InheritedWidget {
  const VedaBrandScope({super.key, required this.brand, required super.child});

  final VedaBrand brand;

  static VedaBrand of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<VedaBrandScope>()!.brand;

  @override
  bool updateShouldNotify(VedaBrandScope old) => old.brand != brand;
}

/// A very faint version of the app's mark at the bottom of the screen, the
/// same treatment as Véda's medallion watermark: 5% opacity, felt rather
/// than noticed.
class BrandWatermark extends StatelessWidget {
  const BrandWatermark({super.key});

  @override
  Widget build(BuildContext context) {
    final asset = VedaBrandScope.of(context).markAsset;
    return IgnorePointer(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Transform.translate(
          offset: const Offset(0, 22),
          child: Opacity(
            opacity: 0.05,
            child: LayoutBuilder(
              builder: (context, constraints) => Image.asset(
                asset,
                width: constraints.maxWidth,
                height: constraints.maxWidth,
                filterQuality: FilterQuality.medium,
              ),
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
