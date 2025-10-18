import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../Helpers/Users.dart';
import '../shared_prff.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'MyColors.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'global_methods.dart' as gm;

// check internet
Future<bool> isInternetAvailable() async {
  try {
    final result = await InternetAddress.lookup('www.google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }
    else {
      return false;
    }
  } on SocketException catch (e) {
    return false;
  }
}

// snackbars
SnackBar errorSnackbar(String msg){
  return SnackBar(
      backgroundColor:MyColors.primaryColor,
      content: Text(msg)
  );
}

textAppBar() => TextStyle(color: MyColors.textPrimaryColor , fontSize: 16 , fontWeight: FontWeight.bold,fontFamily: "Tajawal");
textWhiteAppBar() => TextStyle(color: MyColors.whiteColor , fontSize: 16 , fontWeight: FontWeight.bold,fontFamily: "Tajawal");
textTitle() => TextStyle(color: MyColors.textPrimaryColor , fontSize: 16 , fontWeight: FontWeight.bold,fontFamily: "Tajawal");
textSubTitle() => TextStyle(color: MyColors.textPrimaryColor , fontSize: 14 , fontWeight: FontWeight.normal,fontFamily: "Tajawal");
textCardTitle() => TextStyle(color: MyColors.textPrimaryColor , fontSize: 14 , fontWeight: FontWeight.bold,fontFamily: "Tajawal");
textCardSubTitle() => TextStyle(color: MyColors.textPrimaryColor , fontSize: 12 , fontWeight: FontWeight.bold,fontFamily: "Tajawal");
textHeader() => TextStyle(color: MyColors.textPrimaryColor , fontSize: 28 , fontWeight: FontWeight.bold,fontFamily: "Tajawal");
textBody() => TextStyle(color: MyColors.textSecondaryColor , fontSize: 16 , fontWeight: FontWeight.normal,fontFamily: "Tajawal");
textPrimaryBody() => TextStyle(color: MyColors.primaryColor , fontSize: 16 , fontWeight: FontWeight.normal,fontFamily: "Tajawal");
textPrimaryBodySaudiRiyal() => TextStyle(color: MyColors.primaryColor , fontSize: 16 , fontWeight: FontWeight.normal,fontFamily: "saudi_riyal");
textBodySaudiRiyal() => TextStyle(color: MyColors.textPrimaryColor , fontSize: 16 , fontWeight: FontWeight.normal,fontFamily: "saudi_riyal");
textSubBody() => TextStyle(color: MyColors.textSecondaryColor , fontSize: 12 , fontWeight: FontWeight.normal,fontFamily: "Tajawal");
textInput() => TextStyle(color: MyColors.textPrimaryColor , fontSize: 16 , fontWeight: FontWeight.normal,fontFamily: "Tajawal");
textInputHint() => TextStyle(color: MyColors.textSecondaryColor , fontSize: 16 , fontWeight: FontWeight.normal,fontFamily: "Tajawal");
textPrimaryButton() => TextStyle(color: MyColors.primaryColor , fontSize: 16 , fontWeight: FontWeight.bold,fontFamily: "Tajawal");
textButton() => TextStyle(color: MyColors.textPrimaryColor , fontSize: 16 , fontWeight: FontWeight.bold,fontFamily: "Tajawal");
textOnPrimaryButton() => TextStyle(color: MyColors.whiteColor , fontSize: 16 , fontWeight: FontWeight.bold,fontFamily: "Tajawal");

InputDecoration customInputDecoration(String? label,IconData? icon) {
  return InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide:  BorderSide(color: MyColors.inputBorderColor,),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: MyColors.primaryColor, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: MyColors.inputBorderErrorColor, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: MyColors.inputBorderErrorColor, width: 2),
      ),
      labelStyle: gm.textInput(),
      labelText: label,
      prefixIcon: icon != null ? Icon(icon,color:MyColors.inputIconColor) : null
  );
}

buttonStyle(){
  return ElevatedButton.styleFrom(
    fixedSize: const Size(150.0, 50.0),
    textStyle: const TextStyle(
      fontWeight: FontWeight.bold, fontSize: 16,
    ),
    backgroundColor: MyColors.primaryColor,
    foregroundColor: MyColors.whiteColor,
    elevation: 15,
    // shadowColor: MyColors.dark_shadow,
    alignment: Alignment.center,
    shape: gm.buttonRadius(),
  );
}

