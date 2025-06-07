class UserProfileEntity {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final List<UserAddress> addresses;

  UserProfileEntity({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.addresses = const [],
  });

  UserProfileEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    List<UserAddress>? addresses,
    bool? isAdmin,
    bool? isSubAdmin,
  }) {
    return UserProfileEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      addresses: addresses ?? this.addresses,
    );
  }
}

class UserAddress {
  final String id;
  final String type;
  final String addressLine1;
  final String? contactNo;
  final String? addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final bool isDefault;

  UserAddress({
    required this.id,
    required this.type,
    required this.addressLine1,
    required this.contactNo,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.isDefault = false,
  });

  UserAddress copyWith({
    String? id,
    String? type,
    String? addressLine1,
    String? contactNo,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    bool? isDefault,
  }) {
    return UserAddress(
      id: id ?? this.id,
      type: type ?? this.type,
      addressLine1: addressLine1 ?? this.addressLine1,
      contactNo: contactNo ?? this.contactNo,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}