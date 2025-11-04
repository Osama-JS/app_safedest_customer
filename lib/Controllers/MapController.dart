import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'; // استبدال مكتبة Google Maps
import 'package:get/get.dart';
import '../Models/MapModel.dart';
import '../Helpers/MapHelper.dart';
import '../Services/InitialService.dart';
import '../shared_prff.dart';
import '../../Globals/global.dart' as globals;
import '../Globals/global_methods.dart' as GM;
import 'dart:math';
// import 'package:flutter/services.dart' show rootBundle;
// import 'dart:typed_data';

// لا نحتاج لـ LatLng من مكتبة Google Maps هنا

class MapController extends GetxController {
  final iniService = InitialService.to;

  @override
  void onInit() {
    super.onInit();
    tapedIndex.value = 0;
    getData();
  }



  MapHelper helperData = MapHelper();

  // Mapbox يستخدم Longitude ثم Latitude
  RxString myLong = "39.8262".obs; // الطول
  RxString myLate = "21.4225".obs; // العرض

  // استخدام PointAnnotationOptions لتخزين خيارات العلامات
  RxList<PointAnnotationOptions> mapMarkersOptions =
      <PointAnnotationOptions>[].obs;

  var dataList = <MapModel>[].obs;
  RxBool isLoadingData = true.obs;

  // إحصائيات المهام حسب main_status
  RxMap<String, int> taskStats = <String, int>{}.obs;

  // استخدام Point من Mapbox للإحداثيات
  RxList<Point> positions = <Point>[].obs;
  final markersMap =
      <String, String>{}.obs; // لتخزين العلاقة بين markerId والـ index

  RxInt tapedIndex = 0.obs;
  RxBool showInfo = false.obs;

  RxList<int> tapedIndexes = <int>[].obs;
  RxBool showMInfo = false.obs;

  // لحفظ معرفات العلامات التي تم إنشاؤها على الخريطة لتحديثها
  final RxList<String> createdAnnotationIds = <String>[].obs;

  getData() async {
    try {
      isLoadingData.value = true;
      var data = await helperData.getData(Token_pref.getToken());

      if (data["status"] == 200) {
        final List<dynamic> dataListJson = data["data"];
        print("ssssssssaeeed data : ${data["data"]}");
        dataList.clear();
        dataList.value = dataListJson
            .map((item) => MapModel.fromJson(item))
            .toList();
        print("ssssssssaeeed data : ${dataList.length}");

        for(var item in dataList){
          print("hey saeed item is: ${item.toJson().toString()}");
        }

        mapMarkersOptions.clear();
        positions.clear();
        markersMap.clear();


        // for (int i = 0; i < dataList.length; i++) {
        //   final mapdata = dataList[i];
        //   final markerId = '${mapdata.id.value}';
        //   markersMap[markerId] = i;
        //
        //   // **********************************************
        //   // ** التعديل هنا: استخدام Position() بدلاً من Point.fromLngLat() **
        //   // **********************************************
        //
        //   // Mapbox يستخدم (Longitude, Latitude)
        //   Position positionCoordinates = Position(
        //     double.parse(mapdata.lng.value), // Longitude (الطول)
        //     double.parse(mapdata.lat.value), // Latitude (العرض)
        //   );
        //
        //   // إنشاء Point
        //   Point point = Point(coordinates: positionCoordinates);
        //
        //   positions.add(point);
        //
        //   // إنشاء PointAnnotationOptions بدلاً من Marker
        //   // اختيار الأيقونة المناسبة حسب main_status
        //   print("niaaaaaaaaaaaaaaaaaaa saeed icon $i: ${dataList[i].id.value}: ${dataList[i].mainStatus.value}");
        //   final iconImage = iniService.getIconForMainStatus(
        //     dataList[i].mainStatus.value,
        //   );
        //
        //   mapMarkersOptions.add(
        //     PointAnnotationOptions(
        //       textField: markerId.toString(),
        //       geometry: point,
        //       textColor: Colors.transparent.value,
        //       iconSize: 0.5,
        //       // iconOffset: [0.0, -17.0],
        //       symbolSortKey: markersMap[markerId]!.toDouble(),
        //       image: iconImage,
        //     ),
        //   );
        // }

        generateClusteredMarkers();
        // حساب الإحصائيات
        _calculateTaskStats();

        isLoadingData.value = false;
      }
    } catch (e) {
      isLoadingData.value = false;
      print("MapController error: $e");
      GM.sendError("MapController : $e");
    }
  }

