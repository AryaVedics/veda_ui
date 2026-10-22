// Véda Link, live: how the Véda apps on one phone share with each other, with
// no file in between. See BRIDGE.md for the design and the rules.
//
// Each app publishes ONE feed, the kind of entry it owns, through an Android
// content provider (android/.../VedaLinkProvider.kt) that only apps signed
// with the same key can read. Reading is a direct query to the other app's
// provider, made whenever this app opens or comes back to the front.
//
// Two switches, both off until the person turns them on:
//   share  "Share my entries with my other Véda apps"  (publish this app's feed)
//   use    "Use entries from my other Véda apps"       (read the others' feeds)
//
// Nothing here touches a network: the data goes from one app's private
// storage, through the phone provider mechanism, into the other app.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The apps of the family, with the id each publishes under.
enum LinkApp {
  sun('sun', 'com.aryavedics.sun.link', 'Véda Sun'),
  lifestyle('lifestyle', 'com.aryavedics.lifestyle.link', 'Véda Lifestyle'),
  cycle('cycle', 'com.aryavedics.cycle.link', 'Véda Cycle'),
  routine('routine', 'com.aryavedics.routine.link', 'Véda Routine'),
  skin('skin', 'com.aryavedics.skin.link', 'Véda');

  const LinkApp(this.id, this.authority, this.name);

  final String id;
  final String authority;
  final String name;
}

/// What reading another app's feed came back with.
enum LinkStatus {
  /// Not asked yet (reading is off, or no refresh has run).
  unknown,

  /// Their feed is here.
  connected,

  /// Installed, and allowed, but the person has sharing off in that app.
  sharingOff,

  /// Installed, but signed with a different key, so Android refuses.
  notAllowed,

  /// Not installed.
  notInstalled,

  /// Installed, but did not answer in time (try again).
  noAnswer,
}

class LinkFeed {
  const LinkFeed({
    required this.app,
    required this.updatedAt,
    required this.data,
  });

  final LinkApp app;
  final DateTime updatedAt;

  /// What that app chose to publish (see each app's `linkFeed`).
  final Map<String, Object?> data;
}

class LinkRead {
  const LinkRead(this.status, [this.feed]);

  final LinkStatus status;
  final LinkFeed? feed;
}

class LinkBridge extends ChangeNotifier {
  LinkBridge(this.self, {MethodChannel? channel, DateTime Function()? clock})
    : _channel = channel ?? const MethodChannel('com.aryavedics.veda_ui/link'),
      _clock = clock ?? DateTime.now;

  /// The app this is running inside.
  final LinkApp self;

  final MethodChannel _channel;
  final DateTime Function() _clock;

  static const _shareKey = 'veda_link_share';
  static const _useKey = 'veda_link_use';

  bool _share = false;
  bool _use = false;
  bool get share => _share;
  bool get use => _use;

  final Map<LinkApp, LinkRead> _others = {};
  LinkRead readOf(LinkApp app) =>
      _others[app] ?? const LinkRead(LinkStatus.unknown);

  /// The feed of [app], if it is connected right now.
  LinkFeed? feedOf(LinkApp app) => readOf(app).feed;

  /// The other apps this one can look at.
  Iterable<LinkApp> get others => LinkApp.values.where((a) => a != self);

  Map<String, Object?>? _lastPublished;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _share = prefs.getBool(_shareKey) ?? false;
    _use = prefs.getBool(_useKey) ?? false;
    notifyListeners();
  }

  // A switch must move the instant it is tapped: the flag changes and the
  // screen is told FIRST, and the slower work (saving, publishing, asking the
  // other apps) follows. Waiting for it before redrawing left the switch
  // looking dead until the next rebuild.
  Future<void> setShare(bool on) async {
    _share = on;
    notifyListeners();
    await (await SharedPreferences.getInstance()).setBool(_shareKey, on);
    // On: publish what we have. Off: stop serving anything at once.
    await _write(on ? _lastPublished : null);
    notifyListeners();
  }

  Future<void> setUse(bool on) async {
    _use = on;
    if (on) {
      for (final app in others) {
        _others[app] = const LinkRead(LinkStatus.unknown); // "checking…"
      }
    } else {
      _others.clear();
    }
    notifyListeners();
    await (await SharedPreferences.getInstance()).setBool(_useKey, on);
    if (on) await refresh();
  }

  /// Hand over this app's feed. Remembered, and only served if sharing is on.
  Future<void> publish(Map<String, Object?> data) async {
    _lastPublished = data;
    if (_share) await _write(data);
  }

  Future<void> _write(Map<String, Object?>? data) async {
    final text = data == null
        ? null
        : jsonEncode({
            'schema': 'veda-link/2',
            'app': self.id,
            'updated_at': _clock().toUtc().toIso8601String(),
            'data': data,
          });
    try {
      await _channel
          .invokeMethod('publish', {'feed': text})
          .timeout(const Duration(seconds: 6));
    } on TimeoutException {
      debugPrint('Véda Link: publishing took too long');
    } on MissingPluginException {
      // Not on Android (tests, other platforms): nothing to serve.
    } on PlatformException catch (e) {
      debugPrint('Véda Link: could not publish: ${e.message}');
    }
  }

  /// Ask every other family app for its feed. Does nothing if reading is off.
  Future<void> refresh() async {
    if (!_use) return;
    // All at once, each result shown as soon as it arrives: waking another
    // app can take a moment, and one slow app must not hold up the rest.
    await Future.wait([
      for (final app in others)
        _readOne(app).then((r) {
          if (!_use) return;
          _others[app] = r;
          notifyListeners();
        }),
    ]);
  }

  Future<LinkRead> _readOne(LinkApp app) async {
    try {
      final r = await _channel
          .invokeMapMethod<String, Object?>('read', {
            'authority': app.authority,
          })
          .timeout(const Duration(seconds: 8));
      switch (r?['status']) {
        case 'ok':
          final j = jsonDecode(r!['feed'] as String) as Map<String, Object?>;
          return LinkRead(
            LinkStatus.connected,
            LinkFeed(
              app: app,
              updatedAt: DateTime.fromMillisecondsSinceEpoch(
                r['updated_at'] as int,
              ),
              data: ((j['data'] as Map?) ?? const {}).cast<String, Object?>(),
            ),
          );
        case 'empty':
          return const LinkRead(LinkStatus.sharingOff);
        case 'denied':
          return const LinkRead(LinkStatus.notAllowed);
        default:
          return const LinkRead(LinkStatus.notInstalled);
      }
    } on TimeoutException {
      return const LinkRead(LinkStatus.noAnswer);
    } on MissingPluginException {
      return const LinkRead(LinkStatus.notInstalled);
    } catch (_) {
      return const LinkRead(LinkStatus.notInstalled);
    }
  }
}

/// Keeps the feeds fresh: reads the others when the app opens and every time
/// it comes back to the front, which is when the person is looking.
class LinkRefresher extends StatefulWidget {
  const LinkRefresher({
    super.key,
    required this.bridge,
    required this.child,
    this.onResume,
  });

  final LinkBridge bridge;
  final Widget child;

  /// Also run on open and resume, e.g. to republish a feed that depends on
  /// today's date.
  final VoidCallback? onResume;

  @override
  State<LinkRefresher> createState() => _LinkRefresherState();
}

class _LinkRefresherState extends State<LinkRefresher>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _go();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _go();
  }

  Future<void> _go() async {
    await widget.bridge.load();
    widget.onResume?.call();
    await widget.bridge.refresh();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
