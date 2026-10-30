// A chart or centerpiece that scales with the screen. The child is laid out at
// the size it was designed for and then scaled, as a whole, to the width it
// is given (within a range), so every band, label, marker and line inside it
// grows and shrinks together and a smaller one is the same drawing, smaller.
//
// House rule: every centerpiece and chart in every Véda app goes in one of
// these (or scales itself from one factor, as Cycle's wheel does).

import 'package:flutter/material.dart';

class ScaledBox extends StatelessWidget {
  const ScaledBox({
    super.key,
    required this.designWidth,
    required this.designHeight,
    required this.child,
    this.minScale = 0.7,
    this.maxScale = 1.2,
  });

  /// The size the child was designed for, at scale 1.
  final double designWidth;
  final double designHeight;
  final Widget child;

  /// How far it may shrink or grow from the design size.
  final double minScale;
  final double maxScale;

  /// The scale for a given available width.
  static double scaleFor(
    double width,
    double designWidth, {
    double minScale = 0.7,
    double maxScale = 1.2,
  }) => (width / designWidth).clamp(minScale, maxScale).toDouble();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final width = c.maxWidth.isFinite ? c.maxWidth : designWidth;
      final s = scaleFor(
        width,
        designWidth,
        minScale: minScale,
        maxScale: maxScale,
      );
      return SizedBox(
        width: width,
        height: designHeight * s,
        child: Center(
          child: SizedBox(
            width: designWidth * s,
            height: designHeight * s,
            child: FittedBox(
              fit: BoxFit.fill,
              child: SizedBox(
                width: designWidth,
                height: designHeight,
                child: child,
              ),
            ),
          ),
        ),
      );
    },
  );
}
