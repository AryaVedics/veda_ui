import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veda_ui/veda_ui.dart';

Widget _chart(List<TrendDay> days) => MaterialApp(
  theme: vedaTheme(AppColors.nightfall),
  home: Scaffold(
    body: SingleChildScrollView(child: TrendChart(days: days)),
  ),
);

void main() {
  final first = DateTime(2026, 10, 1);
  List<TrendDay> days(
    Map<int, List<TrendMark>> marks, {
    Set<int> plain = const {},
  }) => [
    for (var i = 0; i < 30; i++)
      TrendDay(
        DateTime(first.year, first.month, first.day + i),
        score: 60.0 + i,
        marked: plain.contains(i) || (marks[i]?.isNotEmpty ?? false),
        marks: marks[i] ?? const [],
      ),
  ];

  testWidgets('coloured dots and diamonds draw without trouble', (t) async {
    t.view.physicalSize = const Size(420, 700);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      _chart(
        days({
          5: const [TrendMark(Color(0xFFE97878))],
          12: const [TrendMark(Color(0xFF22C2D3), diamond: true)],
          // several on one day, side by side (more than three are cut to three)
          20: const [
            TrendMark(Color(0xFFA789EC)),
            TrendMark(Color(0xFF21CC21), diamond: true),
            TrendMark(Color(0xFFE870B8)),
            TrendMark(Color(0xFF7B9CCD)),
          ],
        }),
      ),
    );
    await t.pump();
    expect(t.takeException(), isNull);
    expect(find.byType(TrendChart), findsOneWidget);
  });

  testWidgets('a day with the plain mark and no colours still draws', (
    t,
  ) async {
    await t.pumpWidget(_chart(days(const {}, plain: {3, 9})));
    await t.pump();
    expect(t.takeException(), isNull);
  });

  testWidgets('the key can name the measurement being followed', (t) async {
    await t.pumpWidget(
      MaterialApp(
        theme: vedaTheme(AppColors.nightfall),
        home: Scaffold(
          body: TrendChart(days: days(const {}), scoreLabel: 'Redness'),
        ),
      ),
    );
    await t.pump();
    expect(find.text('Redness'), findsOneWidget);
    expect(find.text('Skin Score'), findsNothing);
  });

  test('marks carry a colour and a shape', () {
    const m = TrendMark(Color(0xFF123456), diamond: true);
    expect(m.color, const Color(0xFF123456));
    expect(m.diamond, isTrue);
    expect(const TrendMark(Color(0xFF000000)).diamond, isFalse);
  });
}
