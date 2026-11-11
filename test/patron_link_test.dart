import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veda_ui/veda_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.aryavedics.veda_ui/link');
  final calls = <MethodCall>[];

  void answer(Future<Object?> Function(MethodCall) handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (c) {
          calls.add(c);
          return handler(c);
        });
  }

  setUp(calls.clear);
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(
    'publish sends the app, whether it is active, and when it runs to',
    () async {
      answer((_) async => true);
      await PatronLink.publish(
        app: 'routine',
        active: true,
        until: DateTime.utc(2027, 1, 2, 3),
      );
      expect(calls.single.method, 'publishPatron');
      expect(calls.single.arguments['app'], 'routine');
      expect(calls.single.arguments['active'], isTrue);
      expect(calls.single.arguments['until'], '2027-01-02T03:00:00.000Z');
    },
  );

  test(
    'a membership that ended is published as not active, with no date',
    () async {
      answer((_) async => true);
      await PatronLink.publish(app: 'skin', active: false);
      expect(calls.single.arguments['active'], isFalse);
      expect(calls.single.arguments.containsKey('until'), isFalse);
    },
  );

  test('read says what the phone answers', () async {
    answer((_) async => true);
    expect(await PatronLink.read(), isTrue);
    answer((_) async => false);
    expect(await PatronLink.read(), isFalse);
  });

  test(
    'no plugin, an error or no answer means no membership, never a free one',
    () async {
      // nothing answering at all (a platform without the plugin)
      expect(await PatronLink.read(), isFalse);
      await PatronLink.publish(app: 'routine', active: true); // must not throw
      answer((_) async => throw PlatformException(code: 'x'));
      expect(await PatronLink.read(), isFalse);
      answer((_) async => null);
      expect(await PatronLink.read(), isFalse);
    },
  );
}
