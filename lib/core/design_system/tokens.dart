import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens from the Transit Screen Specifications §0.
/// Never hardcode raw numbers in widgets — always reference these constants.

// ─── Spacing (4pt base grid) ───────────────────────────────────────────────

abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
}

// ─── Radius ────────────────────────────────────────────────────────────────

abstract final class AppRadius {
  /// Inputs, small buttons, badges
  static const double sm = 8;

  /// Standard buttons
  static const double md = 10;

  /// Cards, list items
  static const double lg = 12;

  /// Modals, sheets
  static const double xl = 16;

  /// Status pills, avatars
  static const double pill = 999;

  // BorderRadius helpers
  static final BorderRadius borderSm = BorderRadius.circular(sm);
  static final BorderRadius borderMd = BorderRadius.circular(md);
  static final BorderRadius borderLg = BorderRadius.circular(lg);
  static final BorderRadius borderXl = BorderRadius.circular(xl);
  static final BorderRadius borderPill = BorderRadius.circular(pill);
}

// ─── Colors ────────────────────────────────────────────────────────────────

abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF1B4332);
  static const Color primaryMid = Color(0xFF2D6A4F);
  static const Color primaryLight = Color(0xFF40916C);

  // Accents
  static const Color accentGold = Color(0xFFC8973A);
  static const Color accentBlue = Color(0xFF2C5282);

  // Semantic
  static const Color danger = Color(0xFFC0392B);
  static const Color dangerLight = Color(0xFFFDF0EE);

  // Surfaces
  static const Color background = Color(0xFFF5F7F4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFD5E0D5);

  // Text
  static const Color textPrimary = Color(0xFF1A2A1A);
  static const Color textMid = Color(0xFF4A6050);
  static const Color textSecondary = Color(0xFF7A9A80);

  // Utility
  static const Color blueLight = Color(0xFFEAF1F8);
  static const Color goldLight = Color(0xFFFFF8E7);
  static const Color greenLight = Color(0xFFF0FAF4);
}

// ─── Typography ────────────────────────────────────────────────────────────

/// Typography scale. Actual TextStyle objects are built in [AppTheme]
/// using Google Fonts (Inter). These are raw size/weight specs.
abstract final class AppTypography {
  // Caption — 11sp / regular — timestamps, helper text
  static const double captionSize = 11;
  static const FontWeight captionWeight = FontWeight.w400;

  // Label — 12sp / bold, uppercase, tracked — field labels, section eyebrows
  static const double labelSize = 12;
  static const FontWeight labelWeight = FontWeight.w700;
  static const double labelLetterSpacing = 0.72; // 0.06em × 12

  // Body Small — 13sp / regular — secondary body text
  static const double bodySmSize = 13;
  static const FontWeight bodySmWeight = FontWeight.w400;

  // Body — 14sp / regular — primary body text, input text
  static const double bodySize = 14;
  static const FontWeight bodyWeight = FontWeight.w400;

  // Subtitle — 15sp / bold — list item titles, card titles
  static const double subtitleSize = 15;
  static const FontWeight subtitleWeight = FontWeight.w700;

  // Title — 17sp / bold — screen/section headings
  static const double titleSize = 17;
  static const FontWeight titleWeight = FontWeight.w700;

  // Headline — 20sp / bold — top-level screen title
  static const double headlineSize = 20;
  static const FontWeight headlineWeight = FontWeight.w700;

  // ─── Direct TextStyle accessors via Inter ────────────────────────────────
  static TextStyle get headlineLarge => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: headlineWeight,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineMedium => GoogleFonts.inter(
        fontSize: headlineSize,
        fontWeight: headlineWeight,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleLarge => GoogleFonts.inter(
        fontSize: titleSize,
        fontWeight: titleWeight,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleMedium => GoogleFonts.inter(
        fontSize: subtitleSize,
        fontWeight: subtitleWeight,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: bodyWeight,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: bodySize,
        fontWeight: bodyWeight,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: bodySmSize,
        fontWeight: bodySmWeight,
        color: AppColors.textMid,
      );

  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: labelSize,
        fontWeight: labelWeight,
        letterSpacing: labelLetterSpacing,
        color: AppColors.textPrimary,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: captionSize,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: captionSize,
        fontWeight: captionWeight,
        color: AppColors.textSecondary,
      );
}

// ─── Elevation ─────────────────────────────────────────────────────────────

abstract final class AppElevation {
  /// Standard card shadow
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0F000000), // ~6% opacity
      blurRadius: 20,
      offset: Offset(0, 2),
    ),
  ];

  /// Bottom sheets / dialogs
  static const List<BoxShadow> modal = [
    BoxShadow(
      color: Color(0x26000000), // ~15% opacity
      blurRadius: 30,
      offset: Offset(0, 10),
    ),
  ];

  /// AppBar / header
  static const List<BoxShadow> header = [
    BoxShadow(
      color: Color(0x26000000), // ~15% opacity
      blurRadius: 24,
      offset: Offset(0, 4),
    ),
  ];
}

// ─── Layout constants ──────────────────────────────────────────────────────

abstract final class AppLayout {
  /// Horizontal screen padding on mobile
  static const double screenPaddingMobile = AppSpacing.md;

  /// Horizontal screen padding on tablet (≥600dp)
  static const double screenPaddingTablet = AppSpacing.xl;

  /// Standard button height (touch target)
  static const double buttonHeight = 48;

  /// Input field height
  static const double inputHeight = 44;

  /// Standard AppBar height
  static const double appBarHeight = 56;

  /// Expanded AppBar (with subtitle row)
  static const double appBarExpandedHeight = 96;

  /// Employee/driver screens max content width
  static const double maxContentWidth = 680;

  /// Admin screens max content width
  static const double maxAdminContentWidth = 1100;

  /// Tablet breakpoint
  static const double tabletBreakpoint = 600;
}
