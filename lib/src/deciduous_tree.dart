// The Véda forest's deciduous tree: a broad, rounded crown of overlapping lobes
// on a visible trunk with a couple of forks into the crown, drawn as one flat
// silhouette like the forest's pines (a Path to fill in the layer's colour).
//
// The forest is pines on the cliffs, the ridge and the far hills and mostly
// deciduous trees in the lower forest, where people would walk; Véda Sleep and
// Véda Hair draw their lower forests with this tree. Each tree is shaped by its
// own [math.Random], so a forest of them is not one tree repeated.

import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// A deciduous tree standing at [base], [height] tall overall (the top of the
/// crown is exactly [height] above the base) with a crown about [width] across.
Path deciduousTree(Offset base, double height, double width, math.Random r) {
  final p = Path();

  // the crown: a dome of lobes, built so its top is the tree's top
  final crownR = width * 0.5; // half the crown's width
  // the crown is a dome, never much taller than it is wide: a tall narrow tree
  // gets a longer trunk, not a stretched crown
  final crownH = math.min(height * 0.66, width * 0.95);
  final clear = height - crownH; // the bare height below the crown
  final trunkTop = base.dy - (clear + crownH * 0.2);
  final cy = base.dy - height + crownH * 0.5; // the middle of the crown
  final lobeBase = width * 0.19;

  // the trunk: a little wider at the foot, tapering up into the crown
  final foot = math.max(width * 0.07, 1.0);
  final neck = foot * 0.62;
  p
    ..moveTo(base.dx - foot, base.dy)
    ..lineTo(base.dx - neck, trunkTop)
    ..lineTo(base.dx + neck, trunkTop)
    ..lineTo(base.dx + foot, base.dy)
    ..close();

  // forks from the trunk up into the lobes (thin, so they show between them)
  final forks = 2 + r.nextInt(2);
  for (var i = 0; i < forks; i++) {
    final dir =
        (i == 0
            ? -1.0
            : i == 1
            ? 1.0
            : 0.0) *
        (0.5 + r.nextDouble() * 0.4);
    final tip = Offset(
      base.dx + dir * crownR * 0.7,
      base.dy - (clear + crownH * (0.3 + r.nextDouble() * 0.25)),
    );
    final w = neck * 0.55;
    p
      ..moveTo(base.dx - w, trunkTop + crownH * 0.05)
      ..lineTo(tip.dx - w * 0.4, tip.dy)
      ..lineTo(tip.dx + w * 0.4, tip.dy)
      ..lineTo(base.dx + w, trunkTop + crownH * 0.05)
      ..close();
  }

  // lobes round the dome and a few filling it, so no gaps show inside
  const around = 11;
  for (var i = 0; i < around; i++) {
    // from the lower left, over the top, to the lower right
    final a =
        math.pi * (1.08 + 0.84 * i / (around - 1)) +
        (r.nextDouble() - 0.5) * 0.18;
    final reach = 0.72 + r.nextDouble() * 0.22;
    final c = Offset(
      base.dx + math.cos(a) * crownR * reach,
      cy - math.sin(a) * crownH * 0.5 * reach + crownH * 0.04,
    );
    p.addOval(
      Rect.fromCircle(
        center: c,
        radius: lobeBase * (0.9 + r.nextDouble() * 0.45),
      ),
    );
  }
  for (var i = 0; i < 4; i++) {
    final c = Offset(
      base.dx + (r.nextDouble() * 2 - 1) * crownR * 0.42,
      cy + (r.nextDouble() * 2 - 1) * crownH * 0.18,
    );
    p.addOval(
      Rect.fromCircle(
        center: c,
        radius: lobeBase * (1.05 + r.nextDouble() * 0.4),
      ),
    );
  }
  // the very top of the crown, so the tree is exactly as tall as asked
  p.addOval(
    Rect.fromCircle(
      center: Offset(base.dx, base.dy - height + lobeBase * 0.95),
      radius: lobeBase * 0.95,
    ),
  );
  return p;
}