buttonSecondaryStyle(){
  return ElevatedButton.styleFrom(
    fixedSize: const Size(150.0, 50.0),
    textStyle: const TextStyle(
      fontWeight: FontWeight.bold, fontSize: 16,
    ),
    backgroundColor: MyColors.primaryShadeColor,
    foregroundColor: MyColors.primaryColor,
    // elevation: 15,
    // shadowColor: MyColors.dark_shadow,
    alignment: Alignment.center,
    shape: gm.buttonRadius(),
  );
}

buttonBackgroundStyle(){
  return ElevatedButton.styleFrom(
    fixedSize: const Size(150.0, 50.0),
    textStyle: const TextStyle(
      fontWeight: FontWeight.bold, fontSize: 16,
    ),
    backgroundColor: MyColors.backgroundColor,
    foregroundColor: MyColors.primaryColor,
    // elevation: 15,
    // shadowColor: MyColors.dark_shadow,
    alignment: Alignment.center,
    shape: gm.buttonRadius(),
  );
}

buttonOnBackgroundStyle(){
  return ElevatedButton.styleFrom(
    fixedSize: const Size(150.0, 50.0),
    textStyle: const TextStyle(
      fontWeight: FontWeight.bold, fontSize: 16,
    ),
    backgroundColor: MyColors.onBackgroundColor,
    foregroundColor: MyColors.primaryColor,
    // elevation: 15,
    // shadowColor: MyColors.dark_shadow,
    alignment: Alignment.center,
    shape: gm.buttonRadius(),
  );
}

buttonRadius(){
  return   RoundedRectangleBorder(
      borderRadius: BorderRadius.all(( Radius.circular(16)))
  );
}

String getLanguage(){
  String lang="ar-EG";
  if(Selected_Language.getLanguage()=="en"){
    lang="en-US";
  }
  return lang;
}

sendError(var error) async{
  print("SAEEEEEEEED ERROR IS: $error");
  User_Helper user = User_Helper();
  // await user.sendError(error);
}

noInternet(){
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
  return double.parse(average.toStringAsFixed(1));}

String fixErrorMessage(String? message){
  try {
    if (message == null) return "errorTryLater".tr;

    String m = message.toLowerCase();

    List<String> errorMessages = [
      "This exception was thrown because the response has a status code of".toLowerCase(),
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

    String startConnectionErrorMessage = "ClientException with SocketException:".toLowerCase();
    if(m.contains(startConnectionErrorMessage)) {
      return "check_internet_connection".tr;
    }
    // else{
    //   message = "errorTryLater".tr;
    // }
  }catch(e){
    debugPrint("saeeed error change error message");
  }
  return message!;
}


BoxDecoration appDecoration() {
  return BoxDecoration(
    border: Border.all(color: MyColors.borderColor.withAlpha(90),
    ),
    color: Colors.white,
    shape: BoxShape.rectangle,
    borderRadius: BorderRadius.circular(5),


  );
}


errorView(BuildContext context, String? message) {
  message = fixErrorMessage(message);
  return  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
                child: const Icon(
                  Icons.close,
                  color: Colors.red,
                  size: 32,
                ),
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
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
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
              )
            ],
          ),
        ),
      );
    },
  );




}

successView(BuildContext context, String? message) {
  return   showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
                child: const Icon(
                  Icons.check,
                  color: Colors.green,
                  size: 32,
                ),
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
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
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
              )
            ],
          ),
        ),
      );
    },
  );




}

BuildContext ? loadingDialogContext;

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
              children: [
                Center(
                  child: loadAnime,
                )
              ],
            ),
          ),
        );
      });
}

hideLoadingDialog(){
  Navigator.pop(loadingDialogContext!);
}

Widget loadAnime = SpinKitPouringHourGlass(
  duration: const Duration(seconds: 3),
  size: 40,// 50.adaptSize,
  color: MyColors.primaryColor,
);

Future<void> showPermissionDeniedDialog(BuildContext context,String desk) async {
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

    String formattedTime = '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';

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