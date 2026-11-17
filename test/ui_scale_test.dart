import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veda_ui/veda_ui.dart';

/// The same 1080-pixel-wide screen at two display-size settings: 360 dp across
/// (density 3.0) and about 485 dp across (density 2.225), as on a Samsung S21
/// at its standard setting and a Pixel 10a set to a smaller display size.
Future<double> _ringPixels(WidgetTester t, double widthDp, double dpr) async {
  late double size;
  await t.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: Size(widthDp, 1000), devicePixelRatio: dpr),
      child: Builder(
        builder: (context) {
          size = miniRingSizeOf(context);
          return const SizedBox();
        },
      ),
    ),
  );
  return size * dpr;
}

void main() {
  testWidgets('the ring is the same size on the glass at either display size', (
    t,
  ) async {
    final samsung = await _ringPixels(t, 360, 3.0);
    final pixel = await _ringPixels(t, 1080 / 2.225, 2.225);
    expect(samsung, closeTo(pixel, pixel * 0.02));
    // and smaller than the old fixed 132 dp, which was 396 px on the Samsung
    expect(samsung, lessThan(132 * 3.0));
  });

  testWidgets('the scale stays within its limits on tiny and huge screens', (
    t,
  ) async {
    await t.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(200, 400)),
        child: Builder(
          builder: (context) {
            expect(uiScaleOf(context), 0.82);
            return const SizedBox();
          },
        ),
      ),
    );
    await t.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(1000, 800)),
        child: Builder(
          builder: (context) {
            expect(uiScaleOf(context), 1.2);
            return const SizedBox();
          },
        ),
      ),
    );
  });
}
