class UserEntity {
  final String id;
  final bool isAdmin;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isSubAdmin;

  UserEntity({
    required this.id,
    required this.isAdmin,
    this.email,
    this.displayName,
    this.photoUrl,
    this.isSubAdmin = false,
  });
}
extension UserEntityCopyWith on UserEntity {
  UserEntity copyWith({bool? isAdmin}) {
    return UserEntity(
      id: id,
      isAdmin: isAdmin ?? this.isAdmin,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }
}