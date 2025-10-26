// models/transaction_model.dart
import 'package:get/get.dart';

class TransactionModel {
  final RxInt id;
  final RxDouble amount;
  final RxString transactionType; // debit / credit
  final RxString description;
  final RxInt sequence;
  final RxString? maturityTime; // null مسموح
  final RxString image;
  final RxString createdAt;
  final RxString updatedAt;

  TransactionModel({
    int id = 0,
    double amount = 0.0,
    String transactionType = '',
    String description = '',
    int sequence = 0,
    String? maturityTime,
    String image = '',
    String createdAt = '',
    String updatedAt = '',
  })  : id = id.obs,
        amount = amount.obs,
        transactionType = transactionType.obs,
        description = description.obs,
        sequence = sequence.obs,
        maturityTime = maturityTime != null ? maturityTime.obs : null,
        image = image.obs,
        createdAt = createdAt.obs,
        updatedAt = updatedAt.obs;

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? 0,
      amount: double.parse (json['amount'] ?? "0.0"),
      transactionType: json['transaction_type'] ?? '',
      description: json['description'] ?? '',
      sequence: json['sequence'] ?? 0,
      maturityTime: json['maturity_time'] ?? null,
      image: (json['image'] as String?)?.trim() ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.value,
      'amount': amount.value,
      'transaction_type': transactionType.value,
      'description': description.value,
      'sequence': sequence.value,
      'maturity_time': maturityTime?.value,
      'image': image.value.trim(),
      'created_at': createdAt.value,
      'updated_at': updatedAt.value,
    };
  }
}