library phosphor_flutter;

// Neutered stubs: IconData is a final class as of this app's Flutter SDK,
// so it can no longer be subclassed. The weight files import this file
// but (in this trimmed patch) construct plain IconData literals directly
// instead of these classes — kept only so the import lines don't error.
//
// Written without super-parameter shorthand: this library's inferred
// language version (from this package's own pubspec sdk constraint)
// predates that Dart feature.
class PhosphorIconData {
  const PhosphorIconData(this.codePoint, this.style);
  final int codePoint;
  final String style;
}

class PhosphorFlatIconData extends PhosphorIconData {
  const PhosphorFlatIconData(int codePoint, String style)
      : super(codePoint, style);
}

class PhosphorDuotoneIconData extends PhosphorIconData {
  const PhosphorDuotoneIconData(
      int codePoint, this.secondaryCodePoint, String style)
      : super(codePoint, style);
  final int secondaryCodePoint;
}
