import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veda_ui/veda_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the support email carries the app and the phone, and what the caller adds, nothing more', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('com.aryavedics.veda_ui/link'),
          (call) async => call.method == 'deviceInfo'
              ? {
                  'version': '0.7.0',
                  'build': 19,
                  'model': 'Google Pixel 10a',
                  'android': '16',
                }
              : null,
        );
    final text = await supportDiagnostics(
      'Véda Lifestyle',
      problem: 'Restore failed',
      extra: {'Linked apps': '1 of 4'},
    );
    expect(text, contains('App: Véda Lifestyle 0.7.0 (build 19)'));
    expect(text, contains('Phone: Google Pixel 10a, Android 16'));
    expect(text, contains('Problem: Restore failed'));
    expect(text, contains('Linked apps: 1 of 4'));
    expect(kSupportEmail, 'support@aryavedics.com');
  });

  test('still works on a phone that cannot answer', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('com.aryavedics.veda_ui/link'),
          null,
        );
    final text = await supportDiagnostics('Véda Sun');
    expect(text, contains('App: Véda Sun'));
    expect(text, contains('Phone: unknown'));
  });

  test('on an Android phone the lines come from what the phone reports', () {
    expect(
      supportAppLines('Véda Routine', {
        'version': '0.8.33',
        'build': '51',
        'model': 'Pixel 10a',
        'android': '17',
      }),
      ['App: Véda Routine 0.8.33 (build 51)', 'Phone: Pixel 10a, Android 17'],
    );
  });

  test('on an iPhone it uses the version the build was given, and never says Android', () {
    final lines = supportAppLines(
      'Véda Routine',
      const {},
      ios: true,
      osVersion: 'Version 18.1 (Build 22B83)',
      appVersion: '0.8.33+51',
    );
    expect(lines, [
      'App: Véda Routine 0.8.33+51',
      'Phone: iPhone, Version 18.1 (Build 22B83)',
    ]);
    expect(lines.join(), isNot(contains('Android')));
  });

  test('on an iPhone with nothing known it still reads cleanly', () {
    expect(supportAppLines('Véda Routine', const {}, ios: true), [
      'App: Véda Routine',
      'Phone: iPhone',
    ]);
  });
}