  // حساب إحصائيات المهام حسب main_status
  void _calculateTaskStats() {
    taskStats.clear();

    // تهيئة العدادات
    taskStats['in_progress'] = 0;
    taskStats['advertised'] = 0;
    taskStats['running'] = 0;
    taskStats['completed'] = 0;

    // حساب العدد لكل حالة
    for (var task in dataList) {
      final mainStatus = task.mainStatus.value;
      if (taskStats.containsKey(mainStatus)) {
        taskStats[mainStatus] = taskStats[mainStatus]! + 1;
      }
    }
  }





RxDouble currentZoom = 2.0.obs;




  double _calculateGeoDistance(double lat1, double lng1, double lat2, double lng2) {
    // هذه دالة تحويل المسافة الجغرافية إلى قيمة نسبية
    const double R = 6371.0; // نصف قطر الأرض بالكيلومتر

    // قيمة ثابتة للباي (تقريبا) لتحويل الدرجات إلى راديان
    const double degToRad = pi / 180.0;

    // تحويل الدرجات إلى راديان
    final lat1Rad = lat1 * degToRad;
    final lat2Rad = lat2 * degToRad;
    final dLat = (lat2 - lat1) * degToRad;
    final dLng = (lng2 - lng1) * degToRad;

    // صيغة هافرسين
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) *
            sin(dLng / 2) * sin(dLng / 2);

