import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veda_ui/veda_ui.dart';

void main() {
  Widget host(Widget child) => MaterialApp(
    theme: vedaTheme(AppColors.nightfall),
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets("shows today's day of the month on a calendar", (t) async {
    await t.pumpWidget(
      host(const TodayTabIcon(selected: false, color: Colors.white)),
    );
    expect(find.text('${DateTime.now().day}'), findsOneWidget);
  });

  testWidgets('the selected icon shows the same day', (t) async {
    await t.pumpWidget(
      host(const TodayTabIcon(selected: true, color: Colors.amber)),
    );
    expect(find.text('${DateTime.now().day}'), findsOneWidget);
  });
}
