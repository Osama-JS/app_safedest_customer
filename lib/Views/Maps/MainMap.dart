import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:save_dest_customer/Views/Widgets/ProgressWithIcon.dart';
import '../../Controllers/MapController.dart';
import '../../Globals/MyColors.dart';
import '../../Globals/style.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_decorations.dart';
import '../../Models/MapModel.dart';
import '../../Services/InitialService.dart';
import '../../shared_prff.dart';
import '../../Globals/global_methods.dart' as GM;
import '../../Globals/global.dart' as globals;
import 'package:http/http.dart' as http;
import '../TaskViews/AddTaskViews/AddTaskPage.dart';

// 💡 إضافة مساعدة لتحويل اللون إلى صيغة Hex لاستخدامها في Mapbox Line Color
extension ColorExtension on Color {
  String toHexString() {
    return '#${(value & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
  }
}

class MainMap extends StatefulWidget {
  const MainMap({super.key});

  @override
  State<MainMap> createState() => _MainMap();
}

class _MainMap extends State<MainMap> {
  final iniService = InitialService.to;

  MapboxMap? mapboxMap;
  PointAnnotationManager? annotationManager;

  final Completer<MapboxMap> _mapboxMapCompleter = Completer();

  MapController mapController = Get.put(MapController());

  // استخدام البنية الصحيحة لـ Point
  Point iniLocation = Point(
    coordinates: Position(39.8262, 21.4225),
  ); // (Lng, Lat)

  final loc.Location _location = loc.Location();
  CameraOptions? _initialCameraOptions;

  // 🏆 إضافة: لتخزين الوجهة المحددة حاليًا
  Point? _currentDestination;

  @override
  void initState() {
    super.initState();
    globals.dashboardIndex = 0;

    mapController.showInfo.value = false;
    mapController.isLoadingData.value = true;
    mapController.tapedIndex.value = -1;
    mapController.getData();

    _initialCameraOptions = CameraOptions(
      center: iniLocation,
      zoom: 2.0,
      // pitch: 0
    );

    // startLocationTracking();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _locationSubscription?.cancel();
    searchQuery.close();
    searchResults.close();
    annotationManager?.deleteAll();
    super.dispose();
  }

  // تهيئة AnnotationManager
  void _onMapCreated(MapboxMap controller) async {
    _mapboxMapCompleter.complete(controller);
    mapboxMap = controller;

    // mapboxMap!.location.updateSettings(LocationComponentSettings(enabled: true));

    annotationManager = await controller.annotations
        .createPointAnnotationManager();

    annotationManager!.tapEvents(
      onTap: (annotation) {
        print("Marker Tapped: ${annotation.textField}");
        final index = mapController
            .markersMap[annotation.textField]; // Mapbox يُنشئ ID تلقائي
        if (index != null) {
          mapController.tapedIndex.value = index;
          mapController.showInfo.value = true;
        }
        return true;
      },
    );

    // // استخدام البنية الصحيحة لـ Point
    Point initialMyPoint = Point(
      coordinates: Position(
        double.parse(mapController.myLong.value),
        double.parse(mapController.myLate.value),
      ),
    );
    _updateMarkers(initialMyPoint);
  }

  RxBool isLoading = true.obs;

  StreamSubscription<loc.LocationData>? _locationSubscription;

