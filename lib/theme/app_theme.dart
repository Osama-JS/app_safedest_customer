import 'package:flutter/material.dart';
import '../Globals/MyColors.dart';

class AppTheme {
  // ===== Typography System =====
  
  static const String primaryFontFamily = 'Tajawal';
  static const String secondaryFontFamily = 'saudi_riyal';
  
  // Font Weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  
  // Font Sizes
  static const double fontSizeXS = 10.0;
  static const double fontSizeSM = 12.0;
  static const double fontSizeBase = 14.0;
  static const double fontSizeLG = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSize2XL = 20.0;
  static const double fontSize3XL = 24.0;
  static const double fontSize4XL = 28.0;
  static const double fontSize5XL = 32.0;
  static const double fontSize6XL = 36.0;
  
  // ===== Spacing System =====
  
  static const double spacing0 = 0.0;
  static const double spacing1 = 4.0;
  static const double spacing2 = 8.0;
  static const double spacing3 = 12.0;
  static const double spacing4 = 16.0;
  static const double spacing5 = 20.0;
  static const double spacing6 = 24.0;
  static const double spacing7 = 28.0;
  static const double spacing8 = 32.0;
  static const double spacing10 = 40.0;
  static const double spacing12 = 48.0;
  static const double spacing16 = 64.0;
  static const double spacing20 = 80.0;
  static const double spacing24 = 96.0;
  
  // ===== Border Radius System =====
  
  static const double radiusNone = 0.0;
  static const double radiusXS = 2.0;
  static const double radiusSM = 4.0;
  static const double radiusBase = 8.0;
  static const double radiusLG = 12.0;
  static const double radiusXL = 16.0;
  static const double radius2XL = 20.0;
  static const double radius3XL = 24.0;
  static const double radiusFull = 9999.0;
  
  // ===== Shadow System =====
  
  static List<BoxShadow> get shadowSM => [
    BoxShadow(
      color: MyColors.shadowColor,
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];
  
  static List<BoxShadow> get shadowBase => [
    BoxShadow(
      color: MyColors.shadowColor,
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get shadowLG => [
    BoxShadow(
      color: MyColors.shadowColor,
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get shadowXL => [
    BoxShadow(
      color: MyColors.shadowColor,
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> get shadow2XL => [
    BoxShadow(
      color: MyColors.shadowColor,
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];
  
  // ===== Elevation System =====
  
  static List<BoxShadow> get elevationLow => [
    BoxShadow(
      color: MyColors.elevationShadow,
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];
  
  static List<BoxShadow> get elevationMedium => [
    BoxShadow(
      color: MyColors.elevationShadow,
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get elevationHigh => [
    BoxShadow(
      color: MyColors.elevationShadow,
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
  
  // ===== Text Styles =====
  
  static TextStyle get displayLarge => TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: fontSize6XL,
    fontWeight: bold,
    color: MyColors.textPrimaryColor,
    height: 1.2,
  );
  
  static TextStyle get displayMedium => TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: fontSize5XL,
    fontWeight: bold,
    color: MyColors.textPrimaryColor,
    height: 1.2,
  );
  
  static TextStyle get displaySmall => TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: fontSize4XL,
    fontWeight: bold,
    color: MyColors.textPrimaryColor,
    height: 1.2,
  );
  
  static TextStyle get headlineLarge => TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: fontSize3XL,
    fontWeight: semiBold,
    color: MyColors.textPrimaryColor,
    height: 1.3,
  );
  
  static TextStyle get headlineMedium => TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: fontSize2XL,
    fontWeight: semiBold,
    color: MyColors.textPrimaryColor,
    height: 1.3,
  );
  
  static TextStyle get headlineSmall => TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: fontSizeXL,
    fontWeight: semiBold,
    color: MyColors.textPrimaryColor,
    height: 1.3,
  );
  
  static TextStyle get titleLarge => TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: fontSizeLG,
    fontWeight: medium,
    color: MyColors.textPrimaryColor,
    height: 1.4,
  );
  
  static TextStyle get titleMedium => TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: fontSizeBase,
    fontWeight: medium,
    color: MyColors.textPrimaryColor,
    height: 1.4,
  );
  
  static TextStyle get titleSmall => TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: fontSizeSM,
    fontWeight: medium,
    color: MyColors.textPrimaryColor,
    height: 1.4,
  );
  
  static TextStyle get bodyLarge => TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: fontSizeLG,
    fontWeight: regular,
    color: MyColors.textPrimaryColor,
    height: 1.5,
  );
  
  static TextStyle get bodyMedium => TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: fontSizeBase,
    fontWeight: regular,
    color: MyColors.textPrimaryColor,
    height: 1.5,
  );
  
  static TextStyle get bodySmall => TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: fontSizeSM,
    fontWeight: regular,
    color: MyColors.textSecondaryColor,
    height: 1.5,
  );
  
  static TextStyle get labelLarge => TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: fontSizeBase,
    fontWeight: medium,
    color: MyColors.textPrimaryColor,
    height: 1.4,
  );
  
  static TextStyle get labelMedium => TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: fontSizeSM,
    fontWeight: medium,
    color: MyColors.textPrimaryColor,
    height: 1.4,
  );
  
  static TextStyle get labelSmall => TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: fontSizeXS,
    fontWeight: medium,
    color: MyColors.textSecondaryColor,
    height: 1.4,
  );
  
  // ===== Special Text Styles =====
  
  static TextStyle get buttonText => TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: fontSizeBase,
    fontWeight: semiBold,
    color: MyColors.whiteColor,
    height: 1.2,
  );
  
  static TextStyle get captionText => TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: fontSizeXS,
    fontWeight: regular,
    color: MyColors.textSecondaryColor,
    height: 1.3,
  );
  
  static TextStyle get overlineText => TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: fontSizeXS,
    fontWeight: medium,
    color: MyColors.textSecondaryColor,
    height: 1.3,
    letterSpacing: 0.5,
  );
  
  // ===== Currency Text Styles =====
  
  static TextStyle get currencyLarge => TextStyle(
    fontFamily: secondaryFontFamily,
    fontSize: fontSize2XL,
    fontWeight: bold,
    color: MyColors.primaryColor,
    height: 1.2,
  );
  
  static TextStyle get currencyMedium => TextStyle(
    fontFamily: secondaryFontFamily,
    fontSize: fontSizeLG,
    fontWeight: semiBold,
    color: MyColors.primaryColor,
    height: 1.2,
  );
  
  static TextStyle get currencySmall => TextStyle(
    fontFamily: secondaryFontFamily,
    fontSize: fontSizeBase,
    fontWeight: medium,
    color: MyColors.textPrimaryColor,
    height: 1.2,
  );
}
