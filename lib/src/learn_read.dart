// Copy of Véda's template (flutter_app/lib/data/learn_read.dart). Keep in step.
//
// Kept only on this phone: nothing is sent anywhere, and it is not part of any
// backup.

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LearnRead {
  LearnRead._();

  static const _key = 'learn_read';

  /// The ids of the notes opened. A listener hears when one is added.
  static final ValueNotifier<Set<String>> ids = ValueNotifier(<String>{});

  static bool _loaded = false;

  /// Reads what was kept. Safe to call again.
  static Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final saved =
          (await SharedPreferences.getInstance()).getStringList(_key) ??
          const <String>[];
      ids.value = {...saved, ...ids.value};
    } catch (_) {
      // none kept, as if new
    }
  }

  /// Notes that this note has been opened. Kept only on this phone.
  static Future<void> mark(String id) async {
    if (ids.value.contains(id)) return;
    ids.value = {...ids.value, id};
    try {
      await (await SharedPreferences.getInstance()).setStringList(
        _key,
        ids.value.toList(),
      );
    } catch (_) {
      // kept for this run
    }
  }

  /// For tests: back to nothing saved and not yet loaded.
  @visibleForTesting
  static void reset() {
    _loaded = false;
    ids.value = <String>{};
  }
}
