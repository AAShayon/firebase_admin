import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../auth/domain/entities/user_entity.dart';

import '../../../auth/domain/entities/user_roles.dart';

abstract class AdminRemoteDataSource {
  Future<List<UserEntity>> getUsers();
  Future<void> updateUserRole(String userId, UserRole newRole);
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
        final adminDoc = matchingAdmins.isNotEmpty ? matchingAdmins.first : null;

        return UserEntity(
          id: doc.id,
          email: doc.data()['email'],
          displayName: doc.data()['displayName'],
          photoUrl: doc.data()['photoUrl'],
          isAdmin: adminDoc != null,
          role: adminDoc != null
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
      throw AdminFailure(message: 'Failed to update user role: ${e.toString()}');
    }
  }
}

class AdminFailure implements Exception {
  final String message;
  AdminFailure({required this.message});
}