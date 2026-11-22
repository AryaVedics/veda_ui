// Each Véda app's own sign, the same wherever one app is shown among the
// others: Véda Today's clock, the Véda Link list, a Profile row. Mostly each
// app's own tab icon (Allergy's tree, Lifestyle's heart with its pulse,
// Routine's shelf, Hair's circle of braid, Garden's ring of flowering vine);
// Véda itself is its medallion.

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'garden_glyph.dart';
import 'hair_glyph.dart';
import 'heart_pulse_icon.dart';
import 'shelf_glyph.dart';
import 'tree_tab_icon.dart';

/// The sign of the app called [id] ('skin' for Véda, then 'routine', 'sun',
/// 'allergy', 'sleep', 'lifestyle', 'kitchen', 'curio', 'hair', 'garden',
/// 'learn', 'cycle', 'today'), [size] across, in [color] (Véda's medallion
/// keeps its own gold).
Widget vedaAppGlyph(String id, Color color, {double size = 22}) =>
    SizedBox.square(
      dimension: size,
      child: FittedBox(
        child: switch (id) {
          'skin' => Image.asset(
            'packages/veda_ui/assets/branding/veda_mark.png',
            width: 24,
            height: 24,
            filterQuality: FilterQuality.medium,
          ),
          'routine' => ShelfGlyph(color: color),
          'sun' => Icon(PhosphorIconsThin.sun, color: color),
          'allergy' => TreeTabIcon(selected: false, color: color),
          'sleep' => Icon(PhosphorIconsThin.moonStars, color: color),
          'lifestyle' => HeartPulseIcon(selected: false, color: color),
          'kitchen' => Icon(PhosphorIconsThin.cookingPot, color: color),
          'curio' => Icon(PhosphorIconsThin.pill, color: color),
          'hair' => HairGlyph(selected: false, color: color),
          'garden' => GardenGlyph(selected: false, color: color),
          'learn' => Icon(PhosphorIconsThin.bookOpen, color: color),
          'cycle' => Icon(PhosphorIconsThin.flowerLotus, color: color),
          'today' => Icon(PhosphorIconsThin.sunHorizon, color: color),
          _ => Icon(PhosphorIconsThin.circle, color: color),
        },
      ),
    );
