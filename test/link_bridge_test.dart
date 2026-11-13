import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veda_ui/veda_ui.dart';

/// A pretend phone: one app's published feed, and the answers other apps'
/// providers would give.
class FakePhone {
  String? published;
  List<Object?>? blocked;
  final Map<String, Map<String, Object?>> providers = {};
  final List<String> asked = [];

  Future<Object?> handle(MethodCall call) async {
    if (call.method == 'publish') {
      published = call.arguments['feed'] as String?;
      blocked = call.arguments['blocked'] as List?;
      return true;
    }
    if (call.method == 'read') {
      asked.add(call.arguments['authority'] as String);
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

  test('one app at a time: unlink keeps that pair apart, link one alone, connect all', () async {
    phone.providers['com.aryavedics.skin.link'] = {
      'status': 'ok',
      'feed': jsonEncode({
        'data': {'readings': []},
      }),
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };
    phone.providers['com.aryavedics.routine.link'] = {
      'status': 'ok',
      'feed': jsonEncode({
        'data': {'products': []},
      }),
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };
    final b = bridge(LinkApp.lifestyle);
    await b.load();
    await b.publish({'days': {}});
    expect(b.linkedCount, 0);

    // Linking Véda alone connects Véda only: the others stay apart.
    await b.setLinked(LinkApp.skin, true);
    expect(b.isLinked(LinkApp.skin), isTrue);
    expect(b.isLinked(LinkApp.routine), isFalse);
    expect(b.linkedCount, 1);
    expect(b.readOf(LinkApp.skin).status, LinkStatus.connected);
    expect(b.readOf(LinkApp.routine).status, LinkStatus.unlinked);
    expect(phone.published, isNotNull);
    expect(
      phone.blocked,
      containsAll([
        'com.aryavedics.sun',
        'com.aryavedics.routine',
      ]),
    );
    expect(phone.blocked, isNot(contains('com.aryavedics.skin')));

    // Connect all: every pair, nothing blocked.
    await b.connectAll(true);
    expect(b.linkedCount, b.others.length);
    expect(phone.blocked, isEmpty);
    expect(b.readOf(LinkApp.routine).status, LinkStatus.connected);

    // Unlink Routine: its feed is no longer read, and it is turned away from ours.
    await b.setLinked(LinkApp.routine, false);
    expect(b.isLinked(LinkApp.routine), isFalse);
    expect(b.readOf(LinkApp.routine).status, LinkStatus.unlinked);
    expect(b.feedOf(LinkApp.routine), isNull);
    expect(phone.blocked, ['com.aryavedics.routine']);

    // It is remembered.
    final again = bridge(LinkApp.lifestyle);
    await again.load();
    expect(again.isLinked(LinkApp.routine), isFalse);
    expect(again.isLinked(LinkApp.skin), isTrue);

    // Unlinking the very last one is the same as connecting nothing.
    for (final app in b.others) {
      await b.setLinked(app, false);
    }
    expect(b.share, isFalse);
    expect(b.use, isFalse);
    expect(phone.published, isNull);
  });

  test('nothing is served until sharing is turned on, and it stops when turned off', () async {
    final b = bridge(LinkApp.lifestyle);
    await b.load();
    await b.publish({
      'days': ['2026-10-01'],
    });
    expect(phone.published, isNull); // sharing is off: nothing leaves the app

    await b.setShare(true);
    final feed = jsonDecode(phone.published!) as Map;
    expect(feed['schema'], 'veda-link/2');
    expect(feed['app'], 'lifestyle');
    expect((feed['data'] as Map)['days'], ['2026-10-01']);

    await b.setShare(false);
    expect(
      phone.published,
      isNull,
    ); // switched off: the feed is removed at once
  });

  test('Véda Cycle reads and never shares, whatever is switched on', () async {
    // an older version published a feed and left the switch on
    SharedPreferences.setMockInitialValues({'veda_link_share': true});
    phone.published = '{"old": "feed"}';
    final b = bridge(LinkApp.cycle);
    await b.load();
    expect(phone.published, isNull); // what an older version left is removed
    expect(b.share, isFalse);

    await b.publish({
      'period_days': ['2026-10-01'],
    });
    await b.setShare(true);
    await b.connectAll(true);
    expect(b.share, isFalse);
    expect(phone.published, isNull); // nothing is ever served

    // it can still read the others, and the others do not list it
    expect(b.use, isTrue);
    expect(b.others, isNot(contains(LinkApp.cycle)));
    expect(b.isLinked(LinkApp.skin), isTrue);
    for (final self in LinkApp.values.where((a) => a.publishes)) {
      expect(bridge(self).others, isNot(contains(LinkApp.cycle)));
    }
  });

  test('an app asks only for the feeds it uses, and still lists and links the rest', () async {
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final id in ['skin', 'sun', 'routine']) {
      phone.providers['com.aryavedics.$id.link'] = {
        'status': 'ok',
        'feed': jsonEncode({'data': {}}),
        'updated_at': now,
      };
    }
    final b = LinkBridge(
      LinkApp.lifestyle,
      reads: {LinkApp.skin, LinkApp.sun},
      channel: channel,
    );
    await b.load();
    await b.publish({'days': {}});
    await b.connectAll(true);
    expect(phone.asked.toSet(), {
      'com.aryavedics.skin.link',
      'com.aryavedics.sun.link',
    }, reason: 'Routine is linked but its entries are never fetched');
    expect(b.readOf(LinkApp.sun).status, LinkStatus.connected);
    expect(b.readOf(LinkApp.routine).status, LinkStatus.notRead);
    expect(b.feedOf(LinkApp.routine), isNull);
    // Still listed and counted, so the person can link or unlink it.
    expect(b.others, containsAll([LinkApp.skin, LinkApp.sun, LinkApp.routine]));
    expect(b.linkedCount, 3);
    // Cycle shares nothing: never listed as a source, never asked.
    expect(b.others, isNot(contains(LinkApp.cycle)));
    expect(phone.asked, isNot(contains('com.aryavedics.cycle.link')));
    // An unlinked app is turned away, as before.
    phone.asked.clear();
    await b.setLinked(LinkApp.sun, false);
    await b.refresh();
    expect(phone.asked, ['com.aryavedics.skin.link']);
    expect(b.readOf(LinkApp.sun).status, LinkStatus.unlinked);
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
    phone.providers['com.aryavedics.routine.link'] = {
      'status': 'ok',
      'feed': jsonEncode({
        'schema': 'veda-link/2',
        'app': 'routine',
        'data': {'products': 3},
      }),
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };
    phone.providers['com.aryavedics.sun.link'] = {'status': 'empty'};
    phone.providers['com.aryavedics.lifestyle.link'] = {'status': 'denied'};
    phone.providers['com.aryavedics.skin.link'] = {'status': 'old_version'};

    final b = bridge(LinkApp.cycle);
    await b.load();
    await b.refresh();
    expect(
      b.readOf(LinkApp.routine).status,
      LinkStatus.unknown,
    ); // reading is off

    await b.setUse(true);
    expect(b.readOf(LinkApp.routine).status, LinkStatus.connected);
    expect(b.feedOf(LinkApp.routine)!.data['products'], 3);
    expect(b.readOf(LinkApp.sun).status, LinkStatus.sharingOff);
    expect(b.readOf(LinkApp.lifestyle).status, LinkStatus.notAllowed);
    expect(b.readOf(LinkApp.skin).status, LinkStatus.oldVersion);
    expect(b.others, isNot(contains(LinkApp.cycle)));

    await b.setUse(false);
    expect(
      b.feedOf(LinkApp.routine),
      isNull,
    ); // reading off: everything forgotten
  });

  test(
    'a switch moves the moment it is tapped, before the slow work finishes',
    () async {
      final b = bridge(LinkApp.lifestyle);
      await b.load();
      var told = 0;
      b.addListener(() => told++);
      final pending = b.setShare(true); // not awaited on purpose
      expect(b.share, isTrue); // already on
      expect(told, greaterThanOrEqualTo(1)); // and the screen has been told
      await pending;
      final pending2 = b.setUse(true);
      expect(b.use, isTrue);
      expect(
        b.readOf(LinkApp.skin).status,
        LinkStatus.unknown,
      ); // "checking…" at once
      await pending2;
    },
  );

  test('live readings from Veda fill the charts, and the same readings again change nothing', () async {
    final store = VedaLinkStore(file: MemoryJsonFile());
    await store.load();
    final data = {
      'readings': [
        {
          'taken_at': '2026-10-20T14:00:00.000Z',
          'slot': 'midday',
          'skin_score': 86,
          'scores': {'redness': 84},
        },
        {
          'taken_at': '2026-10-19T08:00:00.000Z',
          'slot': 'morning',
          'skin_score': 80,
          'scores': {'redness': 78},
        },
        {'bad': 'row'},
      ],
    };
    expect(await store.takeLive(data), isTrue);
    expect(store.data.readings, hasLength(2));
    expect(store.data.readings.first.slot, 'morning'); // oldest first
    expect(await store.takeLive(data), isFalse);
  });
}
