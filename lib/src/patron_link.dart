// The Patron flag between the Véda apps on one phone: "this phone has a
// membership", so one Patron covers every app that carries ads (all but Cycle).
//
// Whichever app sees an active membership publishes it (active, and the date it
// runs to); every app reads whether ANY app on the phone has one. It names
// nothing about the person, never leaves the phone, and does not depend on the
// readings-sharing switches, because it is not personal data. On Android it
// travels through each app's link provider, on the iPhone through the App Group
// folder (IOS_LINK_PLAN.md). An app on a phone where neither works simply reads
// "no membership" and relies on its own purchase.

import 'dart:async';

import 'package:flutter/services.dart';

class PatronLink {
  PatronLink._();

  static const _channel = MethodChannel('com.aryavedics.veda_ui/link');

  /// Tells the other apps whether this app has an active membership. [app] is
  /// this app's id ("routine", "skin", ...); [until] is when it runs to, if known.
  static Future<void> publish({
    required String app,
    required bool active,
    DateTime? until,
  }) async {
    try {
      await _channel
          .invokeMethod('publishPatron', {
            'app': app,
            'active': active,
            if (until != null) 'until': until.toUtc().toIso8601String(),
          })
          .timeout(const Duration(seconds: 6));
    } catch (_) {
      // No plugin here, no App Group yet, or too slow: nothing to publish to.
    }
  }

  /// True if any Véda app on this phone has a membership that has not run out.
  static Future<bool> read() async {
    try {
      return (await _channel
              .invokeMethod<bool>('readPatron')
              .timeout(const Duration(seconds: 6))) ??
          false;
    } catch (_) {
      return false;
    }
  }
}
