import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veda_ui/veda_ui.dart';

const _sc = {'sleep': 88.0, 'movement': 40.0};

Widget _app(List<Widget> children) => MaterialApp(
  theme: vedaTheme(AppColors.nightfall),
  home: Scaffold(
    body: SingleChildScrollView(child: ChartCarousel(children: children)),
  ),
);

GroupMetricsCard _card(String title) => GroupMetricsCard(
  key: ValueKey(title),
  title: title,
  subtitle: 'sub',
  ghostKeys: const ['sleep', 'movement'],
  caveat: 'c',
  groups: const [GroupMetrics('Low', 3, null, _sc)],
);

/// How visible a card really is on screen right now (not what it is heading
/// towards), so a fade that never finishes shows up.
double _opacityOf(WidgetTester t, String title) {
  final fade = t.widget<FadeTransition>(
    find
        .ancestor(
          of: find.byKey(ValueKey(title)),
          matching: find.byType(FadeTransition),
        )
        .first,
  );
  return fade.opacity.value;
}

void main() {
  testWidgets('a swipe on a chart moves to the next card, not the chart', (
    t,
  ) async {
    await t.pumpWidget(_app([_card('first'), _card('second')]));
    await t.pumpAndSettle();
    expect(_opacityOf(t, 'first'), 1);
    // swipe across the chart area of the first card
    await t.fling(find.text('sub').first, const Offset(-300, 0), 1000);
    await t.pumpAndSettle();
    expect(_opacityOf(t, 'second'), 1);
    expect(_opacityOf(t, 'first'), 0);
  });

  testWidgets('the chart inside a card does not change its style by swipe', (
    t,
  ) async {
    await t.pumpWidget(_app([_card('first'), _card('second')]));
    await t.pumpAndSettle();
    final pages = t.widgetList<PageView>(find.byType(PageView));
    expect(pages, isNotEmpty);
    for (final p in pages) {
      expect(p.physics, isA<NeverScrollableScrollPhysics>());
    }
  });

  testWidgets('swiping back and forth keeps the right card showing', (t) async {
    await t.pumpWidget(_app([_card('first'), _card('second'), _card('third')]));
    await t.pumpAndSettle();
    const titles = ['first', 'second', 'third'];
    var page = 0;
    // forwards, back, forwards again: the card on screen must always be the
    // one the dots say, and the others must be gone, every time
    for (final dx in [-300.0, -300.0, 300.0, 300.0, -300.0, 300.0, -300.0]) {
      await t.fling(find.byType(ChartCarousel), Offset(dx, 0), 1000);
      await t.pumpAndSettle();
      page = (page + (dx < 0 ? 1 : -1)).clamp(0, 2);
      for (var i = 0; i < 3; i++) {
        expect(
          _opacityOf(t, titles[i]),
          i == page ? 1.0 : 0.0,
          reason: 'after swipe to page $page, card ${titles[i]}',
        );
      }
    }
  });

  testWidgets('a slow drag also moves to the next card', (t) async {
    await t.pumpWidget(_app([_card('first'), _card('second')]));
    await t.pumpAndSettle();
    final g = await t.startGesture(t.getCenter(find.byType(ChartCarousel)));
    for (var i = 0; i < 10; i++) {
      await g.moveBy(const Offset(-8, 0));
      await t.pump(const Duration(milliseconds: 120));
    }
    await g.up();
    await t.pumpAndSettle();
    expect(_opacityOf(t, 'second'), 1);
    expect(_opacityOf(t, 'first'), 0);
  });
}
