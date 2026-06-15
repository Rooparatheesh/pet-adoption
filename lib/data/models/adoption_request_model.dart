import 'pet_model.dart';
import 'user_model.dart';

class AdoptionRequestModel {
  final int id;
  final int userId;
  final int petId;
  final String status; // 'pending', 'approved', 'completed', 'rejected'
  final String? message;
  final PetModel? pet;
  final UserModel? requester;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AdoptionRequestModel({
    required this.id,
    required this.userId,
    required this.petId,
    required this.status,
    this.message,
    this.pet,
    this.requester,
    this.createdAt,
    this.updatedAt,
  });

  factory AdoptionRequestModel.fromJson(Map<String, dynamic> json) {
    return AdoptionRequestModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      petId: json['pet_id'] as int,
      status: json['status'] as String,
      message: json['message'] as String?,
      pet: json['pet'] != null ? PetModel.fromJson(json['pet'] as Map<String, dynamic>) : null,
      requester: json['requester'] != null ? UserModel.fromJson(json['requester'] as Map<String, dynamic>) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'pet_id': petId,
      'status': status,
      'message': message,
      'pet': pet?.toJson(),
      'requester': requester?.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
