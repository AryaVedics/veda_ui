// Design tokens, shared by every Véda app.
//
// Colors are defined once here and referenced everywhere else; never
// hardcode a hex in a widget. That keeps the palette rules enforceable:
//
//   base    canvas, cards, chrome, supporting text, neutral states (each
//           app's own hue: indigo, peacock, nightfall, wine, umber)
//   gold    readings, the primary action, active selection, and anything
//           asking for attention (the same in every app)
//   magenta anything drawn over a camera feed or a photograph
//
// NO COLOR ENCODES VALENCE. A high number and a low number are the same gold;
// color that means "good" or "bad" is a claim made visually, without the
// words that would qualify it.
//
// Each palette is Véda's indigo with the hue turned and the lightness kept,
// so text contrast is the same in every app (checked in
// test/palette_contrast_test.dart: body text at least 4.5:1 on cards).

import 'package:flutter/material.dart';

/// The warm white every chart marks its leading edge with.
const kMarkerWhite = Color(0xFFFFFDF5);

class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.canvas,
    required this.canvasDeep,
    required this.card,
    required this.cardSunken,
    required this.accent,
    required this.accentDim,
    required this.accentText,
    required this.onAccent,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.divider,
    required this.overlay,
    required this.overlayLight,
  });

  final Color canvas;

  /// Darker canvas, for the corners of the backdrop and camera screens.
  final Color canvasDeep;
  final Color card;

  /// Recessed fill: progress tracks, inactive chips, text fields.
  final Color cardSunken;
  final Color accent;

  /// Dim accent: unfilled ring, selected chip background.
  final Color accentDim;

  /// Lighter accent for text (the fill tone fails contrast as text).
  final Color accentText;

  /// Text and icons sitting ON the accent fill.
  final Color onAccent;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color divider;

  /// Magenta. Camera guides and photo overlays only.
  final Color overlay;
  final Color overlayLight;

  static const _accent = Color(0xFFD9B863);
  static const _accentDim = Color(0xFF544019);
  static const _accentText = Color(0xFFE8C86A);
  static const _onAccent = Color(0xFF3A2E10);
  static const _overlay = Color(0xFFED93B1);
  static const _overlayLight = Color(0xFFF4C0D1);

  /// Véda itself: deep indigo.
  static const midnight = AppColors(
    canvas: Color(0xFF221A4A),
    canvasDeep: Color(0xFF1A1440),
    card: Color(0xFF312666),
    cardSunken: Color(0xFF291F58),
    accent: _accent,
    accentDim: _accentDim,
    accentText: _accentText,
    onAccent: _onAccent,
    textPrimary: Color(0xFFEEEAFC),
    textSecondary: Color(0xFFC9BEF0),
    textMuted: Color(0xFFA99BE0),
    divider: Color(0xFF3B2F7A),
    overlay: _overlay,
    overlayLight: _overlayLight,
  );

  /// Véda Routine: peacock blue.
  static const peacock = AppColors(
    canvas: Color(0xFF163B4E),
    canvasDeep: Color(0xFF113243),
    card: Color(0xFF21526B),
    cardSunken: Color(0xFF1B465C),
    accent: _accent,
    accentDim: _accentDim,
    accentText: _accentText,
    onAccent: _onAccent,
    textPrimary: Color(0xFFE9F6FD),
    textSecondary: Color(0xFFBAE1F4),
    textMuted: Color(0xFF96CBE5),
    divider: Color(0xFF296380),
    overlay: _overlay,
    overlayLight: _overlayLight,
  );

  /// Véda Lifestyle: midnight blue (the night sky behind its stars).
  static const nightfall = AppColors(
    canvas: Color(0xFF0F1D3F),
    canvasDeep: Color(0xFF09122B),
    card: Color(0xFF1A3166),
    cardSunken: Color(0xFF142757),
    accent: _accent,
    accentDim: _accentDim,
    accentText: _accentText,
    onAccent: _onAccent,
    textPrimary: Color(0xFFEAF1FC),
    textSecondary: Color(0xFFC2D2EC),
    textMuted: Color(0xFF96ACD4),
    divider: Color(0xFF2B4580),
    overlay: _overlay,
    overlayLight: _overlayLight,
  );

  /// Véda Cycle: deep wine.
  static const wine = AppColors(
    canvas: Color(0xFF461E33),
    canvasDeep: Color(0xFF3D172B),
    card: Color(0xFF612B48),
    cardSunken: Color(0xFF54233D),
    accent: _accent,
    accentDim: _accentDim,
    accentText: _accentText,
    onAccent: _onAccent,
    textPrimary: Color(0xFFFBEBF4),
    textSecondary: Color(0xFFECC2D8),
    textMuted: Color(0xFFDBA0BF),
    divider: Color(0xFF743557),
    overlay: _overlay,
    overlayLight: _overlayLight,
  );

  /// Véda Sun: warm umber.
  static const umber = AppColors(
    canvas: Color(0xFF45311F),
    canvasDeep: Color(0xFF3C2918),
    card: Color(0xFF60442C),
    cardSunken: Color(0xFF523A25),
    accent: _accent,
    accentDim: _accentDim,
    accentText: _accentText,
    onAccent: _onAccent,
    textPrimary: Color(0xFFFAF3EC),
    textSecondary: Color(0xFFEBD6C3),
    textMuted: Color(0xFFD9BCA2),
    divider: Color(0xFF735337),
    overlay: _overlay,
    overlayLight: _overlayLight,
  );

  /// Véda Kitchen: chilli, a spice red. Clearly red (hue about 5°), so it is
  /// never mistaken for Cycle's wine (about 330°) or Sun's umber (about 28°).
  static const chilli = AppColors(
    canvas: Color(0xFF5A1A14),
    canvasDeep: Color(0xFF4C140F),
    card: Color(0xFF78281F),
    cardSunken: Color(0xFF69211A),
    accent: _accent,
    accentDim: _accentDim,
    accentText: _accentText,
    onAccent: _onAccent,
    textPrimary: Color(0xFFFDEEEA),
    textSecondary: Color(0xFFF3CABF),
    textMuted: Color(0xFFE6A99B),
    divider: Color(0xFF8E3528),
    overlay: _overlay,
    overlayLight: _overlayLight,
  );

  /// Véda Allergy: moss, a deep olive green (hue about 85°), so it is never
  /// mistaken for Routine's peacock blue-green (about 200°) or Sun's umber.
  /// Provisional until the owner confirms the colour.
  static const moss = AppColors(
    canvas: Color(0xFF2F3B1E),
    canvasDeep: Color(0xFF27321A),
    card: Color(0xFF45542C),
    cardSunken: Color(0xFF3A4825),
    accent: _accent,
    accentDim: _accentDim,
    accentText: _accentText,
    onAccent: _onAccent,
    textPrimary: Color(0xFFF4F6EA),
    textSecondary: Color(0xFFDDE3C6),
    textMuted: Color(0xFFC2CBA3),
    divider: Color(0xFF5A6B3A),
    overlay: _overlay,
    overlayLight: _overlayLight,
  );

  static const all = {
    'midnight': midnight,
    'peacock': peacock,
    'nightfall': nightfall,
    'wine': wine,
    'umber': umber,
    'chilli': chilli,
    'moss': moss,
  };

  @override
  AppColors copyWith({
    Color? canvas,
    Color? canvasDeep,
    Color? card,
    Color? cardSunken,
    Color? accent,
    Color? accentDim,
    Color? accentText,
    Color? onAccent,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? divider,
    Color? overlay,
    Color? overlayLight,
  }) {
    return AppColors(
      canvas: canvas ?? this.canvas,
      canvasDeep: canvasDeep ?? this.canvasDeep,
      card: card ?? this.card,
      cardSunken: cardSunken ?? this.cardSunken,
      accent: accent ?? this.accent,
      accentDim: accentDim ?? this.accentDim,
      accentText: accentText ?? this.accentText,
      onAccent: onAccent ?? this.onAccent,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      divider: divider ?? this.divider,
      overlay: overlay ?? this.overlay,
      overlayLight: overlayLight ?? this.overlayLight,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      canvas: l(canvas, other.canvas),
      canvasDeep: l(canvasDeep, other.canvasDeep),
      card: l(card, other.card),
      cardSunken: l(cardSunken, other.cardSunken),
      accent: l(accent, other.accent),
      accentDim: l(accentDim, other.accentDim),
      accentText: l(accentText, other.accentText),
      onAccent: l(onAccent, other.onAccent),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      textMuted: l(textMuted, other.textMuted),
      divider: l(divider, other.divider),
      overlay: l(overlay, other.overlay),
      overlayLight: l(overlayLight, other.overlayLight),
    );
  }
}

extension AppColorsX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
