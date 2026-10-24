// Reaching us when something is wrong: "Contact support" opens an email to us
// with a short, readable block of technical details already in it. Nothing is
// sent by the app itself: the person sees the exact text first, and sends (or
// doesn't) from their own email app. No photos, readings, or entries are ever
// included, only what helps us fix a problem.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'common.dart';

const String kSupportEmail = 'support@aryavedics.com';

const _channel = MethodChannel('com.aryavedics.veda_ui/link');

/// What a support email carries: the app, the version, the phone, and
/// anything the caller adds (what failed, which apps are linked).
Future<String> supportDiagnostics(
  String appName, {
  String? problem,
  Map<String, String> extra = const {},
}) async {
  var info = <String, String>{};
  try {
    final r = await _channel.invokeMapMethod<String, Object?>('deviceInfo');
    info = {for (final e in (r ?? const {}).entries) e.key: '${e.value}'};
  } catch (_) {
    // Not Android, or the call failed: the email still goes out without it.
  }
  final lines = <String>[
    'App: $appName ${info['version'] ?? ''} (build ${info['build'] ?? '?'})'
        .trim(),
    'Phone: ${info['model'] ?? 'unknown'}, Android ${info['android'] ?? '?'}',
    'Time: ${DateTime.now().toIso8601String()}',
    if (problem != null && problem.isNotEmpty) 'Problem: $problem',
    for (final e in extra.entries) '${e.key}: ${e.value}',
  ];
  return lines.join('\n');
}

/// Shows the person exactly what would be sent, and opens their email app
/// with it if they agree (or the share sheet if they have no email app).
Future<void> contactSupport(
  BuildContext context,
  String appName, {
  String? problem,
  Map<String, String> extra = const {},
}) async {
  final details = await supportDiagnostics(
    appName,
    problem: problem,
    extra: extra,
  );
  if (!context.mounted) return;
  final send = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Contact support'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This opens an email to us with the details below, so we can '
              'see what went wrong. Nothing is sent until you send it. No '
              'photos, readings or entries are included. Add a line about '
              'what happened if you like.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            Text(
              details,
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(c, true),
          child: const Text('Write the email'),
        ),
      ],
    ),
  );
  if (send != true) return;
  final body = 'Hello,\n\n(Tell us what happened here.)\n\n--\n$details';
  final uri = Uri(
    scheme: 'mailto',
    path: kSupportEmail,
    queryParameters: {'subject': '$appName support', 'body': body},
  );
  try {
    if (await launchUrl(uri)) return;
  } catch (_) {
    // No email app: share the text instead, below.
  }
  await Share.share('To: $kSupportEmail\n\n$body', subject: '$appName support');
}

/// Profile's "Help" card: the one place to reach us from inside an app.
class SupportSection extends StatelessWidget {
  const SupportSection({
    super.key,
    required this.appName,
    this.extra = const {},
  });

  final String appName;

  /// Anything app-specific worth putting in the email (for example which apps
  /// are linked).
  final Map<String, String> extra;

  @override
  Widget build(BuildContext context) {
    return CardBox(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: Column(
        children: [
          ProfileRow(
            icon: PhosphorIconsThin.lifebuoy,
            title: 'Contact support',
            subtitle:
                'Something wrong? Email us with the details that help. You '
                'see exactly what is included before anything is sent.',
            onTap: () => contactSupport(context, appName, extra: extra),
          ),
        ],
      ),
    );
  }
}
