import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veda_ads/veda_ads.dart';

// With ads off (the default for tests and beta builds) the banner shows nothing
// and never touches the ad library or the membership check.
void main() {
  testWidgets('with ads off the banner is empty and asks nothing', (t) async {
    var asked = false;
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AdBanner(
            isMember: ValueNotifier(false),
            membershipReady: () async => asked = true,
          ),
        ),
      ),
    );
    await t.pump();
    expect(find.byType(SizedBox), findsWidgets);
    expect(asked, isFalse);
    expect(VedaAds.enabled, isFalse);
  });

  test('the default ad units are Google test units', () {
    expect(
      VedaAds.androidBannerUnit,
      startsWith('ca-app-pub-3940256099942544/'),
    );
    expect(VedaAds.iosBannerUnit, startsWith('ca-app-pub-3940256099942544/'));
  });
}
