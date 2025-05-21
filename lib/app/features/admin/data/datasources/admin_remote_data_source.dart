import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/entities/user_roles.dart';
import '../models/admin_model.dart';

abstract class AdminRemoteDataSource {
  Future<List<UserEntity>> getUsers();

  Future<void> updateUserRole(String userId, UserRole newRole);

  Future<AdminModel> getAdminDetails(String userId);

  Future<List<AdminModel>> getAllAdminDetails();
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  AdminRemoteDataSourceImpl({required this.firestore, required this.auth});

  @override
  Future<List<UserEntity>> getUsers() async {
    try {
      final users = await firestore.collection('users').get();
      final admins = await firestore.collection('admins').get();

      return users.docs.map((doc) {
        final matchingAdmins = admins.docs.where((admin) => admin.id == doc.id);
        final adminDoc =
            matchingAdmins.isNotEmpty ? matchingAdmins.first : null;

        return UserEntity(
          id: doc.id,
          email: doc.data()['email'],
          displayName: doc.data()['displayName'],
          photoUrl: doc.data()['photoUrl'],
          isAdmin: adminDoc != null,
          role:
              adminDoc != null
                  ? (adminDoc.data()['isSuperAdmin'] == true
                      ? UserRole.superAdmin
                      : UserRole.admin)
                  : UserRole.user,
        );
      }).toList();
    } catch (e) {
      throw AdminFailure(message: 'Failed to fetch users: ${e.toString()}');
    }
  }

  @override
  Future<void> updateUserRole(String userId, UserRole newRole) async {
    try {
      if (newRole == UserRole.user) {
        await firestore.collection('admins').doc(userId).delete();
      } else {
        await firestore.collection('admins').doc(userId).set({
          'updatedAt': FieldValue.serverTimestamp(),
          'isSuperAdmin': newRole == UserRole.superAdmin,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      throw AdminFailure(
        message: 'Failed to update user role: ${e.toString()}',
      );
    }
  }

  @override
  Future<AdminModel> getAdminDetails(String userId) async {
    final doc = await firestore.collection('admins').doc(userId).get();
    if (!doc.exists) throw AdminFailure(message: 'Admin not found');
    return AdminModel.fromJson(doc.data()!..['userId'] = doc.id);
  }

  @override
  Future<List<AdminModel>> getAllAdminDetails() async {
    final snapshot = await firestore.collection('admins').get();
    return snapshot.docs
        .map((doc) => AdminModel.fromJson(doc.data()!..['userId'] = doc.id))
        .toList();
  }
}

class AdminFailure implements Exception {
  final String message;

  AdminFailure({required this.message});
}
