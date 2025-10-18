import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'; // استبدال مكتبة Google Maps
import 'package:get/get.dart';
import '../Models/MapModel.dart';
import '../Helpers/MapHelper.dart';
import '../Services/InitialService.dart';
import '../shared_prff.dart';
import '../../Globals/global.dart' as globals;
import '../Globals/global_methods.dart' as GM;
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
  RxList<PointAnnotationOptions> mapMarkersOptions = <PointAnnotationOptions>[]
      .obs;

  var dataList = <MapModel>[].obs;
  RxBool isLoadingData = true.obs;

  // استخدام Point من Mapbox للإحداثيات
  RxList<Point> positions = <Point>[].obs;
  final markersMap = <String, int>{}
      .obs; // لتخزين العلاقة بين markerId والـ index

  RxInt tapedIndex = 0.obs;
  RxBool showInfo = false.obs;

  // لحفظ معرفات العلامات التي تم إنشاؤها على الخريطة لتحديثها
  final RxList<String> createdAnnotationIds = <String>[].obs;



  getData() async {
    try {
      isLoadingData.value = true;
      var data = await helperData.getData(Token_pref.getToken());

      if (data["status"] == 200) {
        final List<dynamic> dataListJson = data["data"];
        dataList.clear();
        dataList.value = dataListJson.map((item) => MapModel.fromJson(item)).toList();
        mapMarkersOptions.clear();
        positions.clear();
        markersMap.clear();

        for (int i = 0; i < dataList.length; i++) {
          print("nnnnnnnnnnnniaaaaaaaaaaaaaaaaaaaa$i");
          final mapdata = dataList[i];
          final markerId = '${mapdata.id.value}';
          markersMap[markerId] = i;

          // **********************************************
          // ** التعديل هنا: استخدام Position() بدلاً من Point.fromLngLat() **
          // **********************************************

          // Mapbox يستخدم (Longitude, Latitude)
          Position positionCoordinates = Position(
              double.parse(mapdata.lng.value), // Longitude (الطول)
              double.parse(mapdata.lat.value) // Latitude (العرض)
          );


          // إنشاء Point
          Point point = Point(coordinates: positionCoordinates);

          positions.add(point);

          // إنشاء PointAnnotationOptions بدلاً من Marker
          mapMarkersOptions.add(
            PointAnnotationOptions(
              textField: markerId.toString(),
              geometry: point,
              textColor: Colors.transparent.value,
              iconSize: 1,
              iconOffset: [0.0, -17.0],
              symbolSortKey: markersMap[markerId]!.toDouble(),
              image: iniService.mapTargetIcon,
            ),
          );
        }

        isLoadingData.value = false;
      }


    } catch (e) {
      isLoadingData.value = false;
      print("MapController error: $e");
      GM.sendError("MapController : $e");
    }
  }

}