import 'package:flutter/material.dart';

import '../shared_prff.dart';

class MyColors {
  // ===== نظام الألوان الأساسي المحدث =====

  // الألوان الأساسية - تدرجات عصرية من الأحمر (SafeDest Red Theme)
  static const Color primary50 = Color(0xFFFEF2F2);
  static const Color primary100 = Color(0xFFFEE2E2);
  static const Color primary200 = Color(0xFFFECACA);
  static const Color primary300 = Color(0xFFFCA5A5);
  static const Color primary400 = Color(0xFFF87171);
  static const Color primary500 = Color(
    0xFFD40019,
  ); // اللون الأساسي الأحمر من SafeDest Driver
  static const Color primary600 = Color(0xFFB91C1C);
  static const Color primary700 = Color(0xFF991B1B);
  static const Color primary800 = Color(0xFF7F1D1D);
  static const Color primary900 = Color(0xFF6B1717);

  // الألوان الثانوية - تدرجات برتقالية داكنة (Deep Orange)
  static const Color secondary50 = Color(0xFFFFF3E0);
  static const Color secondary100 = Color(0xFFFFE0B2);
  static const Color secondary200 = Color(0xFFFFCC80);
  static const Color secondary300 = Color(0xFFFFB74D);
  static const Color secondary400 = Color(0xFFFFA726);
  static const Color secondary500 = Color(
    0xFFFF5722,
  ); // Deep Orange من SafeDest Driver
  static const Color secondary600 = Color(0xFFF4511E);
  static const Color secondary700 = Color(0xFFE64A19);
  static const Color secondary800 = Color(0xFFD84315);
  static const Color secondary900 = Color(0xFFBF360C);

  // ألوان النجاح والخطأ والتحذير
  static const Color success50 = Color(0xFFF0FDF4);
  static const Color success500 = Color(0xFF22C55E);
  static const Color success600 = Color(0xFF16A34A);

  static const Color error50 = Color(0xFFFEF2F2);
  static const Color error500 = Color(0xFFEF4444);
  static const Color error600 = Color(0xFFDC2626);

  static const Color warning50 = Color(0xFFFFFBEB);
  static const Color warning500 = Color(0xFFF59E0B);
  static const Color warning600 = Color(0xFFD97706);

  // ألوان محايدة عصرية
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);

  // ===== الألوان المتوافقة مع النظام القديم =====
  static const Color onBackgroundColor = neutral50;
  static const Color cardBColor = primary50;
  static const Color primaryShadeColor = primary100;
  static const Color textPrimaryColor = neutral800;
  static const Color textSecondaryColor = neutral500;
  static const Color whiteColor = Color(0xFFFFFFFF);

  static const Color inputFillColor = neutral50;
  static const Color inputBorderColor = neutral200;
  static const Color inputBorderErrorColor = error500;
  static const Color inputIconColor = neutral600;
  static const Color shimmerColor = primary400;

  static const Color splashBackgroundColor = whiteColor;

  // الألوان الديناميكية حسب الثيم
  static const Color darkPrimaryColor = primary600;
  static const Color lightPrimaryColor = primary500;
  static Color primaryColor = Theme_pref.getTheme() == 0
      ? lightPrimaryColor
      : darkPrimaryColor;

  static const Color darkBackground = whiteColor;
  static const Color lightBackground = whiteColor;
  static Color backgroundColor = Theme_pref.getTheme() == 0
      ? lightBackground
      : darkBackground;

  static const Color darkBorder = neutral300;
  static const Color lightBorder = neutral200;
  static Color borderColor = Theme_pref.getTheme() == 0
      ? lightBorder
      : darkBorder;

  static const Color darkFont = neutral900;
  static const Color lightFont = neutral800;
  static Color fontColor = Theme_pref.getTheme() == 0 ? lightFont : darkFont;

  static const Color darkAppBar = whiteColor;
  static const Color lightAppBar = whiteColor;
  static Color appBarColor = Theme_pref.getTheme() == 0
      ? lightAppBar
      : darkAppBar;

  static const Color inputLightFont = neutral800;
  static const Color inputDarkFont = neutral800;
  static Color inputFontColor = Theme_pref.getTheme() == 0
      ? inputLightFont
      : inputDarkFont;

  // ===== ألوان إضافية عصرية =====
  static const Color linkColor = secondary500;
  static const Color surfaceColor = neutral50;
  static const Color surfaceVariantColor = neutral100;
  static const Color outlineColor = neutral300;
  static const Color outlineVariantColor = neutral200;

  // ألوان الظلال
  static const Color shadowColor = Color(0x1A000000);
  static const Color elevationShadow = Color(0x0D000000);

  // ألوان التدرج
  static const Color gradientStart = primary400;
  static const Color gradientEnd = primary600;

  // ===== ألوان متوافقة مع النظام القديم =====
  static const Color white_100 = Color(0x1A7F7F7F);
  static const Color shimmerbase = primary200;
  static const Color shimmerhighlight = primary100;
  static const Color gray = neutral300;
  static const Color black = neutral900;
  static const Color yellow = warning500;

  // ===== ألوان إضافية للتطبيق =====

  // ألوان النصوص والتلميحات
  static const Color textHintColor = neutral400;
  static const Color errorColor = error500;

  // ألوان الحالة
  static const Color statusPending = warning500;
  static const Color statusInProgress = secondary500;
  static const Color statusCompleted = success500;
  static const Color statusCancelled = error500;

  // ألوان الأولوية
  static const Color priorityLow = success500;
  static const Color priorityMedium = warning500;
  static const Color priorityHigh = error500;

  // ألوان التقييم
  static const Color ratingGold = Color(0xFFFFD700);
  static const Color ratingSilver = Color(0xFFC0C0C0);
  static const Color ratingBronze = Color(0xFFCD7F32);
}
