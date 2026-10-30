import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veda_ui/veda_ui.dart';

Widget _app(List<Widget> children) => MaterialApp(
  theme: vedaTheme(AppColors.nightfall),
  home: Scaffold(
    body: SingleChildScrollView(child: ChartCarousel(children: children)),
  ),
);

Widget _card(String name, double h) =>
    SizedBox(height: h, width: double.infinity, child: Text(name));

void main() {
  testWidgets('a single chart is shown as it is, with no dots', (t) async {
    await t.pumpWidget(_app([_card('only', 100)]));
    expect(find.text('only'), findsOneWidget);
    expect(find.byKey(const Key('carouselDot0')), findsNothing);
  });

  testWidgets('dots and swipes move between the cards', (t) async {
    await t.pumpWidget(_app([_card('one', 100), _card('two', 200)]));
    expect(find.byKey(const Key('carouselDot1')), findsOneWidget);

    // tap the second dot
    await t.tap(find.byKey(const Key('carouselDot1')));
    await t.pumpAndSettle();
    final two = t.widget<AnimatedOpacity>(
      find
          .ancestor(
            of: find.text('two'),
            matching: find.byType(AnimatedOpacity),
          )
          .first,
    );
    expect(two.opacity, 1);

    // swipe back to the first
    await t.fling(find.text('two'), const Offset(300, 0), 1000);
    await t.pumpAndSettle();
    final one = t.widget<AnimatedOpacity>(
      find
          .ancestor(
            of: find.text('one'),
            matching: find.byType(AnimatedOpacity),
          )
          .first,
    );
    expect(one.opacity, 1);
  });

  testWidgets('the carousel is as tall as its tallest card', (t) async {
    await t.pumpWidget(_app([_card('one', 100), _card('two', 260)]));
    final stack = find.descendant(
      of: find.byType(ChartCarousel),
      matching: find.byType(Stack),
    );
    expect(t.getSize(stack.first).height, 260);
  });
}
