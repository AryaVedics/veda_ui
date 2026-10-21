library phosphor_flutter;

// Trimmed local patch (see third_party/phosphor_flutter/PATCH_NOTES.md):
// upstream 2.1.0 subclasses IconData, which the Flutter SDK this app
// builds against no longer allows (IconData became a final class). Only
// the two weights this app actually uses are kept.
export 'package:phosphor_flutter/src/phosphor_icons_thin.dart';
export 'package:phosphor_flutter/src/phosphor_icons_fill.dart';
