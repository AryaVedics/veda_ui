import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veda_ui/veda_ui.dart';

Widget _app({bool? showOpenVeda}) => MaterialApp(
  theme: vedaTheme(AppColors.nightfall),
  home: LogoMenuScope(
    items: const [],
    showOpenVeda: showOpenVeda ?? true,
    child: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => showLogoMenu(context),
            child: const Text('logo'),
          ),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('the menu offers Open Véda unless an app turns it off', (
    t,
  ) async {
    await t.pumpWidget(_app());
    await t.tap(find.text('logo'));
    await t.pumpAndSettle();
    expect(find.text('Open Véda'), findsOneWidget);
    expect(find.text('Our website'), findsOneWidget);
  });

  testWidgets('with it off, the rest of the menu is unchanged', (t) async {
    await t.pumpWidget(_app(showOpenVeda: false));
    await t.tap(find.text('logo'));
    await t.pumpAndSettle();
    expect(find.text('Open Véda'), findsNothing);
    expect(find.text('Our website'), findsOneWidget);
    expect(find.text('Support'), findsOneWidget);
  });
}
