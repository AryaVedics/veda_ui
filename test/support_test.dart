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
}
