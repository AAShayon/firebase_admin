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
    required this.isSubAdmin ,
  });
}
extension UserEntityCopyWith on UserEntity {
  UserEntity copyWith({bool? isAdmin , bool? isSubAdmin }) {
    return UserEntity(
      id: id,
      isAdmin: isAdmin ?? this.isAdmin,
      isSubAdmin: isSubAdmin ??   this.isSubAdmin ,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }
}