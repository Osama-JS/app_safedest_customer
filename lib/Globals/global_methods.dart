import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../Helpers/Users.dart';
import '../shared_prff.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'MyColors.dart';
import '../theme/app_theme.dart';
import '../theme/app_decorations.dart';
import 'package:flutter/material.dart';
import 'dart:io';

// check internet
Future<bool> isInternetAvailable() async {
  try {
    final result = await InternetAddress.lookup('www.google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  } on SocketException catch (e) {
    return false;
  }
}

// snackbars
SnackBar errorSnackbar(String msg) {
  return SnackBar(backgroundColor: MyColors.primaryColor, content: Text(msg));
}

// ===== Text Styles - Updated to use AppTheme =====
textAppBar() => AppTheme.titleLarge.copyWith(color: MyColors.textPrimaryColor);
textWhiteAppBar() => AppTheme.titleLarge.copyWith(color: MyColors.whiteColor);
textTitle() => AppTheme.titleLarge;
textSubTitle() => AppTheme.titleMedium;
textCardTitle() => AppTheme.titleMedium.copyWith(fontWeight: AppTheme.semiBold);
textCardSubTitle() =>
    AppTheme.titleSmall.copyWith(fontWeight: AppTheme.semiBold);
textHeader() => AppTheme.displaySmall;
textBody() => AppTheme.bodyLarge.copyWith(color: MyColors.textSecondaryColor);
textPrimaryBody() => AppTheme.bodyLarge.copyWith(color: MyColors.primaryColor);
textPrimaryBodySaudiRiyal() => AppTheme.currencyMedium;
textBodySaudiRiyal() => AppTheme.currencySmall;
textSubBody() => AppTheme.bodySmall;
textInput() => AppTheme.bodyMedium;
textInputHint() =>
    AppTheme.bodyMedium.copyWith(color: MyColors.textSecondaryColor);
textPrimaryButton() =>
    AppTheme.buttonText.copyWith(color: MyColors.primaryColor);
textButton() => AppTheme.labelLarge;
textOnPrimaryButton() => AppTheme.buttonText;

InputDecoration customInputDecoration(String? label, IconData? icon) {
  return AppDecorations.inputDecoration(labelText: label, prefixIcon: icon);
}

buttonStyle() => AppDecorations.primaryButtonStyle;

buttonSecondaryStyle() => AppDecorations.secondaryButtonStyle;
buttonBackgroundStyle() => AppDecorations.outlinedButtonStyle;
buttonOnBackgroundStyle() => AppDecorations.textButtonStyle;

buttonRadius() => RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(AppTheme.radiusLG),
);

String getLanguage() {
  String lang = "ar-EG";
  if (Selected_Language.getLanguage() == "en") {
    lang = "en-US";
  }
  return lang;
}

sendError(var error) async {
  print("SAEEEEEEEED ERROR IS: $error");
  User_Helper user = User_Helper();
  // await user.sendError(error);
}

noInternet() {
  return Get.snackbar(
    "error".tr,
    "checkInternetConnection".tr,
    snackPosition: SnackPosition.TOP,
    backgroundColor: Colors.redAccent,
    colorText: Colors.white,
    duration: Duration(seconds: 2),
  );
}

double calculateRating(int totalStars, int totalUsers) {
  if (totalUsers == 0) {
    return 0.0;
  }
  double average = totalStars / totalUsers;
  return double.parse(average.toStringAsFixed(1));
}

String fixErrorMessage(String? message) {
  try {
    if (message == null) return "errorTryLater".tr;

    String m = message.toLowerCase();

    List<String> errorMessages = [
      "This exception was thrown because the response has a status code of"
          .toLowerCase(),
      "FormatException:".toLowerCase(),
      "NoSuchMethodError:".toLowerCase(),
      "is not a subtype of type".toLowerCase(),
      "was called on null".toLowerCase(),
    ];
    for (String errorMessage in errorMessages) {
      if (m.contains(errorMessage)) {
        return "errorTryLater".tr;
      }
    }

    String startConnectionErrorMessage = "ClientException with SocketException:"
        .toLowerCase();
    if (m.contains(startConnectionErrorMessage)) {
      return "check_internet_connection".tr;
    }
    // else{
    //   message = "errorTryLater".tr;
    // }
  } catch (e) {
    debugPrint("saeeed error change error message");
  }
  return message!;
}

BoxDecoration appDecoration() {
  return BoxDecoration(
    border: Border.all(color: MyColors.borderColor.withAlpha(90)),
    color: Colors.white,
    shape: BoxShape.rectangle,
    borderRadius: BorderRadius.circular(5),
  );
}

