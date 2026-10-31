import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../consts/app_colors.dart';
import '../consts/app_icons.dart';
import '../consts/app_sizes.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    const colorScheme = ColorScheme(
      brightness: .light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primarySoft,
      onPrimaryContainer: AppColors.primary,
      secondary: AppColors.accent,
      onSecondary: AppColors.onAccent,
      secondaryContainer: AppColors.accentSoft,
      onSecondaryContainer: AppColors.onAccent,
      error: AppColors.error,
      onError: AppColors.onError,
      surface: AppColors.surface,
      onSurface: AppColors.text,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.border,
      outlineVariant: AppColors.outline,
      shadow: AppColors.shadow,
      inverseSurface: AppColors.primary,
      onInverseSurface: AppColors.onPrimary,
      inversePrimary: AppColors.accent,
      surfaceContainerLowest: AppColors.surface,
      surfaceContainerLow: AppColors.background,
      surfaceContainer: AppColors.background,
    );

    final textTheme = _textTheme;
    final radius = BorderRadius.circular(AppSizes.radiusMd);
    final border = OutlineInputBorder(
      borderRadius: radius,
      borderSide: const BorderSide(color: AppColors.border),
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      iconTheme: const IconThemeData(color: AppColors.text, size: 22),
      actionIconTheme: ActionIconThemeData(
        backButtonIconBuilder: (_) => const Icon(AppIcons.back, size: 18),
      ),
      dividerColor: AppColors.outline,
      dividerTheme: const DividerThemeData(
        color: AppColors.outline,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarThemeData(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: AppColors.background,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: const IconThemeData(color: AppColors.text),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: textTheme.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: .w800,
            color: AppColors.onPrimary,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          backgroundColor: AppColors.surface,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: textTheme.labelLarge?.copyWith(color: AppColors.primary),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: textTheme.bodyLarge?.copyWith(
          color: AppColors.textSecondary,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: const BorderSide(color: AppColors.outline),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.outline,
        labelStyle: textTheme.labelLarge ?? const TextStyle(),
        secondaryLabelStyle: textTheme.labelLarge?.copyWith(
          color: AppColors.onPrimary,
        ),
        side: const BorderSide(color: AppColors.outline),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.accentSoft,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            color: selected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: .w700,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: selected ? AppColors.primary : AppColors.textSecondary,
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.primary,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.onPrimary,
          fontWeight: .w600,
        ),
        behavior: .floating,
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
    );
  }

  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x0F0D1B14), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x120D1B14), blurRadius: 28, offset: Offset(0, 10)),
  ];

  static TextTheme get _textTheme {
    TextStyle style({
      required double fontSize,
      required FontWeight fontWeight,
      required Color color,
      double? letterSpacing,
      double? height,
    }) {
      return GoogleFonts.plusJakartaSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );
    }

    return TextTheme(
      displayLarge: style(
        fontSize: 40,
        fontWeight: .w800,
        letterSpacing: -1,
        height: 1.12,
        color: AppColors.text,
      ),
      headlineLarge: style(
        fontSize: 30,
        fontWeight: .w800,
        letterSpacing: -0.75,
        height: 1.12,
        color: AppColors.text,
      ),
      headlineMedium: style(
        fontSize: 22,
        fontWeight: .w800,
        letterSpacing: -0.4,
        color: AppColors.text,
      ),
      titleLarge: style(
        fontSize: 20,
        fontWeight: .w800,
        letterSpacing: -0.4,
        color: AppColors.text,
      ),
      titleMedium: style(
        fontSize: 17,
        fontWeight: .w800,
        letterSpacing: -0.17,
        color: AppColors.text,
      ),
      titleSmall: style(fontSize: 15, fontWeight: .w700, color: AppColors.text),
      bodyLarge: style(fontSize: 16, fontWeight: .w500, color: AppColors.text),
      bodyMedium: style(
        fontSize: 14,
        fontWeight: .w600,
        color: AppColors.textSecondary,
      ),
      bodySmall: style(
        fontSize: 12,
        fontWeight: .w500,
        color: AppColors.textSecondary,
      ),
      labelLarge: style(fontSize: 14, fontWeight: .w700, color: AppColors.text),
      labelMedium: style(
        fontSize: 12,
        fontWeight: .w700,
        color: AppColors.text,
      ),
      labelSmall: style(
        fontSize: 11,
        fontWeight: .w700,
        color: AppColors.textSecondary,
      ),
    );
  }
}
