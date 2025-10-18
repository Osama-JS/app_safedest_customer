import 'package:get/get.dart';

class TaskModel {
  final RxInt id;
  final RxString status;
  final RxBool closed;
  final RxString paymentStatus;
  final RxString paymentMethod;
  final LocationModel pickup;
  final LocationModel delivery;
  final RxDouble price;
  final RxString currency;
  final DriverModel driver;
  final RxString vehicle;
  final RxList<AdditionalDataModel> additionalData;
  final RxString createdAt;

  TaskModel({
    int id = 0,
    String status = '',
    bool closed = false,
    String paymentStatus = '',
    String paymentMethod = '',
    LocationModel? pickup,
    LocationModel? delivery,
    double price = 0.0,
    String currency = '',
    DriverModel? driver,
    String vehicle = '',
    List<AdditionalDataModel> additionalData = const [],
    String createdAt = '',
  })  : id = id.obs,
        status = status.obs,
        closed = closed.obs,
        paymentStatus = paymentStatus.obs,
        paymentMethod = paymentMethod.obs,
        pickup = pickup ?? LocationModel(),
        delivery = delivery ?? LocationModel(),
        price = price.obs,
        currency = currency.obs,
        driver = driver ?? DriverModel(),
        vehicle = vehicle.obs,
        additionalData = additionalData.obs,
        createdAt = createdAt.obs;

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    var additionalDataList = <AdditionalDataModel>[];
    if (json['additional_data'] != null) {
      additionalDataList = (json['additional_data'] as List)
          .map((item) => AdditionalDataModel.fromJson(item))
          .toList();
    }

    return TaskModel(
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
      closed: json['closed'] ?? false,
      paymentStatus: json['payment_status'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      pickup: LocationModel.fromJson(json['pickup'] ?? {}),
      delivery: LocationModel.fromJson(json['delivery'] ?? {}),
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      currency: json['currency'] ?? '',
      driver: DriverModel.fromJson(json['driver'] ?? {}),
      vehicle: json['vehicle'] ?? '',
      additionalData: additionalDataList,
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.value,
      'status': status.value,
      'closed': closed.value,
      'payment_status': paymentStatus.value,
      'payment_method': paymentMethod.value,
      'pickup': pickup.toJson(),
      'delivery': delivery.toJson(),
      'price': price.value,
      'currency': currency.value,
      'driver': driver.toJson(),
      'vehicle': vehicle.value,
      'additional_data': additionalData.map((e) => e.toJson()).toList(),
      'created_at': createdAt.value,
    };
  }
}




class LocationModel {
  final RxDouble lat;
  final RxDouble lng;
  final RxString address;
  final RxString contactName;
  final RxString contactPhone;
  final RxString note;
  final RxString scheduledTime;
  final RxString image;

  LocationModel({
    double lat = 0.0,
    double lng = 0.0,
    String address = '',
    String contactName = '',
    String contactPhone = '',
    String note = '',
    String scheduledTime = '',
    String image = '',
  })  : lat = lat.obs,
        lng = lng.obs,
        address = address.obs,
        contactName = contactName.obs,
        contactPhone = contactPhone.obs,
        note = note.obs,
        scheduledTime = scheduledTime.obs,
        image = image.obs;

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      lat: (json['lat'] is num) ? (json['lat'] as num).toDouble() : 0.0,
      lng: (json['lng'] is num) ? (json['lng'] as num).toDouble() : 0.0,
      address: json['address'] ?? '',
      contactName: json['contact_name'] ?? '',
      contactPhone: json['contact_phone'] ?? '',
      note: json['note'] ?? '',
      scheduledTime: json['scheduled_time'] ?? '',
      image: (json['image'] as String?)?.trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat.value,
      'lng': lng.value,
      'address': address.value,
      'contact_name': contactName.value,
      'contact_phone': contactPhone.value,
      'note': note.value,
      'scheduled_time': scheduledTime.value,
      'image': image.value,
    };
  }
}



class DriverModel {
  final RxString name;
  final RxString phone;
  final RxString image;

  DriverModel({
    String name = '',
    String phone = '',
    String image = '',
  })  : name = name.obs,
        phone = phone.obs,
        image = image.obs;

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      image: (json['image'] as String?)?.trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name.value,
      'phone': phone.value,
      'image': image.value,
    };
  }
}



class AdditionalDataModel {
  final RxString label;
  final RxString value;

  AdditionalDataModel({
    String label = '',
    String value = '',
  })  : label = label.obs,
        value = value.obs;

  factory AdditionalDataModel.fromJson(Map<String, dynamic> json) {
    return AdditionalDataModel(
      label: json['label'] ?? '',
      value: json['value'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label.value,
      'value': value.value,
    };
  }
}



