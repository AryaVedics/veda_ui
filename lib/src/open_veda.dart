// "Open Véda" in every app's logo menu: opens the Véda app if it is on this
// phone, otherwise its store page (where Véda is the one place to get skin
// results, so an app without it simply invites the person to get it).

import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

const String kVedaPackage = 'com.aryavedics.skin';

const _channel = MethodChannel('com.aryavedics.veda_ui/link');

Future<void> openVeda() async {
  try {
    if (await _channel.invokeMethod<String>('openApp', {
          'package': kVedaPackage,
        }) ==
        'opened') {
      return;
    }
  } catch (_) {
    // Not Android, or the call failed: fall through to the store page.
  }
  final store = Uri.parse('market://details?id=$kVedaPackage');
  if (await canLaunchUrl(store)) {
    await launchUrl(store, mode: LaunchMode.externalApplication);
  } else {
    await launchUrl(
      Uri.parse('https://play.google.com/store/apps/details?id=$kVedaPackage'),
      mode: LaunchMode.externalApplication,
    );
  }
}
