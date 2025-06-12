// lib/features/user_profile/data/models/user_profile_model.dart
import '../../domain/entities/user_profile_entity.dart';

class UserProfileModel extends UserProfileEntity {
  UserProfileModel({
    required super.id,
    super.email,
    super.displayName,
    super.photoUrl,
    super.addresses = const [],
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
      addresses: (json['addresses'] as List<dynamic>?)
          ?.map((addr) => UserAddress(
        id: addr['id'],
        type: addr['type'],
        addressLine1: addr['addressLine1'],
        area: addr['area'],
        city: addr['city'],
        state: addr['state'],
        postalCode: addr['postalCode'],
        country: addr['country'],
        isDefault: addr['isDefault'] ?? false,
        contactNo: addr['contactNo'],
      ))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'addresses': addresses.map((addr) => {
        'id': addr.id,
        'type': addr.type,
        'addressLine1': addr.addressLine1,
        'area': addr.area,
        'contactNo': addr.contactNo,
        'city': addr.city,
        'state': addr.state,
        'postalCode': addr.postalCode,
        'country': addr.country,
        'isDefault': addr.isDefault,
      }).toList(),
    };
  }
}