// Véda's theme (flutter_app/lib/main.dart), shared by every companion app.

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// The one display font, for titles only; body text stays on the system sans.
const kDisplayFont = 'packages/veda_ui/Marcellus';

ThemeData vedaTheme(AppColors colors) {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: colors.canvas,
    colorScheme: ColorScheme.fromSeed(
      seedColor: colors.accent,
      brightness: Brightness.dark,
    ).copyWith(surface: colors.canvas),
    extensions: [colors],
    useMaterial3: true,
    dialogTheme: DialogThemeData(
      backgroundColor: colors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: TextStyle(
        fontSize: 19,
        fontFamily: kDisplayFont,
        color: colors.textPrimary,
      ),
      contentTextStyle: TextStyle(
        fontSize: 14,
        color: colors.textSecondary,
        height: 1.5,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      showDragHandle: true,
      dragHandleColor: colors.divider,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colors.card,
      contentTextStyle: TextStyle(fontSize: 13.5, color: colors.textPrimary),
      actionTextColor: colors.accentText,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: colors.card,
      headerForegroundColor: colors.textPrimary,
    ),
    timePickerTheme: TimePickerThemeData(backgroundColor: colors.card),
    chipTheme: ChipThemeData(
      backgroundColor: colors.cardSunken,
      selectedColor: colors.accentDim,
      checkmarkColor: colors.accentText,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      labelStyle: TextStyle(fontSize: 13, color: colors.textSecondary),
      secondaryLabelStyle: TextStyle(fontSize: 13, color: colors.accentText),
      showCheckmark: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.cardSunken,
      hintStyle: TextStyle(color: colors.textMuted),
      labelStyle: TextStyle(color: colors.textMuted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) =>
            s.contains(WidgetState.selected) ? colors.accent : colors.textMuted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? colors.accentDim
            : colors.cardSunken,
      ),
    ),
    splashColor: colors.accentDim.withValues(alpha: 0.3),
    highlightColor: colors.accentDim.withValues(alpha: 0.15),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: colors.accentText,
      selectionColor: colors.accentDim,
      selectionHandleColor: colors.accent,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: colors.accentText),
    ),
  );
}
