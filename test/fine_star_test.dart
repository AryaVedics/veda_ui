import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veda_ui/veda_ui.dart';

// The family's star (Lifestyle's twinkling star, shared): what it draws.

Future<ByteData> _draw(
  double v,
  double tw,
  double scale, {
  double minRay = 1.0,
  double heartScale = 1.0,
}) async {
  final rec = ui.PictureRecorder();
  final canvas = Canvas(rec);
  paintFineStar(
    canvas,
    const Offset(100, 100),
    v,
    tw,
    scale,
    minRay: minRay,
    heartScale: heartScale,
  );
  final img = await rec.endRecording().toImage(200, 200);
  return (await img.toByteData())!;
}

int _alpha(ByteData d, int x, int y) => d.getUint8((y * 200 + x) * 4 + 3);

void main() {
  testWidgets('a star is a halo, a heart and eight rays', (t) async {
    await t.runAsync(() async {
      final d = await _draw(0.6, 0.5, 1);
      expect(_alpha(d, 100, 100), greaterThan(200)); // the heart
      expect(_alpha(d, 100 + 20, 100), greaterThan(0)); // a long ray, across
      expect(_alpha(d, 100, 100 + 20), greaterThan(0)); // a long ray, down
      expect(_alpha(d, 100 + 9, 100 + 9), greaterThan(0)); // a short diagonal
      expect(_alpha(d, 1, 1), 0); // nothing out at the corner
    });
  });

  testWidgets('a brighter star is larger, and a smaller scale is smaller', (
    t,
  ) async {
    await t.runAsync(() async {
      int reach(ByteData d) {
        var n = 0;
        for (var x = 100; x < 200; x++) {
          if (_alpha(d, x, 100) > 8) n = x - 100;
        }
        return n;
      }

      final dim = reach(await _draw(0.2, 0.5, 1));
      final bright = reach(await _draw(0.9, 0.5, 1));
      final small = reach(await _draw(0.9, 0.5, 0.25));
      expect(bright, greaterThan(dim));
      expect(small, lessThan(bright));
    });
  });

  testWidgets('a small star can have fine rays and a small heart', (t) async {
    await t.runAsync(() async {
      final big = await _draw(0.5, 0.5, 0.26);
      final fine = await _draw(0.5, 0.5, 0.26, minRay: 0.4, heartScale: 0.2);
      // the heart is smaller: a pixel two out from the middle is lit by the
      // heart in one and barely in the other
      int lit(ByteData d) {
        var n = 0;
        for (var y = 94; y <= 106; y++) {
          for (var x = 94; x <= 106; x++) {
            if (_alpha(d, x, y) > 200) n++;
          }
        }
        return n;
      }

      expect(lit(fine), lessThan(lit(big)));
    });
  });
}
