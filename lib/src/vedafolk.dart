// What every Véda app says about the Little Vedafolk, and how often they visit:
// one place for the wording and the pace, so the apps cannot drift apart. Each
// app still draws its own hiding places and keeps its own switch; this file is
// the sentence, the interval and the Profile row they share.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'common.dart';

/// The line every app ends its Vedafolk description with.
const kVedafolkCompany =
    'They are here if you need some company through the day and a smile on '
    'your face.';

/// How often a friend visits, on average: a visit comes between 0.7 and 1.3
/// times this after the last, so it never feels like a metronome.
const kVedafolkEvery = Duration(seconds: 30);

/// "Now and then, one of the Vedafolk peeks out from [where]. They are here..."
/// [where] says where they hide in this app, such as "behind the grass beside
/// the tree".
String vedafolkBlurb(String where) =>
    'Now and then, one of the Vedafolk peeks out from $where. '
    '$kVedafolkCompany';

/// The Profile row with the switch, the same in every app that has the friends
/// peek out. Pass the app's own switch: [on] says whether they are on, and
/// [onChanged] turns them on or off.
class VedafolkSwitchRow extends StatelessWidget {
  const VedafolkSwitchRow({
    super.key,
    required this.on,
    required this.onChanged,
    required this.where,
  });

  final ValueListenable<bool> on;
  final Future<void> Function(bool value) onChanged;

  /// Where the friends hide in this app ("behind the plants or the bottles on
  /// the cabinet").
  final String where;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: on,
      builder: (context, value, _) => ProfileRow(
        icon: PhosphorIconsThin.pawPrint,
        title: 'Show the Little Vedafolk',
        subtitle: vedafolkBlurb(where),
        trailing: Switch(
          key: const Key('forestFriendsSwitch'),
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
