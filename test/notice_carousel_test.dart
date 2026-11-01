import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veda_ui/veda_ui.dart';

Widget _app({String Function(DateTime)? greeting}) => MaterialApp(
  theme: vedaTheme(AppColors.nightfall),
  home: Scaffold(
    body: NoticeCarousel(
      appKey: 'test',
      messages: const [
        NoticeMessage('a', PhosphorIconsThin.drop, 'First message'),
      ],
      leading: const Text('RING'),
      now: DateTime(2026, 10, 31, 9),
      greeting: greeting,
    ),
  ),
);

void main() {
  testWidgets('closing the last message leaves the ring and a greeting', (
    t,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await t.pumpWidget(_app(greeting: (n) => 'Good morning at ${n.hour}'));
    await t.pumpAndSettle();
    expect(find.text('First message'), findsOneWidget);

    await t.tap(find.byIcon(PhosphorIconsThin.x));
    await t.pumpAndSettle();
    expect(find.text('First message'), findsNothing);
    // the box is never empty: the greeting stays, with no x, beside the ring
    expect(find.text('RING'), findsOneWidget);
    expect(find.text('Good morning at 9'), findsOneWidget);
    expect(find.byIcon(PhosphorIconsThin.x), findsNothing);
  });

  testWidgets('without a greeting the ring still stays', (t) async {
    SharedPreferences.setMockInitialValues({});
    await t.pumpWidget(_app());
    await t.pumpAndSettle();
    await t.tap(find.byIcon(PhosphorIconsThin.x));
    await t.pumpAndSettle();
    expect(find.text('RING'), findsOneWidget);
  });
}
