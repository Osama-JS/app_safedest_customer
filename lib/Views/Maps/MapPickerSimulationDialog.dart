import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../Globals/MyColors.dart';
import '../../Services/InitialService.dart';



class MapPickerSimulationDialog extends StatefulWidget {
  final bool isPickup;
  final double? initialLat;
  final double? initialLng;

  const MapPickerSimulationDialog({
    super.key,
    required this.isPickup,
    this.initialLat,
    this.initialLng,
  });

  @override
  State<MapPickerSimulationDialog> createState() => _MapPickerSimulationDialogState();
}

class _MapPickerSimulationDialogState extends State<MapPickerSimulationDialog> {
  double selectedLat = 0.0;
  double selectedLng = 0.0;
  String selectedAddress = "لم يتم تحديد الموقع بعد";
  final iniService = InitialService.to;


  final Completer<MapboxMap> _mapboxMapCompleter = Completer();
  MapboxMap? mapboxMap;
  PointAnnotationManager? annotationManager;


  CameraOptions? _initialCameraOptions;

  @override
  void initState() {
    super.initState();

    // 💡 إذا كانت هناك إحداثيات سابقة، فابدأ بها
    if (widget.initialLat != null && widget.initialLng != null) {
      selectedLat = widget.initialLat!;
      selectedLng = widget.initialLng!;
      selectedAddress = "الموقع المحدد مسبقًا";
    }


    final double lat = selectedLat != 0.0 ? selectedLat : 21.4225;
    final double lng = selectedLng != 0.0 ? selectedLng : 39.8262;

    _initialCameraOptions = CameraOptions(
      center: Point(coordinates: Position(lng, lat)),
      zoom: 14.0,
    );
  }

  void _onMapCreated(MapboxMap controller) async {
    _mapboxMapCompleter.complete(controller);
    mapboxMap = controller;

    mapboxMap!.location.updateSettings(LocationComponentSettings(enabled: true));
    annotationManager = await controller.annotations.createPointAnnotationManager();


    if (selectedLat != 0.0 && selectedLng != 0.0) {
      _addMarker(Point(coordinates: Position(selectedLng, selectedLat)));
    } else {

      // mapboxMap!.location.getLastLocation().then((location) {
      //   if (location != null) {
      //     final currentPosition = Point(
      //       coordinates: Position(location.longitude, location.latitude),
      //     );
      //     mapboxMap!.flyTo(
      //       CameraOptions(center: currentPosition, zoom: 14.0),
      //       MapAnimationOptions.defaultOptions,
      //     );
      //   }
      // });
    }
  }


  void _addMarker(Point myPosition) async {
    if (annotationManager == null) return;

    await annotationManager!.deleteAll();

    final currentMarkerOptions = PointAnnotationOptions(
      textField: '',
      geometry: myPosition,
      iconSize: 0.3,
      iconOffset: [0.0, -17.0],
      symbolSortKey: 0,

      image: InitialService.to.mapMyPointIcon,
    );
    await annotationManager!.create(currentMarkerOptions);
    setState(() {});
  }

  void _onMapTapped(Point point) async {
    if (mapboxMap == null) return;


    selectedLat = (point.coordinates.lat).toDouble();
    selectedLng = (point.coordinates.lng).toDouble();


    final newAddress = "Lat: ${selectedLat.toStringAsFixed(4)}, Lng: ${selectedLng.toStringAsFixed(4)}";

    setState(() {
      selectedAddress = newAddress;
    });


    _addMarker(point);
  }

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      title: Text(widget.isPickup ? "تحديد موقع الاستلام من الخريطة" : "تحديد موقع التسليم من الخريطة"),
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 350,
        child: Column(
          children: [
            Expanded(
              child: SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: MapWidget(
                  styleUri: MapboxStyles.MAPBOX_STREETS,
                  cameraOptions: _initialCameraOptions,

                  onMapCreated: _onMapCreated,

                  onTapListener: (point) {
                    _onMapTapped(point.point);
                  },
                ),
              ),

            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              color: Colors.white,
              child: Text(
                selectedAddress,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text("إلغاء", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {

            if(selectedLng!=0.0&&selectedLat!=0.0){
              Get.back(result: {
                'lat': selectedLat,
                'lon': selectedLng,
                'address': selectedAddress,
              });
            }else{
              Get.snackbar("error".tr, "قم بتحديد الموقع اولا", snackPosition: SnackPosition.BOTTOM);
            }


          },
          style: ElevatedButton.styleFrom(
            backgroundColor: MyColors.primaryColor,
          ),
          child: const Text("تأكيد الموقع", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}