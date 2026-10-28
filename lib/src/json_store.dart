// The one place each companion app's data lives: a single JSON file in the
// app's own storage on the phone. Nothing is sent anywhere. Deleting the app
// deletes the file; "Delete everything" in Profile does the same without
// uninstalling. Same rules as Routine's store:
//
//  * written to a side file and moved over the old one, so a crash mid-write
//    never leaves half a file;
//  * saves are queued, one at a time and in order, and only the newest state is
//    ever written, so two saves close together can never leave the older one
//    on disk over the newer (which lost a whole day after a restart);
//  * a file that could not be read is never overwritten (loadFailed), so
//    someone's data is never silently replaced by an empty one.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Where the JSON text is kept. A file on the phone in the app; memory in tests.
abstract class JsonFile {
  Future<String?> read();
  Future<void> write(String text);
  Future<void> delete();
}

class DocumentsJsonFile implements JsonFile {
  DocumentsJsonFile(this.name);

  static var _writeSeq = 0;

  /// The file name in the app's documents folder, e.g. "sun.json".
  final String name;

  Future<File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$name');
  }

  @override
  Future<String?> read() async {
    final f = await _file;
    return await f.exists() ? f.readAsString() : null;
  }

  @override
  Future<void> write(String text) async {
    final f = await _file;
    // its own side file for each write, so two writes never share one
    final tmp = File('${f.path}.${_writeSeq++}.tmp');
    await tmp.writeAsString(text, flush: true);
    await tmp.rename(f.path);
  }

  @override
  Future<void> delete() async {
    final f = await _file;
    if (await f.exists()) await f.delete();
  }
}

class MemoryJsonFile implements JsonFile {
  MemoryJsonFile([this.text]);
  String? text;

  @override
  Future<String?> read() async => text;

  @override
  Future<void> write(String t) async => text = t;

  @override
  Future<void> delete() async => text = null;
}

/// A store holding one immutable data value [T] that round-trips through JSON.
abstract class JsonStore<T> extends ChangeNotifier {
  JsonStore(this._file, {DateTime Function()? clock})
    : clock = clock ?? DateTime.now;

  final JsonFile _file;
  final DateTime Function() clock;

  /// The value when the file is empty or missing.
  T get empty;
  T fromJson(Map<String, Object?> json);
  Map<String, Object?> toJson(T value);

  late T _data = empty;
  T get data => _data;

  bool _loaded = false;
  bool get loaded => _loaded;

  /// Set when the saved file could not be read.
  bool loadFailed = false;

  int _seq = 0;
  String newId() =>
      '${clock().microsecondsSinceEpoch.toRadixString(36)}${(_seq++).toRadixString(36)}';

  Future<void> load() async {
    try {
      final text = await _file.read();
      if (text != null && text.isNotEmpty) {
        _data = fromJson((jsonDecode(text) as Map).cast<String, Object?>());
      }
    } catch (e) {
      debugPrint('Data could not be read: $e');
      loadFailed = true;
    }
    _loaded = true;
    notifyListeners();
  }

  @protected
  Future<void> set(T next) async {
    _data = next;
    notifyListeners();
    if (loadFailed) return;
    await _save();
  }

  var _saveGen = 0;
  Future<void> _saving = Future.value();

  /// Writes the data to the file: after any save already running, and only if
  /// no newer save has been asked for since (that one writes the newest state,
  /// which includes this one's changes).
  Future<void> _save() {
    final gen = ++_saveGen;
    return _saving = _saving.then((_) async {
      if (gen != _saveGen || loadFailed) return;
      // a write that fails is tried again; it never stops the saves behind it
      for (var attempt = 0; attempt < 3; attempt++) {
        try {
          await _file.write(jsonEncode(toJson(_data)));
          saveFailed = false;
          return;
        } catch (e) {
          debugPrint('Saving failed (try ${attempt + 1}): $e');
          await Future<void>.delayed(
            Duration(milliseconds: 150 * (attempt + 1)),
          );
          if (gen != _saveGen) return; // a newer save will write instead
        }
      }
      saveFailed = true;
    });
  }

  /// Set when the last save could not be written even after trying again.
  bool saveFailed = false;

  String exportJson() =>
      const JsonEncoder.withIndent('  ').convert(toJson(_data));

  /// Replaces everything with a backup's [json]. A file that could not be read
  /// no longer blocks saving once the person has chosen to restore.
  Future<void> restoreJson(String json) async {
    final next = fromJson((jsonDecode(json) as Map).cast<String, Object?>());
    loadFailed = false;
    await set(next);
  }

  Future<void> deleteEverything() async {
    _data = empty;
    loadFailed = false;
    _saveGen++; // anything queued is dropped
    await _saving;
    await _file.delete();
    notifyListeners();
  }
}

/// Hands [json] to the phone's share sheet as a file.
Future<void> shareJsonFile(String fileName, String json, String subject) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$fileName');
  await file.writeAsString(json);
  await Share.shareXFiles([
    XFile(file.path, mimeType: 'application/json'),
  ], subject: subject);
}
