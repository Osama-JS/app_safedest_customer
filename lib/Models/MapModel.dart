import 'package:get/get.dart';

class MapModel {
  final RxInt id;
  final RxString status;
  final RxString lat;
  final RxString lng;
  final RxString pickupAddress;
  final RxString deliveryAddress;
  final RxString? driverName;
  final RxString? driverPhone;
  final RxString? driverImage;
  final RxDouble price;
  final RxString currency;
  final RxString? vehicle;
  final RxString createdAt;

  MapModel({
    int id = 0,
    String status = '',
    String lat = '',
    String lng = '',
    String pickupAddress = '',
    String deliveryAddress = '',
    String? driverName,
    String? driverPhone,
    String? driverImage,
    double price = 0.0,
    String currency = '',
    String? vehicle,
    String createdAt = '',
  })  : id = id.obs,
        status = status.obs,
        lat = lat.obs,
        lng = lng.obs,
        pickupAddress = pickupAddress.obs,
        deliveryAddress = deliveryAddress.obs,
        driverName = driverName?.obs,
        driverPhone = driverPhone?.obs,
        driverImage = driverImage?.obs,
        price = price.obs,
        currency = currency.obs,
        vehicle = vehicle?.obs,
        createdAt = createdAt.obs;

  factory MapModel.fromJson(Map<String, dynamic> json) {
    return MapModel(
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
      lat: ((json['lat'] is num) ? (json['lat'] as num).toDouble() : 0.0).toString(),
      lng: ((json['lng'] is num) ? (json['lng'] as num).toDouble() : 0.0).toString(),
      pickupAddress: json['pickup_address'] ?? '',
      deliveryAddress: json['delivery_address'] ?? '',
      driverName: json['driver_name'],
      driverPhone: json['driver_phone'],
      driverImage: json['driver_image'],
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      currency: json['currency'] ?? '',
      vehicle: json['vehicle'],
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.value,
      'status': status.value,
      'lat': lat.value,
      'lng': lng.value,
      'pickup_address': pickupAddress.value,
      'delivery_address': deliveryAddress.value,
      'driver_name': driverName?.value,
      'driver_phone': driverPhone?.value,
      'driver_image': driverImage?.value,
      'price': price.value,
      'currency': currency.value,
      'vehicle': vehicle?.value,
      'created_at': createdAt.value,
    };
  }
}