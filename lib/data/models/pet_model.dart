import 'user_model.dart';
import 'category_model.dart';

class PetModel {
  final int id;
  final String name;
  final String breed;
  final int age; // in months
  final String gender;
  final String size;
  final String? description;
  final String? imageUrl;
  final String location;
  final bool isAdopted;
  final int categoryId;
  final int ownerId;
  final UserModel? owner;
  final CategoryModel? category;

  PetModel({
    required this.id,
    required this.name,
    required this.breed,
    required this.age,
    required this.gender,
    required this.size,
    this.description,
    this.imageUrl,
    required this.location,
    required this.isAdopted,
    required this.categoryId,
    required this.ownerId,
    this.owner,
    this.category,
  });

  String get ageText {
    if (age < 1) {
      return 'Newborn';
    } else if (age < 12) {
      return '$age months';
    } else {
      final years = age ~/ 12;
      final remainingMonths = age % 12;
      if (remainingMonths == 0) {
        return '$years ${years == 1 ? "year" : "years"}';
      } else {
        return '$years.${(remainingMonths / 1.2).round()} ${years == 1 ? "year" : "years"}';
      }
    }
  }

  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      id: json['id'] as int,
      name: json['name'] as String,
      breed: json['breed'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String,
      size: json['size'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      location: json['location'] as String,
      isAdopted: json['is_adopted'] as bool,
      categoryId: json['category_id'] as int,
      ownerId: json['owner_id'] as int,
      owner: json['owner'] != null ? UserModel.fromJson(json['owner'] as Map<String, dynamic>) : null,
      category: json['category'] != null ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'breed': breed,
      'age': age,
      'gender': gender,
      'size': size,
      'description': description,
      'image_url': imageUrl,
      'location': location,
      'is_adopted': isAdopted,
      'category_id': categoryId,
      'owner_id': ownerId,
      'owner': owner?.toJson(),
      'category': category?.toJson(),
    };
  }
}
