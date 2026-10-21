# Local patch: phosphor_flutter 2.1.0

Upstream 2.1.0 (the latest version published, from 2024-05-10) declares
`PhosphorIconData extends IconData`. This app's Flutter SDK made
`IconData` a `final class`, so subclassing it is now a compile error —
upstream hasn't published a fix.

This is a vendored, trimmed copy used via a `dependency_overrides: path:`
entry in the app's `pubspec.yaml`. Changes from upstream:

- `lib/phosphor_flutter.dart` — only exports the Thin and Fill weight
  files (the two this app actually uses), not all six.
- `lib/src/phosphor_icon_data.dart` — `PhosphorIconData` and its two
  subclasses no longer extend `IconData`; they're inert stubs now, kept
  only so the weight files' `import` lines still resolve.
- `lib/src/phosphor_icons_thin.dart` and `phosphor_icons_fill.dart` —
  every icon constant now constructs a plain `IconData(...)` literal
  directly (same codepoint, fontFamily, fontPackage as before) instead
  of going through `PhosphorFlatIconData(...)`. The `@staticIconProvider`
  annotation on each class (unresolved even upstream, apparently a
  leftover from their code generator) was dropped along with it.

If phosphor_flutter ships a real fix for this upstream, drop the
`dependency_overrides` entry and delete this folder instead of
maintaining the patch here.
