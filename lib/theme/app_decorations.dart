import 'package:flutter/material.dart';
import '../Globals/MyColors.dart';
import 'app_theme.dart';

class AppDecorations {
  // ===== Container Decorations =====
  
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: MyColors.whiteColor,
    borderRadius: BorderRadius.circular(AppTheme.radiusLG),
    boxShadow: AppTheme.shadowBase,
    border: Border.all(
      color: MyColors.outlineVariantColor,
      width: 1,
    ),
  );
  
  static BoxDecoration get elevatedCardDecoration => BoxDecoration(
    color: MyColors.whiteColor,
    borderRadius: BorderRadius.circular(AppTheme.radiusXL),
    boxShadow: AppTheme.shadowLG,
  );
  
  static BoxDecoration get surfaceDecoration => BoxDecoration(
    color: MyColors.surfaceColor,
    borderRadius: BorderRadius.circular(AppTheme.radiusBase),
    border: Border.all(
      color: MyColors.outlineVariantColor,
      width: 1,
    ),
  );
  
  static BoxDecoration get primaryGradientDecoration => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        MyColors.gradientStart,
        MyColors.gradientEnd,
      ],
    ),
    borderRadius: BorderRadius.circular(AppTheme.radiusLG),
    boxShadow: AppTheme.shadowBase,
  );
  
  static BoxDecoration get secondaryGradientDecoration => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        MyColors.secondary400,
        MyColors.secondary600,
      ],
    ),
    borderRadius: BorderRadius.circular(AppTheme.radiusLG),
    boxShadow: AppTheme.shadowBase,
  );
  
  // ===== Input Field Decorations =====
  
  static InputDecoration inputDecoration({
    String? labelText,
    String? hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
    bool isError = false,
  }) => InputDecoration(
    labelText: labelText,
    hintText: hintText,
    prefixIcon: prefixIcon != null 
        ? Icon(prefixIcon, color: MyColors.inputIconColor, size: 20)
        : null,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: MyColors.inputFillColor,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppTheme.spacing4,
      vertical: AppTheme.spacing3,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
      borderSide: BorderSide(
        color: MyColors.inputBorderColor,
        width: 1,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
      borderSide: BorderSide(
        color: MyColors.inputBorderColor,
        width: 1,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
      borderSide: BorderSide(
        color: MyColors.primaryColor,
        width: 2,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
      borderSide: BorderSide(
        color: MyColors.inputBorderErrorColor,
        width: 1,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
      borderSide: BorderSide(
        color: MyColors.inputBorderErrorColor,
        width: 2,
      ),
    ),
    labelStyle: AppTheme.bodyMedium.copyWith(
      color: MyColors.textSecondaryColor,
    ),
    hintStyle: AppTheme.bodyMedium.copyWith(
      color: MyColors.textSecondaryColor,
    ),
    errorStyle: AppTheme.bodySmall.copyWith(
      color: MyColors.inputBorderErrorColor,
    ),
  );
  
  // ===== Button Decorations =====
  
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: MyColors.primaryColor,
    foregroundColor: MyColors.whiteColor,
    elevation: 2,
    shadowColor: MyColors.shadowColor,
    padding: const EdgeInsets.symmetric(
      horizontal: AppTheme.spacing6,
      vertical: AppTheme.spacing3,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
    ),
    textStyle: AppTheme.buttonText,
  );
  
  static ButtonStyle get secondaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: MyColors.primaryShadeColor,
    foregroundColor: MyColors.primaryColor,
    elevation: 0,
    padding: const EdgeInsets.symmetric(
      horizontal: AppTheme.spacing6,
      vertical: AppTheme.spacing3,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
      side: BorderSide(
        color: MyColors.primaryColor,
        width: 1,
      ),
    ),
    textStyle: AppTheme.buttonText.copyWith(
      color: MyColors.primaryColor,
    ),
  );
  
  static ButtonStyle get outlinedButtonStyle => OutlinedButton.styleFrom(
    foregroundColor: MyColors.primaryColor,
    padding: const EdgeInsets.symmetric(
      horizontal: AppTheme.spacing6,
      vertical: AppTheme.spacing3,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
    ),
    side: BorderSide(
      color: MyColors.primaryColor,
      width: 1,
    ),
    textStyle: AppTheme.buttonText.copyWith(
      color: MyColors.primaryColor,
    ),
  );
  
  static ButtonStyle get textButtonStyle => TextButton.styleFrom(
    foregroundColor: MyColors.primaryColor,
    padding: const EdgeInsets.symmetric(
      horizontal: AppTheme.spacing4,
      vertical: AppTheme.spacing2,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppTheme.radiusBase),
    ),
    textStyle: AppTheme.labelLarge.copyWith(
      color: MyColors.primaryColor,
    ),
  );
  
  // ===== Status Decorations =====
  
  static BoxDecoration statusDecoration(Color color) => BoxDecoration(
    color: color.withOpacity(0.1),
    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
    border: Border.all(
      color: color.withOpacity(0.3),
      width: 1,
    ),
  );
  
  static BoxDecoration get successDecoration => statusDecoration(MyColors.success500);
  static BoxDecoration get warningDecoration => statusDecoration(MyColors.warning500);
  static BoxDecoration get errorDecoration => statusDecoration(MyColors.error500);
  static BoxDecoration get infoDecoration => statusDecoration(MyColors.secondary500);
  
  // ===== Badge Decorations =====
  
  static BoxDecoration badgeDecoration(Color color) => BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
    boxShadow: AppTheme.shadowSM,
  );
  
  // ===== Shimmer Decorations =====
  
  static BoxDecoration get shimmerDecoration => BoxDecoration(
    color: MyColors.shimmerbase,
    borderRadius: BorderRadius.circular(AppTheme.radiusBase),
  );
  
  // ===== Divider Decorations =====
  
  static BoxDecoration get dividerDecoration => BoxDecoration(
    color: MyColors.outlineVariantColor,
  );
  
  // ===== Bottom Sheet Decorations =====
  
  static BoxDecoration get bottomSheetDecoration => BoxDecoration(
    color: MyColors.whiteColor,
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(AppTheme.radius2XL),
      topRight: Radius.circular(AppTheme.radius2XL),
    ),
    boxShadow: AppTheme.shadow2XL,
  );
  
  // ===== Dialog Decorations =====
  
  static BoxDecoration get dialogDecoration => BoxDecoration(
    color: MyColors.whiteColor,
    borderRadius: BorderRadius.circular(AppTheme.radius2XL),
    boxShadow: AppTheme.shadowXL,
  );
  
  // ===== App Bar Decorations =====
  
  static BoxDecoration get appBarDecoration => BoxDecoration(
    color: MyColors.whiteColor,
    boxShadow: AppTheme.elevationLow,
  );
  
  // ===== Navigation Bar Decorations =====
  
  static BoxDecoration get navigationBarDecoration => BoxDecoration(
    color: MyColors.whiteColor,
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(AppTheme.radius2XL),
      topRight: Radius.circular(AppTheme.radius2XL),
    ),
    boxShadow: AppTheme.shadowLG,
  );
}
