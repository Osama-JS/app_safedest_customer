import 'package:get/get.dart';
// import 'DriverModel.dart'; // افترض أن اسم الملف هو DriverModel.dart

class OfferModel {
  final RxInt id;
  final Rx<DriverModel> driver;
  final RxInt driverId;
  final RxDouble price;
  final RxBool accepted;
  final RxString description;

  OfferModel({
    int id = 0,
    required DriverModel driver,
    int driverId = 0,
    double price = 0.0,
    bool accepted = false,
    String description = '',
  })  : id = id.obs,
        driver = driver.obs,
        driverId = driverId.obs,
        price = price.obs,
        accepted = accepted.obs,
        description = description.obs;

  factory OfferModel.fromJson(Map<String, dynamic> json) {


    return OfferModel(
      id: json['id'] ?? 0,
      driver: DriverModel.fromJson(json['driver'] ?? {}),
      driverId: json['driver_id'] ?? 0,
      price: double.parse(json['price']??"0.0"),
      accepted: json['accepted'] ?? false,
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id.value,
    'driver': driver.value.toJson(),
    'driver_id': driverId.value,
    'price': price.value,
    'accepted': accepted.value,
    'description': description.value,
  };
}



class DriverModel {
  final RxInt id;
  final RxString name;
  final RxString phone;
  final RxString image;

  DriverModel({
    int id = 0,
    String name = '',
    String phone = '',
    String image = '',
  })  : id = id.obs,
        name = name.obs,
        phone = phone.obs,
        image = image.obs;

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id.value,
    'name': name.value,
    'phone': phone.value,
    'image': image.value,
  };
}


