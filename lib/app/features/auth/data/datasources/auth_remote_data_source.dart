// lib/app/features/auth/data/datasources/auth_remote_data_source.dart
import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/failures.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Future<void> saveAdminDeviceToken(String adminId);
  Future<UserModel> signInWithGoogle();
  Future<void> signUpWithEmailAndPassword(String email, String password);
  Future<void> updatePassword(String newPassword, [String? currentPassword]);
  Future<bool> isAdmin(String userId);
  Future<bool> isSubAdmin(String userId);
  Future<UserModel> getCurrentUser();
  Future<void> assignAdminRole(String userId, {bool isAdmin});
  Future<void> assignSubAdminRole(String userId, {bool isSubAdmin});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl({
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _googleSignIn = googleSignIn,
        _firestore = firestore;

  @override
  Future<void> saveAdminDeviceToken(String adminId) async {
    try {
      await FirebaseMessaging.instance.requestPermission();
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) {
        print('FCM token is null, cannot save.');
        return;
      }
      final tokenRef = _firestore
          .collection('admins')
          .doc(adminId)
          .collection('tokens')
          .doc(fcmToken);

      await tokenRef.set({
        'createdAt': FieldValue.serverTimestamp(),
        'platform': Platform.operatingSystem,
      });
      log('Admin FCM token saved successfully: $fcmToken');
    } catch (e) {
      log('Error saving admin FCM token: $e');
    }
  }
  Future<void> _saveUserToFirestore(User user) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final userSnapshot = await userRef.get();

    if (!userSnapshot.exists) {
      // User is new. Create their document.
      await userRef.set({
        'id': user.uid,
        'email': user.email,
        'displayName': user.displayName, // This is null for email/pass, which is OK for a new user.
        'photoUrl': user.photoURL,
        'addresses': [], // IMPORTANT: Initialize the addresses array.
        'createdAt': FieldValue.serverTimestamp(),
        'isAdmin': false, // Always default to false.
        'isSubAdmin': false, // Always default to false.
      });
    }
    // The 'else' block is gone. We do nothing if the user already exists.
  }

  @override
  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user;
      if (user == null) throw const AuthFailure(message: 'User not found');

      await _saveUserToFirestore(user); // Ensures user doc exists.

      // THE EFFICIENT WAY: Fetch the full document from Firestore.
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) throw const AuthFailure(message: 'User database entry not found.');

      // Let the factory constructor parse everything, including admin roles.
      return UserModel.fromJson(userDoc.data()!);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromCode(e.code);
    } catch (_) {
      throw const AuthFailure();
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (_) {
      throw const AuthFailure(message: 'Unable to sign out');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw const AuthFailure(message: 'Cancelled');
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) throw const AuthFailure(message: 'User not found');

      await _saveUserToFirestore(user); // Ensures user doc exists.

      // THE EFFICIENT WAY: Fetch the full document from Firestore.
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) throw const AuthFailure(message: 'User database entry not found.');

      // Let the factory constructor parse everything.
      return UserModel.fromJson(userDoc.data()!);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromCode(e.code);
    } catch (e) {
      throw AuthFailure(message: 'Google Sign-In Failed: ${e.toString()}');
    }
  }

  /// --- 4. THIS METHOD IS FIXED AND EFFICIENT ---
  @override
  Future<UserModel> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthFailure(message: 'No authenticated user');

    // THE EFFICIENT WAY: Fetch the full document from Firestore.
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (!userDoc.exists) {
      await signOut(); // Clean up inconsistent state.
      throw const AuthFailure(message: 'User data not found. Please sign in again.');
    }

    return UserModel.fromJson(userDoc.data()!);
  }

  // --- These methods are kept for potential other uses, but are no longer used in the main login flow ---
  @override
  Future<bool> isAdmin(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      return userDoc.exists && (userDoc.data()?['isAdmin'] ?? false);
    } catch (e) {
      throw AuthFailure(message: 'Failed to check admin status: ${e.toString()}');
    }
  }

  @override
  Future<bool> isSubAdmin(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      return userDoc.exists && (userDoc.data()?['isSubAdmin'] ?? false);
    } catch (e) {
      throw AuthFailure(message: 'Failed to check sub-admin status: ${e.toString()}');
    }
  }

  @override
  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _saveUserToFirestore(userCredential.user!);
      }
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromCode(e.code);
    } catch (e) {
      throw AuthFailure(message: 'Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> updatePassword(String newPassword, [String? currentPassword]) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthFailure(message: 'No authenticated user');
      }

      if (currentPassword != null &&
          user.providerData.any((info) => info.providerId == 'password')) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
      } else if (user.providerData.isEmpty ||
          user.providerData.any((info) => info.providerId == 'google.com')) {
        if (user.email == null) {
          throw const AuthFailure(message: 'User email not available');
        }
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: newPassword,
        );
        await user.linkWithCredential(credential);
        return;
      }

      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromCode(e.code);
    } catch (e) {
      throw AuthFailure(message: 'Password update failed: ${e.toString()}');
    }
  }

// This function in your code is now correctly secured by the new rules.
// Only a user who is ALREADY an admin can successfully call this.
  @override
  Future<void> assignAdminRole(String userId, {bool isAdmin = true}) async {
    try {
      // THIS LINE WILL FAIL if the currently logged-in user is not an admin,
      // because our security rule `allow update: if (isAdmin())` will catch it.
      await _firestore.collection('users').doc(userId).update({
        'isAdmin': isAdmin,
        if (isAdmin) 'isSubAdmin': false,
      });

      // To make this fully work, you MUST also add/remove the user from the `admins` collection.
      if (isAdmin) {
        await _firestore.collection('admins').doc(userId).set({
          'assignedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await _firestore.collection('admins').doc(userId).delete();
      }
    } catch (e) {
      throw AuthFailure(message: 'Failed to update admin role: ${e.toString()}');
    }
  }

  @override
  Future<void> assignSubAdminRole(String userId, {bool isSubAdmin = true}) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isSubAdmin': isSubAdmin,
      });
    } catch (e) {
      throw AuthFailure(message: 'Failed to update sub-admin role: ${e.toString()}');
    }
  }
}