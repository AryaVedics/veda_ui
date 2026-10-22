import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veda_ui/veda_ui.dart';

/// A pretend phone: one app's published feed, and the answers other apps'
/// providers would give.
class FakePhone {
  String? published;
  final Map<String, Map<String, Object?>> providers = {};

  Future<Object?> handle(MethodCall call) async {
    if (call.method == 'publish') {
      published = call.arguments['feed'] as String?;
      return true;
    }
    if (call.method == 'read') {
      return providers[call.arguments['authority']] ?? {'status': 'missing'};
    }
    throw MissingPluginException();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('test/link');
  late FakePhone phone;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    phone = FakePhone();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, phone.handle);
  });

  LinkBridge bridge(LinkApp app) => LinkBridge(app, channel: channel);

  test('nothing is served until sharing is turned on, and it stops when turned off', () async {
    final b = bridge(LinkApp.cycle);
    await b.load();
    await b.publish({'period_days': ['2026-10-01']});
    expect(phone.published, isNull); // sharing is off: nothing leaves the app

    await b.setShare(true);
    final feed = jsonDecode(phone.published!) as Map;
    expect(feed['schema'], 'veda-link/2');
    expect(feed['app'], 'cycle');
    expect((feed['data'] as Map)['period_days'], ['2026-10-01']);

    await b.setShare(false);
    expect(phone.published, isNull); // switched off: the feed is removed at once
  });

  test('the switches are remembered', () async {
    final b = bridge(LinkApp.sun);
    await b.load();
    await b.setShare(true);
    await b.setUse(true);
    final again = bridge(LinkApp.sun);
    await again.load();
    expect(again.share, isTrue);
    expect(again.use, isTrue);
  });

  test('reading another app reports exactly what happened', () async {
    phone.providers['com.aryavedics.cycle.link'] = {
      'status': 'ok',
      'feed': jsonEncode({
        'schema': 'veda-link/2',
        'app': 'cycle',
        'data': {'phase': 'luteal'}
      }),
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };
    phone.providers['com.aryavedics.sun.link'] = {'status': 'empty'};
    phone.providers['com.aryavedics.lifestyle.link'] = {'status': 'denied'};

    final b = bridge(LinkApp.routine);
    await b.load();
    await b.refresh();
    expect(b.readOf(LinkApp.cycle).status, LinkStatus.unknown); // reading is off

    await b.setUse(true);
    expect(b.readOf(LinkApp.cycle).status, LinkStatus.connected);
    expect(b.feedOf(LinkApp.cycle)!.data['phase'], 'luteal');
    expect(b.readOf(LinkApp.sun).status, LinkStatus.sharingOff);
    expect(b.readOf(LinkApp.lifestyle).status, LinkStatus.notAllowed);
    expect(b.readOf(LinkApp.skin).status, LinkStatus.notInstalled);
    expect(b.others, isNot(contains(LinkApp.routine)));

    await b.setUse(false);
    expect(b.feedOf(LinkApp.cycle), isNull); // reading off: everything forgotten
  });
}
