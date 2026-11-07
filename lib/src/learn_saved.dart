// Copy of Véda's template (flutter_app/lib/data/learn_saved.dart). Keep in step.
//
// Kept only on this phone: nothing is sent anywhere, and it is not part of any
// backup.

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LearnSaved {
  LearnSaved._();

  static const _key = 'learn_saved';

  /// The ids of the saved notes. A listener hears when a note is saved or let go.
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

  /// Saves the note, or lets it go if it was saved.
  static Future<void> toggle(String id) async {
    final next = {...ids.value};
    if (!next.remove(id)) next.add(id);
    ids.value = next;
    try {
      await (await SharedPreferences.getInstance()).setStringList(
        _key,
        next.toList(),
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
