// Each Véda app's own sign, the same wherever one app is shown among the
// others: Véda Today's clock, the Véda Link list, a Profile row. All drawn in
// the Véda line icons (see line_icons.dart), so they share one line weight;
// Véda itself is its medallion.

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'line_icons.dart';

/// The sign of the app called [id] ('skin' for Véda, then 'routine', 'sun',
/// 'allergy', 'sleep', 'lifestyle', 'kitchen', 'curio', 'hair', 'garden',
/// 'learn', 'cycle', 'today'), [size] across, in [color] (Véda's medallion
/// keeps its own gold).
Widget vedaAppGlyph(String id, Color color, {double size = 22}) {
  final icon = vedaIconForApp(id);
  if (icon != null) return VedaLineIcon(icon, color: color, size: size);
  return SizedBox.square(
    dimension: size,
    child: FittedBox(
      child: id == 'skin'
          ? Image.asset(
              'packages/veda_ui/assets/branding/veda_mark.png',
              width: 24,
              height: 24,
              filterQuality: FilterQuality.medium,
            )
          : Icon(PhosphorIconsThin.circle, color: color),
    ),
  );
}