  // void startLocationTracking() async {
  //   bool serviceEnabled = await _location.serviceEnabled();
  //   if (!serviceEnabled) {
  //     serviceEnabled = await _location.requestService();
  //     if (!serviceEnabled) return;
  //   }
  //
  //   var permission = await _location.requestPermission();
  //   if (permission == loc.PermissionStatus.denied) return;
  //
  //   _locationSubscription?.cancel();
  //
  //   // 🏆 التعديل الأساسي: تفعيل distanceFilter بقيمة 5 أمتار
  //   _location.changeSettings(
  //     accuracy: loc.LocationAccuracy.high,
  //     interval: 1000,
  //     distanceFilter: 5, // التحديث فقط بعد الحركة بـ 5 أمتار
  //   );
  //
  //
  //   _locationSubscription = _location.onLocationChanged.listen((loc.LocationData currentLocation) {
  //     // استخدام البنية الصحيحة لـ Point (Long, Lat)
  //     Point myPoint = Point(coordinates: Position(currentLocation.longitude!, currentLocation.latitude!));
  //     mapController.myLong.value = currentLocation.longitude.toString();
  //     mapController.myLate.value = currentLocation.latitude.toString();
  //
  //     if (mapController.myLate.value != "21.4225" && isLoading.value) {
  //       isLoading.value = false;
  //       _moveCamera(myPoint);
  //       _updateMarkers(myPoint);
  //     } else if (!isLoading.value) {
  //       _updateMarkers(myPoint);
  //
  //     }
  //   });
  // }

  Future<void> _moveCamera(Point position) async {
    if (mapboxMap != null) {
      await mapboxMap!.easeTo(
        CameraOptions(center: position, zoom: 14.0),
        MapAnimationOptions(duration: 1000, startDelay: 0),
      );
    }
  }

  Future<void> _searchMoveCamera(var index) async {
    if (mapboxMap != null) {
      Point p = mapController.positions.elementAt(index);
      await mapboxMap!.easeTo(
        CameraOptions(center: p, zoom: 14.0),
        MapAnimationOptions(duration: 1000, startDelay: 0),
      );
    }
  }

  // مفتاح Mapbox Access Token
  final String _mapboxAccessToken =
      "pk.eyJ1Ijoib3NhbWExOTk4IiwiYSI6ImNtZ280cmw1YjFwNHQya3FxZnY2cjV5cmkifQ.gugWvJf_2VRFnk-3LVaI1w";

