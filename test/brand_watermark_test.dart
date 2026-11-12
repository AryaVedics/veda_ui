import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veda_ui/veda_ui.dart';

const _brand = VedaBrand(
  appName: 'Véda Test',
  word: 'TEST',
  markAsset: 'packages/veda_ui/assets/branding/veda_mark.png',
  ringTrack: Color(0xFF123456),
);

Future<double> _opacity(WidgetTester t, {required bool quiet}) async {
  await t.pumpWidget(
    MaterialApp(
      home: VedaBrandScope(
        brand: _brand,
        child: Scaffold(body: Stack(children: [BrandWatermark(quiet: quiet)])),
      ),
    ),
  );
  await t.pumpAndSettle();
  return t.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity;
}

void main() {
  testWidgets('the watermark is 5%, and 40% of that when quiet', (t) async {
    expect(await _opacity(t, quiet: false), closeTo(0.05, 1e-9));
    expect(await _opacity(t, quiet: true), closeTo(0.02, 1e-9));
  });

  testWidgets('it fades between the two instead of jumping', (t) async {
    Future<void> show(bool quiet) => t.pumpWidget(
      MaterialApp(
        home: VedaBrandScope(
          brand: _brand,
          child: Scaffold(
            body: Stack(children: [BrandWatermark(quiet: quiet)]),
          ),
        ),
      ),
    );
    await show(false);
    await t.pumpAndSettle();
    await show(true);
    await t.pump(const Duration(milliseconds: 125));
    final mid = t.renderObject<RenderBox>(find.byType(Image)).hasSize;
    expect(mid, isTrue);
    await t.pumpAndSettle();
    expect(
      t.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity,
      closeTo(0.02, 1e-9),
    );
  });
}