// دالة عرض خطأ الاتصال بالإنترنت مع إعادة المحاولة
Future<void> showInternetConnectionDialog(
  BuildContext context,
  VoidCallback onRetry,
) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 16,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(
              color: isDark
                  ? Colors.red.withValues(alpha: 0.3)
                  : Colors.red.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // أيقونة
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.red.withValues(alpha: 0.2)
                      : Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),

              // العنوان
              Text(
                'no_internet_connection'.tr,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // الوصف
              Text(
                'cannot_continue_without_internet'.tr,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white70 : Colors.black54,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // زر إعادة المحاولة
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onRetry();
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text('retry'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

errorView(BuildContext context, String? message) {
  message = fixErrorMessage(message);
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.red, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                'error'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message!,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        // padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('close'.tr),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

successView(BuildContext context, String? message) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.green, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                'success'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message!,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        // padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('ok'.tr),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

BuildContext? loadingDialogContext;

showDialogLoading({required BuildContext context}) {
  loadingDialogContext = context;
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [Center(child: loadAnime)],
          ),
        ),
      );
    },
  );
}

hideLoadingDialog() {
  Navigator.pop(loadingDialogContext!);
}

Widget loadAnime = SpinKitPouringHourGlass(
  duration: const Duration(seconds: 3),
  size: 40, // 50.adaptSize,
  color: MyColors.primaryColor,
);

Future<void> showPermissionDeniedDialog(
  BuildContext context,
  String desk,
) async {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("requiredPermissions".tr),
      content: Text(desk),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr),
        ),
        TextButton(
          onPressed: () => openAppSettings(),
          child: Text('open_settings'.tr),
        ),
      ],
    ),
  );
}

String formatDate(String inputDate) {
  try {
    DateTime date;
    try {
      date = DateTime.parse(inputDate);
    } catch (_) {
      String separator = inputDate.contains('-') ? '-' : '/';
      final parts = inputDate.split(separator);
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        date = DateTime(year, month, day);
      } else {
        throw Exception("Invalid date format");
      }
    }

    final months = {
      1: 'january'.tr,
      2: 'february'.tr,
      3: 'march'.tr,
      4: 'april'.tr,
      5: 'may'.tr,
      6: 'june'.tr,
      7: 'july'.tr,
      8: 'august'.tr,
      9: 'september'.tr,
      10: 'october'.tr,
      11: 'november'.tr,
      12: 'december'.tr,
    };

    String day = date.day.toString().padLeft(2, '0');
    String month = months[date.month] ?? '';
    String year = date.year.toString();

    return "$day $month $year";
  } catch (e) {
    return inputDate;
  }
}

String formatDateTime(String input) {
  try {
    DateTime dateTime;

    if (input.contains('T')) {
      dateTime = DateTime.parse(input);
    } else if (input.contains(' ')) {
      final parts = input.split(' ');
      if (parts.length >= 2) {
        final datePart = parts[0];
        final timePart = parts[1].split(':');
        final d = datePart.split('-');
        if (d.length == 3 && timePart.length >= 2) {
          dateTime = DateTime(
            int.parse(d[0]),
            int.parse(d[1]),
            int.parse(d[2]),
            int.parse(timePart[0]),
            int.parse(timePart[1]),
          );
        } else {
          throw Exception("Invalid format");
        }
      } else {
        dateTime = DateTime.parse(input);
      }
    } else {
      dateTime = DateTime.parse(input);
    }

    final months = {
      1: 'january'.tr,
      2: 'february'.tr,
      3: 'march'.tr,
      4: 'april'.tr,
      5: 'may'.tr,
      6: 'june'.tr,
      7: 'july'.tr,
      8: 'august'.tr,
      9: 'september'.tr,
      10: 'october'.tr,
      11: 'november'.tr,
      12: 'december'.tr,
    };

    String day = dateTime.day.toString();
    String month = months[dateTime.month] ?? '';
    String year = dateTime.year.toString();

    int hour = dateTime.hour;
    int minute = dateTime.minute;

    String period = hour >= 12 ? 'pm'.tr : 'am'.tr;
    int displayHour = hour % 12;
    if (displayHour == 0) displayHour = 12;

    String formattedTime =
        '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';

    return "$day $month $year، $formattedTime";
  } catch (e) {
    try {
      String datePart = input.split(RegExp(r'[T\s]')).first;
      return formatDate(datePart);
    } catch (_) {
      return input;
    }
  }
}
