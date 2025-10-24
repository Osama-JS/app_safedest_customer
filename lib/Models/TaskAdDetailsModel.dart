import 'package:get/get.dart';


class TaskAdDetailsModel {
  final RxInt id;
  final RxInt taskId;
  final RxDouble lowPrice;
  final RxDouble highPrice;
  final RxString note;
  final RxString status;
  final RxBool included;
  final RxBool serviceCommissionType;
  final RxDouble serviceCommission;
  final RxDouble vatCommission;
  final Rx<TaskModel> task;
  final Rx<CustomerModel> customer;

  TaskAdDetailsModel({
    int id = 0,
    int taskId = 0,
    double lowPrice = 0.0,
    double highPrice = 0.0,
    String note = '',
    String status = '',
    bool included = false,
    bool serviceCommissionType = false,
    double serviceCommission = 0.0,
    double vatCommission = 0.0,
     TaskModel? task,
     CustomerModel? customer,
  })  : id = id.obs,
        taskId = taskId.obs,
        lowPrice = lowPrice.obs,
        highPrice = highPrice.obs,
        note = note.obs,
        status = status.obs,
        included = included.obs,
        serviceCommissionType = serviceCommissionType.obs,
        serviceCommission = serviceCommission.obs,
        vatCommission = vatCommission.obs,
        task = (task ?? TaskModel(  // قيمة افتراضية
          pickup: ContactLocationModel(),
          delivery: ContactLocationModel(),
          additionalData: TaskAdditionalDataModel(),
        )).obs,
        customer = (customer ?? CustomerModel()).obs;

  factory TaskAdDetailsModel.fromJson(Map<String, dynamic> json) {


    return TaskAdDetailsModel(
      id: json['id'] ?? 0,
      taskId: json['task_id'] ?? 0,
      lowPrice: double.parse(json['low_price']??"0.0"),
      highPrice: double.parse(json['high_price']??"0.0"),
      note: json['note'] ?? '',
      status: json['status'] ?? '',
      included: json['included'] ?? false,
      serviceCommissionType: json['service_commission_type'] ?? false,
      serviceCommission: double.parse(json['service_commission']??"0.0"),
      vatCommission: double.parse(json['vat_commission']??"0.0"),
      task: TaskModel.fromJson(json['task'] ?? {}),
      customer: CustomerModel.fromJson(json['customer'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id.value,
    'task_id': taskId.value,
    'low_price': lowPrice.value,
    'high_price': highPrice.value,
    'note': note.value,
    'status': status.value,
    'included': included.value,
    'service_commission_type': serviceCommissionType.value,
    'service_commission': serviceCommission.value,
    'vat_commission': vatCommission.value,
    'task': task.value.toJson(),
    'customer': customer.value.toJson(),
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
    String owner = '',
    int id = 0,
    String name = '',
    String phone = '',
    String email = '',
    String image = '',
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



class TaskModel {
  final RxInt id;
  final RxString status;
  final RxDouble totalPrice;
  final RxString conditions;
  final Rx<ContactLocationModel> pickup;
  final Rx<ContactLocationModel> delivery;
  final Rx<TaskAdditionalDataModel> additionalData;

  TaskModel({
    int id = 0,
    String status = '',
    double totalPrice = 0.0,
    String conditions = '',
    required ContactLocationModel pickup,
    required ContactLocationModel delivery,
    required TaskAdditionalDataModel additionalData,
  })  : id = id.obs,
        status = status.obs,
        totalPrice = totalPrice.obs,
        conditions = conditions.obs,
        pickup = pickup.obs,
        delivery = delivery.obs,
        additionalData = additionalData.obs;

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
      totalPrice: double.parse (json['total_price']  ?? '0.0'),
      conditions: json['conditions'] ?? '',
      pickup: ContactLocationModel.fromJson(json['pickup'] ?? {}),
      delivery: ContactLocationModel.fromJson(json['delivery'] ?? {}),
      additionalData: TaskAdditionalDataModel.fromJson(json['additional_data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id.value,
    'status': status.value,
    'total_price': totalPrice.value,
    'conditions': conditions.value,
    'pickup': pickup.value.toJson(),
    'delivery': delivery.value.toJson(),
    'additional_data': additionalData.value.toJson(),
  };
}




// هيكل الحقل الفردي ضمن additional_data
class AdditionalFieldModel {
  final RxString label;
  final RxString value;
  final RxString type;

  AdditionalFieldModel({String label = '', String value = '', String type = ''})
      : label = label.obs,
        value = value.obs,
        type = type.obs;

  factory AdditionalFieldModel.fromJson(Map<String, dynamic> json) {
    return AdditionalFieldModel(
      label: json['label'] ?? '',
      value: json['value'] ?? '',
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label.value,
    'value': value.value,
    'type': type.value,
  };
}

// الموديل الذي يجمع كل البيانات الإضافية في خريطة مفتاحها هو اسم الحقل (field_name)
class TaskAdditionalDataModel {
  final RxMap<String, AdditionalFieldModel> fields;

  TaskAdditionalDataModel({Map<String, AdditionalFieldModel>? fields})
      : fields = (fields ?? {}).obs;

  factory TaskAdditionalDataModel.fromJson(Map<String, dynamic> json) {
    final Map<String, AdditionalFieldModel> parsedFields = {};
    json.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        parsedFields[key] = AdditionalFieldModel.fromJson(value);
      }
    });
    return TaskAdditionalDataModel(fields: parsedFields);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonMap = {};
    fields.forEach((key, value) {
      jsonMap[key] = value.toJson();
    });
    return jsonMap;
  }
}




class ContactLocationModel {
  final RxString contactName;
  final RxString address;
  final RxDouble latitude;
  final RxDouble longitude;

  ContactLocationModel({
    String contactName = '',
    String address = '',
    double latitude = 0.0,
    double longitude = 0.0,
  })  : contactName = contactName.obs,
        address = address.obs,
        latitude = latitude.obs,
        longitude = longitude.obs;

  factory ContactLocationModel.fromJson(Map<String, dynamic> json) {
    return ContactLocationModel(
      contactName: json['contact_name'] ?? '',
      address: json['address'] ?? '',
      latitude:double.parse (json['latitude'] ?? "0.0"),
      longitude: double.parse (json['longitude'] ?? "0.0") ,
    );
  }

  Map<String, dynamic> toJson() => {
    'contact_name': contactName.value,
    'address': address.value,
    'latitude': latitude.value,
    'longitude': longitude.value,
  };
}