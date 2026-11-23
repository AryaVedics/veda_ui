import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veda_ui/veda_ui.dart';

const _ink = Color(0xFF1F2330);
const _muted = Color(0xFFB3B8C8);
const _gold = Color(0xFFE8C86A);

Widget _sheet() => MaterialApp(
  debugShowCheckedModeBanner: false,
  home: Scaffold(
    backgroundColor: _ink,
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 10,
        runSpacing: 14,
        children: [
          for (final icon in VedaIcon.values)
            SizedBox(
              width: 118,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // at tab size, idle and selected
                      VedaLineIcon(icon, color: _muted),
                      VedaLineIcon(icon, color: _gold, selected: true),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // large, to judge the drawing
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      VedaLineIcon(icon, color: _muted, size: 48),
                      VedaLineIcon(
                        icon,
                        color: _gold,
                        selected: true,
                        size: 48,
                      ),
                    ],
                  ),
                  Text(
                    icon.name,
                    style: const TextStyle(color: _muted, fontSize: 11),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  ),
);

void main() {
  testWidgets('every icon draws, idle and selected', (t) async {
    await t.pumpWidget(_sheet());
    expect(
      find.byType(VedaLineIcon),
      findsNWidgets(VedaIcon.values.length * 4),
    );
    expect(t.takeException(), isNull);
  });

  test('each app has its sign, and Véda is its medallion', () {
    for (final id in const [
      'today',
      'routine',
      'sun',
      'allergy',
      'sleep',
      'lifestyle',
      'kitchen',
      'curio',
      'hair',
      'garden',
      'learn',
      'cycle',
    ]) {
      expect(vedaIconForApp(id), isNotNull, reason: id);
    }
    expect(vedaIconForApp('skin'), isNull);
  });

  // the contact sheet, to look at (skipped in normal runs):
  // flutter test test/line_icons_test.dart --run-skipped --update-goldens
  testWidgets('contact sheet', (t) async {
    t.view.physicalSize = const Size(1340, 1300);
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    await t.pumpWidget(_sheet());
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/line_icons.png'),
    );
  }, skip: true);
}