    // استخدام atan2(y, x) حيث y هي جذر a و x هي جذر (1-a)
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c; // المسافة بالكيلومتر
  }
  void generateClusteredMarkers() {

    mapMarkersOptions.clear();

    final int quantizedLevel = getQuantizedZoomLevel(currentZoom.value);

    double clusterDistanceKm = 0.0;

    // 2. تعيين المسافة بناءً على المستويات الأربعة
    // ⚠️ يمكنك تعديل هذه المسافات لتناسب التوزيع الجغرافي لبياناتك ⚠️
    switch (quantizedLevel) {
      case 1:
      // الزووم الأبعد (تقريباً 1.0 إلى 4.25)
        clusterDistanceKm = 10.0; // تجميع نطاق واسع (10 كيلومترات)
        break;
      case 2:
      // الزووم المتوسط البعيد (تقريباً 4.25 إلى 7.5)
        clusterDistanceKm = 2.0; // تجميع متوسط
        break;
      case 3:
      // الزووم المتوسط القريب (تقريباً 7.5 إلى 10.75)
        clusterDistanceKm = 0.5; // تجميع ضيق (500 متر)
        break;
      case 4:
      // الزووم الأقرب (تقريباً 10.75 إلى 14.0)
        clusterDistanceKm = 0.05; // تجميع للمواقع المتطابقة تقريباً (50 متر)
        break;
      default:
      // لأي حالة زووم غير متوقعة (خارج 1-14)
        clusterDistanceKm = 0.0;
        break;
    }


    // double clusterDistanceKm = 0.0;
    //
    // if (currentZoom.value < 8) {
    //   clusterDistanceKm = 5.0; // تجميع كبير للمناطق البعيدة
    // } else if (currentZoom.value < 12) {
    //   clusterDistanceKm = 0.5; // تجميع متوسط
    // } else {
    //   // لن يتم استدعاء هذه الدالة إذا كان الزووم مرتفعاً جداً (حسب clusterThresholdZoom)
    //   clusterDistanceKm = 0.05;
    // }


    final List<MapModel> remainingData = List.from(dataList);
    final List<List<MapModel>> finalClusters = [];
    // final List<MapModel> clusteredItems = [];

    // 1. تطبيق منطق التجميع المعتمد على المسافة (DBSCAN بسيط)
    while (remainingData.isNotEmpty) {
      final referenceItem = remainingData.removeAt(0);

      double? refLat = double.tryParse(referenceItem.lat.value);
      double? refLng = double.tryParse(referenceItem.lng.value);

      if (refLat == null || refLng == null) continue;

      List<MapModel> currentCluster = [referenceItem];

      // البحث عن العناصر القريبة
      for (int i = remainingData.length - 1; i >= 0; i--) {
        final targetItem = remainingData[i];

        double? targetLat = double.tryParse(targetItem.lat.value);
        double? targetLng = double.tryParse(targetItem.lng.value);

        if (targetLat == null || targetLng == null) continue;

        final distance = _calculateGeoDistance(
            refLat, refLng, targetLat, targetLng
        );

        if (distance <= clusterDistanceKm) {
          currentCluster.add(remainingData.removeAt(i));
        }
      }
      finalClusters.add(currentCluster);
    }

    // 2. إنشاء علامات العرض النهائية من المجموعات
    int index = 0;

    for (var clusterItems in finalClusters) {
      final int clusterCount = clusterItems.length;
      final MapModel firstItem = clusterItems.first;

      double? lat = double.tryParse(firstItem.lat.value);
      double? lng = double.tryParse(firstItem.lng.value);

      if (lat == null || lng == null) continue;
      Position positionCoordinates = Position(
        lng, // Longitude (الطول)
        lat, // Latitude (العرض)
      );
      Point point = Point(coordinates: positionCoordinates);


      // final String markerId = clusterCount > 1 ? 'Cluster_${index}' : '${firstItem.id.value}';
       String markerId = "";

      Uint8List iconImage;
      String annotationText;
      double iconSize;

      if (clusterCount > 1) {

        for(var item in clusterItems){
          if(markerId!=""){
            markerId+=",${item.id.value}";
          }else{
            markerId+="${item.id.value}";
          }
        }
        markersMap[markerId] = markerId;

        // حالة التجميع
        iconImage = iniService.mapTargetIcon; // يجب توفيرها
        // annotationText = ".$clusterCount";
        annotationText = markerId;
        iconSize = 0.5;
      } else {
        // حالة علامة فردية
        markerId ="${firstItem.id.value}";

        markersMap[markerId] = markerId;


        iconImage = iniService.getIconForMainStatus(firstItem.mainStatus.value);
        annotationText = markerId;
        iconSize = 0.3;

      }

      // Point point = Point.fromLngLat(lng, lat);
      positions.add(point);

      mapMarkersOptions.add(
        PointAnnotationOptions(
          textField: annotationText,
          // textHaloColor: Colors.white.value,
          textHaloWidth: 1.5,
          textSize: 14.0,
          // textColor: clusterCount > 1 ? Colors.black.value : Colors.transparent.value,
          textColor:  Colors.transparent.value,
          geometry: point,
          iconSize: 0.3,//iconSize,
          iconOffset: [0.0, -17.0],
          symbolSortKey: index.toDouble(),
          image: iconImage,
        ),
      );
      index++;
    }
  }


  int getQuantizedZoomLevel(double zoom) {
    const double minZoom = 1.0;
    const double maxZoom = 14.0;
    const int numLevels = 4;

    // حساب حجم كل قسم (المسافة بين العتبات)
    final double zoomRange = maxZoom - minZoom;
    final double levelSize = zoomRange / numLevels; // 13 / 4 = 3.25

    if (zoom < minZoom) return 0;
    if (zoom >= maxZoom) return numLevels;

    // حساب القسم الذي تقع فيه قيمة الزوم الحالية
    // مثال: إذا كان الزووم 4.0، (4.0 - 1.0) / 3.25 = 0.92 -> (int) 0 + 1 = 1
    // مثال: إذا كان الزووم 10.0، (10.0 - 1.0) / 3.25 = 2.76 -> (int) 2 + 1 = 3
    final int level = ((zoom - minZoom) / levelSize).floor();

    // إضافة 1 لجعل المستويات تبدأ من 1 (أو يمكن استخدام القيمة مباشرة)
    return level + 1;
  }


}