  void _updateMarkers(Point myPosition) async {
    if (annotationManager == null) return;

    // await annotationManager!.deleteAll();

    // 1. إضافة علامة الموقع الحالي
    // final currentMarkerOptions = PointAnnotationOptions(
    //   textField: '',
    //   geometry: myPosition,
    //   iconSize: 0.3,
    //   // 💡 تم ضبط الإزاحة لتثبيت طرف الأيقونة على الموقع
    //   iconOffset: [0.0, -17.0],
    //
    //   symbolSortKey: 0,
    //   image: iniService.mapMyPointIcon,
    //
    // );
    // await annotationManager!.create(currentMarkerOptions);

    // 2. إضافة علامات البيانات الأخرى
    await annotationManager!.createMulti(
      mapController.mapMarkersOptions.toList(),
    );
    print("nnnnnns");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {},
      child: Scaffold(
        backgroundColor: Theme_pref.getTheme() == 0
            ? MyColors.lightBackground
            : MyColors.darkBackground,
        body: SafeArea(
          top: true, // Preserve status bar area
          child: Obx(
            () => mapController.isLoadingData.value
                ? Center(child: ProgressWithIcon())
                : Stack(
                    children: [
                      SizedBox(
                        height: double.infinity,
                        width: double.infinity,
                        child: MapWidget(
                          styleUri: MapboxStyles.MAPBOX_STREETS,
                          cameraOptions: _initialCameraOptions,

                          onMapCreated: _onMapCreated,

                          onTapListener: (point) {
                            mapController.showInfo.value = false;
                            FocusScope.of(context).unfocus();
                            searchQuery.value = '';
                            searchResults.clear();

                            _currentDestination = null; // مسح الوجهة
                          },
                        ),
                      ),

                      Positioned(
                        top: 8,
                        left: 20,
                        right: 20,
                        child: mapSearchWidget(),
                      ),

                      // زر إنشاء مهمة جديدة
                      Positioned(
                        bottom: 30,
                        right: 20,
                        child: FloatingActionButton(
                          onPressed: () {
                            Get.to(
                              () => AddTaskPage(
                                stepTwoResponse: http.Response('{}', 200),
                                priceMethodId: 1,
                              ),
                            );
                          },
                          backgroundColor: MyColors.primaryColor,
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),

                      if (mapController.showInfo.value)
                        Positioned(
                          bottom: 20,
                          left: 0,
                          right: 0,
                          child: Container(
                            // height: 290,
                            child: _buildInfo(context),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  RxList<MapModel> searchResults = <MapModel>[].obs;
  RxString searchQuery = ''.obs;
  Timer? _debounceTimer;

  void search(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      searchQuery.value = query.toLowerCase().trim();
      if (searchQuery.value.isEmpty) {
        searchResults.clear();
      } else {
        searchResults.assignAll(
          mapController.dataList.where((item) {
            final q = searchQuery.value;
            return (item.pickupAddress.value.toLowerCase().contains(q) ||
                item.deliveryAddress.value.toLowerCase().contains(q) ||
                (item.driverName?.value != null &&
                    item.driverName!.value.toLowerCase().contains(q)) ||
                (item.driverPhone?.value != null &&
                    item.driverPhone!.value.toLowerCase().contains(q)) ||
                (item.vehicle?.value != null &&
                    item.vehicle!.value.toLowerCase().contains(q)) ||
                item.status.value.toLowerCase().contains(q) ||
                item.id.value.toString().contains(q));
          }).toList(),
        );
      }
    });
  }

  Widget _buildInfo(BuildContext context) {
    bool hasDriver =
        mapController.dataList[mapController.tapedIndex.value].driverName !=
            null &&
        mapController
            .dataList[mapController.tapedIndex.value]
            .driverName!
            .isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- رقم المهمة والحالة ---
            Row(
              children: [
                Text(
                  '#${mapController.dataList[mapController.tapedIndex.value].id.value}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    mapController
                        .dataList[mapController.tapedIndex.value]
                        .status
                        .value,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // --- السعر والعملة ---
            Text(
              '${mapController.dataList[mapController.tapedIndex.value].price.value.toStringAsFixed(2)} ${mapController.dataList[mapController.tapedIndex.value].currency.value}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),

            // --- موقع الاستلام (Pickup) ---
            _buildLocationSection(
              icon: Icons.location_on_outlined,
              title: 'موقع الاستلام',
              address: mapController
                  .dataList[mapController.tapedIndex.value]
                  .pickupAddress
                  .value,
            ),
            const SizedBox(height: 12),

            // --- موقع التسليم (Delivery) ---
            _buildLocationSection(
              icon: Icons.delivery_dining_outlined,
              title: 'موقع التسليم',
              address: mapController
                  .dataList[mapController.tapedIndex.value]
                  .deliveryAddress
                  .value,
            ),
            const SizedBox(height: 12),

            // --- بيانات السائق (إن وُجد) ---
            if (hasDriver)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'بيانات السائق',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (mapController
                                  .dataList[mapController.tapedIndex.value]
                                  .driverImage !=
                              null &&
                          mapController
                              .dataList[mapController.tapedIndex.value]
                              .driverImage!
                              .isNotEmpty)
                        ClipOval(
                          child: Image.network(
                            mapController
                                .dataList[mapController.tapedIndex.value]
                                .driverImage!
                                .value,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const CircleAvatar(child: Icon(Icons.person)),
                          ),
                        )
                      else
                        const CircleAvatar(child: Icon(Icons.person)),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mapController
                                .dataList[mapController.tapedIndex.value]
                                .driverName!
                                .value,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (mapController
                                      .dataList[mapController.tapedIndex.value]
                                      .driverPhone !=
                                  null &&
                              mapController
                                  .dataList[mapController.tapedIndex.value]
                                  .driverPhone!
                                  .isNotEmpty)
                            Text(
                              mapController
                                  .dataList[mapController.tapedIndex.value]
                                  .driverPhone!
                                  .value,
                              style: const TextStyle(color: Colors.grey),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),

            // --- نوع المركبة (إن وُجد) ---
            if (mapController
                        .dataList[mapController.tapedIndex.value]
                        .vehicle !=
                    null &&
                mapController
                    .dataList[mapController.tapedIndex.value]
                    .vehicle!
                    .isNotEmpty)
              Text.rich(
                TextSpan(
                  text: 'المركبة: ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: mapController
                          .dataList[mapController.tapedIndex.value]
                          .vehicle!
                          .value,
                      style: const TextStyle(fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),

            // --- تاريخ الإنشاء ---
            Text(
              'أنشئت في: ${GM.formatDateTime(mapController.dataList[mapController.tapedIndex.value].createdAt.value)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget mapSearchWidget() {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacing4),
      child: Column(
        children: [
          // Search Field
          Container(
            decoration: AppDecorations.cardDecoration.copyWith(
              boxShadow: AppTheme.shadowLG,
            ),
            child: TextField(
              style: AppTheme.bodyMedium,
              decoration:
                  AppDecorations.inputDecoration(
                    hintText: 'search'.tr,
                    prefixIcon: Icons.search_outlined,
                  ).copyWith(
                    filled: true,
                    fillColor: MyColors.whiteColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                      borderSide: BorderSide(
                        color: MyColors.primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
              onChanged: (query) => search(query),
            ),
          ),
          // Search Results
          Obx(() => _buildSearchResults()),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (searchQuery.isEmpty) {
      return const SizedBox();
    }
    bool hasDriver =
        mapController.dataList[mapController.tapedIndex.value].driverName !=
            null &&
        mapController
            .dataList[mapController.tapedIndex.value]
            .driverName!
            .isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 200),
          child: Obx(
            () => ListView.builder(
              shrinkWrap: true,
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final item = searchResults[index];
                return InkWell(
                  onTap: () {
                    searchQuery.value = '';
                    searchResults.clear();
                    FocusScope.of(context).unfocus();

                    mapController.tapedIndex.value = mapController.dataList
                        .indexOf(item);
                    mapController.showInfo.value = true;
                    _searchMoveCamera(mapController.tapedIndex.value);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- رقم المهمة والحالة ---
                      Row(
                        children: [
                          Text(
                            '#${item.id.value}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withAlpha(30),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item.status.value,
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // --- السعر والعملة ---
                      Text(
                        '${item.price.value.toStringAsFixed(2)} ${item.currency.value}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // --- موقع الاستلام (Pickup) ---
                      _buildLocationSection(
                        icon: Icons.location_on_outlined,
                        title: 'موقع الاستلام',
                        address: item.pickupAddress.value,
                      ),
                      const SizedBox(height: 12),

                      // --- موقع التسليم (Delivery) ---
                      _buildLocationSection(
                        icon: Icons.delivery_dining_outlined,
                        title: 'موقع التسليم',
                        address: item.deliveryAddress.value,
                      ),
                      const SizedBox(height: 12),

                      // --- بيانات السائق (إن وُجد) ---
                      if (hasDriver)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'بيانات السائق',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                if (item.driverImage != null &&
                                    item.driverImage!.isNotEmpty)
                                  ClipOval(
                                    child: Image.network(
                                      item.driverImage!.value,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const CircleAvatar(
                                            child: Icon(Icons.person),
                                          ),
                                    ),
                                  )
                                else
                                  const CircleAvatar(child: Icon(Icons.person)),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.driverName!.value,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (item.driverPhone != null &&
                                        item.driverPhone!.isNotEmpty)
                                      Text(
                                        item.driverPhone!.value,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),

                      // --- نوع المركبة (إن وُجد) ---
                      if (item.vehicle != null && item.vehicle!.isNotEmpty)
                        Text.rich(
                          TextSpan(
                            text: 'المركبة: ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                text: item.vehicle!.value,
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // --- تاريخ الإنشاء ---
                      Text(
                        'أنشئت في: ${GM.formatDateTime(item.createdAt.value)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationSection({
    required IconData icon,
    required String title,
    required String address,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey),
            const SizedBox(width: 6),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          address,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
        ),
      ],
    );
  }
}
