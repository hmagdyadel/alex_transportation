import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:alex_transportation/core/design_system/tokens.dart';

/// Builds the app-wide [ThemeData] using design tokens.
abstract final class AppTheme {
  /// Light theme — the only theme for now.
  static ThemeData light() {
    const colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryLight,
      secondary: AppColors.accentGold,
      onSecondary: Colors.white,
      error: AppColors.danger,
      onError: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
    );

    final textTheme = _buildTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: AppLayout.appBarHeight,
        titleTextStyle: GoogleFonts.inter(
          fontSize: AppTypography.titleSize,
          fontWeight: AppTypography.titleWeight,
          color: Colors.white,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0, // We use custom BoxShadow via AppElevation
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderLg,
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Elevated buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, AppLayout.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderMd,
          ),
          textStyle: GoogleFonts.inter(
            fontSize: AppTypography.bodySize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // Outlined buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(0, AppLayout.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderMd,
          ),
          side: const BorderSide(color: AppColors.border),
          textStyle: GoogleFonts.inter(
            fontSize: AppTypography.bodySize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // Text buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.inter(
            fontSize: AppTypography.bodySmSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.borderSm,
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderSm,
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderSm,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderSm,
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderSm,
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: AppTypography.labelSize,
          fontWeight: AppTypography.labelWeight,
          letterSpacing: AppTypography.labelLetterSpacing,
          color: AppColors.primary,
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: AppTypography.bodySize,
          color: AppColors.textSecondary,
        ),
        errorStyle: GoogleFonts.inter(
          fontSize: AppTypography.captionSize,
          color: AppColors.danger,
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 0,
      ),

      // Bottom sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderXl,
        ),
      ),
    );
  }

  /// Builds the complete text theme using Inter.
  static TextTheme _buildTextTheme() {
    return TextTheme(
      // Headline — 20sp / bold
      headlineSmall: GoogleFonts.inter(
        fontSize: AppTypography.headlineSize,
        fontWeight: AppTypography.headlineWeight,
        color: AppColors.textPrimary,
      ),

      // Title — 17sp / bold
      titleMedium: GoogleFonts.inter(
        fontSize: AppTypography.titleSize,
        fontWeight: AppTypography.titleWeight,
        color: AppColors.textPrimary,
      ),

      // Subtitle — 15sp / bold
      titleSmall: GoogleFonts.inter(
        fontSize: AppTypography.subtitleSize,
        fontWeight: AppTypography.subtitleWeight,
        color: AppColors.textPrimary,
      ),

      // Body — 14sp / regular
      bodyLarge: GoogleFonts.inter(
        fontSize: AppTypography.bodySize,
        fontWeight: AppTypography.bodyWeight,
        color: AppColors.textPrimary,
      ),

      // Body Small — 13sp / regular
      bodyMedium: GoogleFonts.inter(
        fontSize: AppTypography.bodySmSize,
        fontWeight: AppTypography.bodySmWeight,
        color: AppColors.textPrimary,
      ),

      // Label — 12sp / bold / uppercase / tracked
      labelLarge: GoogleFonts.inter(
        fontSize: AppTypography.labelSize,
        fontWeight: AppTypography.labelWeight,
        letterSpacing: AppTypography.labelLetterSpacing,
        color: AppColors.primary,
      ),

      // Caption — 11sp / regular
      bodySmall: GoogleFonts.inter(
        fontSize: AppTypography.captionSize,
        fontWeight: AppTypography.captionWeight,
        color: AppColors.textSecondary,
      ),
    );
  }
}
