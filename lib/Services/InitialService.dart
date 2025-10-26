import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'dart:ui' as ui;

class InitialService extends GetxService {
  static InitialService get to => Get.find();

  RxBool userHasCompletedData = false.obs;
  RxBool userHasBookingsToPay = false.obs;
  RxInt userType = 0.obs;
  RxInt vat = 0.obs;

  RxString userEmail = "".obs;
  RxString userName = "".obs;
  RxString userImage = "".obs;
  RxString userPhone = "".obs;

  @override
  void onInit() {
    super.onInit();
    loadMapTargetIcon();
    loadMapTargetIcon2();
    loadMapStatusIcons();
  }

    late Uint8List mapTargetIcon;
  late Uint8List mapMyPointIcon;
  late Uint8List mapTargetInProgressIcon;
  late Uint8List mapTargetCompletedIcon;
  late Uint8List mapTargetAdvertisedIcon;
  late Uint8List mapTargetRunningIcon;
  // loadMapTargetIcon() async {
  //   try {
  //     final ByteData bytes = await rootBundle.load('assets/images/target.png');
  //     final Uint8List list = bytes.buffer.asUint8List();
  //
  //     // 1. فك تشفير الصورة المضغوطة (PNG/JPEG) إلى كائن ui.Image
  //     // هذا يضمن أن البيانات الداخلية للصورة مفكوكة التشفير وجاهزة
  //     final Completer<ui.Image> completer = Completer();
  //     ui.decodeImageFromList(list, (ui.Image image) {
  //       completer.complete(image);
  //     });
  //     final ui.Image image = await completer.future;
  //
  //     // 2. إعادة تشفير الصورة إلى ByteData بتنسيق PNG
  //     // (PNG هو التنسيق الأكثر شيوعاً لدعم الشفافية وARGB_8888)
  //     final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  //
  //     if (byteData != null) {
  //       mapTargetIcon = byteData.buffer.asUint8List();
  //       print("Marker icon successfully decoded to PNG/ARGB_8888 format.");
  //     } else {
  //       // في حالة فشل التحويل (نادرة)
  //       mapTargetIcon = list; // العودة إلى الأصل
  //     }
  //
  //   } catch (e) {
  //     print("Error loading and decoding map icon: $e");
  //     // يمكنك هنا تحميل صورة احتياطية أو استخدام list مباشرة إذا فشل فك التشفير
  //     final ByteData bytes = await rootBundle.load('assets/images/target.png');
  //     mapTargetIcon = bytes.buffer.asUint8List();
  //   }
  // }
  // loadMapTargetIcon2() async {
  //   try {
  //     final ByteData bytes = await rootBundle.load('assets/images/myPoint.png');
  //     final Uint8List list = bytes.buffer.asUint8List();
  //
  //     // 1. فك تشفير الصورة المضغوطة (PNG/JPEG) إلى كائن ui.Image
  //     // هذا يضمن أن البيانات الداخلية للصورة مفكوكة التشفير وجاهزة
  //     final Completer<ui.Image> completer = Completer();
  //     ui.decodeImageFromList(list, (ui.Image image) {
  //       completer.complete(image);
  //     });
  //     final ui.Image image = await completer.future;
  //
  //     // 2. إعادة تشفير الصورة إلى ByteData بتنسيق PNG
  //     // (PNG هو التنسيق الأكثر شيوعاً لدعم الشفافية وARGB_8888)
  //     final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  //
  //     if (byteData != null) {
  //       mapMyPointIcon = byteData.buffer.asUint8List();
  //       print("Marker icon successfully decoded to PNG/ARGB_8888 format.");
  //     } else {
  //       // في حالة فشل التحويل (نادرة)
  //       mapMyPointIcon = list; // العودة إلى الأصل
  //     }
  //
  //   } catch (e) {
  //     print("Error loading and decoding map icon: $e");
  //     // يمكنك هنا تحميل صورة احتياطية أو استخدام list مباشرة إذا فشل فك التشفير
  //     final ByteData bytes = await rootBundle.load('assets/images/myPoint.png');
  //     mapMyPointIcon = bytes.buffer.asUint8List();
  //   }
  // }
  loadMapTargetIcon() async {
    final ByteData bytes = await rootBundle.load('assets/images/target.png');
    mapTargetIcon = bytes.buffer.asUint8List();
  }


  loadMapTargetIcon2() async {
    final ByteData bytes = await rootBundle.load('assets/images/myPoint.png');
    mapMyPointIcon = bytes.buffer.asUint8List();
  }

  loadMapStatusIcons() async {
    // تحميل أيقونات الحالات المختلفة
    final ByteData inProgressBytes = await rootBundle.load(
      'assets/images/target_in_progress.png',
    );
    mapTargetInProgressIcon = inProgressBytes.buffer.asUint8List();

    final ByteData completedBytes = await rootBundle.load(
      'assets/images/target_complete.png',
    );
    mapTargetCompletedIcon = completedBytes.buffer.asUint8List();

    final ByteData advertisedBytes = await rootBundle.load(
      'assets/images/target_advertiser.png',
    );
    mapTargetAdvertisedIcon = advertisedBytes.buffer.asUint8List();

    final ByteData runningBytes = await rootBundle.load(
      'assets/images/target_running.png',
    );
    mapTargetRunningIcon = runningBytes.buffer.asUint8List();
  }

  // دالة للحصول على الأيقونة المناسبة حسب main_status
  Uint8List getIconForMainStatus(String mainStatus) {
    switch (mainStatus) {
      case 'in_progress':
        return mapTargetInProgressIcon;
      case 'completed':
        return mapTargetCompletedIcon;
      case 'advertised':
        return mapTargetAdvertisedIcon;
      case 'running':
        return mapTargetRunningIcon;
      default:
        return mapTargetInProgressIcon;
    }
  }
}
