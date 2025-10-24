import 'package:get/get.dart';

class TaskAdModel {
  final RxInt id;
  final RxInt taskId;
  final RxDouble lowPrice;
  final RxDouble highPrice;
  final RxString note;
  final RxString status;
  final RxInt user;
  final Rx<CustomerModel> customer;
  final RxString fromAddress;
  final RxString toAddress;
  final RxList<double> fromLocation; // [Longitude, Latitude]
  final RxList<double> toLocation;   // [Longitude, Latitude]

  TaskAdModel({
    required int id,
    required int taskId,
    required double lowPrice,
    required double highPrice,
    required String note,
    required String status,
    required int user,
    required CustomerModel customer,
    required String fromAddress,
    required String toAddress,
    required List<double> fromLocation,
    required List<double> toLocation,
  })  : id = id.obs,
        taskId = taskId.obs,
        lowPrice = lowPrice.obs,
        highPrice = highPrice.obs,
        note = note.obs,
        status = status.obs,
        user = user.obs,
        customer = customer.obs,
        fromAddress = fromAddress.obs,
        toAddress = toAddress.obs,
        fromLocation = fromLocation.obs,
        toLocation = toLocation.obs;

  factory TaskAdModel.fromJson(Map<String, dynamic> json) {
    // معالجة أسعار Null
    double parsePrice(dynamic value) {
      if (value is int) return value.toDouble();
      if (value is double) return value;
      return 0.0;
    }

    // معالجة مواقع Null
    List<double> parseLocation(List<dynamic>? list) {
      if (list == null || list.isEmpty) return [0.0, 0.0];
      return list.map((e) => parsePrice(e)).toList();
    }

    return TaskAdModel(
      id: json['id'] ?? 0,
      taskId: json['task_id'] ?? 0,
      lowPrice: parsePrice(json['low_price']),
      highPrice: parsePrice(json['high_price']),
      note: json['note'] ?? '',
      status: json['status'] ?? '',
      user: json['user'] ?? 0,
      // إنشاء موديل العميل من الخريطة
      customer: CustomerModel.fromJson(json['customer'] ?? {}),
      fromAddress: json['from_address'] ?? '',
      toAddress: json['to_address'] ?? '',
      fromLocation: parseLocation(json['from_location']),
      toLocation: parseLocation(json['to_location']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id.value,
    'task_id': taskId.value,
    'low_price': lowPrice.value,
    'high_price': highPrice.value,
    'note': note.value,
    'status': status.value,
    'user': user.value,
    'customer': customer.value.toJson(), // تحويل موديل العميل إلى JSON
    'from_address': fromAddress.value,
    'to_address': toAddress.value,
    'from_location': fromLocation.toList(),
    'to_location': toLocation.toList(),
  };
}




class CustomerModel {
  final RxString owner;
  final RxInt id;
  final RxString name;
  final RxString phone;
  final RxString email;
  final RxString image;

  CustomerModel({
    required String owner,
    required int id,
    required String name,
    required String phone,
    required String email,
    required String image,
  })  : owner = owner.obs,
        id = id.obs,
        name = name.obs,
        phone = phone.obs,
        email = email.obs,
        image = image.obs;

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      owner: json['owner'] ?? '',
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'owner': owner.value,
    'id': id.value,
    'name': name.value,
    'phone': phone.value,
    'email': email.value,
    'image': image.value,
  };
}