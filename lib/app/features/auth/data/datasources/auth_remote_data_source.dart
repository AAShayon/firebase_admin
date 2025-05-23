import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/failures.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailAndPassword(String email, String password);

  Future<void> signOut();

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
  })
      : _auth = auth,
        _googleSignIn = googleSignIn,
        _firestore = firestore;

  @override
  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw const AuthFailure(message: 'User not found');

      final adminStatus = await isAdmin(user.uid);
      final subAdminStatus = await isSubAdmin(user.uid);

      return UserModel(
        id: user.uid,
        isAdmin: adminStatus,
        isSubAdmin: subAdminStatus,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoURL,
      );
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
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) throw const AuthFailure(message: 'User not found');

      final adminStatus = await isAdmin(user.uid); // Renamed variable
      final subAdminStatus = await isSubAdmin(user.uid); // Renamed variable
      return UserModel(
        id: user.uid,
        isAdmin: adminStatus,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoURL,
        isSubAdmin: subAdminStatus,);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromCode(e.code);
    } catch (e) {
      throw AuthFailure(message: 'Google Sign-In Failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthFailure(message: 'No authenticated user');

    final adminStatus = await isAdmin(user.uid);
    final subAdminStatus = await isSubAdmin(user.uid);
    return UserModel(
      id: user.uid,
      isAdmin: adminStatus,
      displayName: user.displayName,
      email: user.email,
      photoUrl: user.photoURL,
      isSubAdmin: subAdminStatus,
    );
  }

  @override
  Future<bool> isAdmin(String userId) async {
    try {
      final doc = await _firestore.collection('admins').doc(userId).get();
      return doc.exists;
    } catch (e) {
      throw AuthFailure(
          message: 'Failed to check admin status: ${e.toString()}');
    }
  }

  @override
  Future<bool> isSubAdmin(String userId) async {
    try {
      final doc = await _firestore.collection('subAdmins').doc(userId).get();
      return doc.exists;
    } catch (e) {
      throw AuthFailure(
          message: 'Failed to check sub-admin status: ${e.toString()}');
    }
  }


  @override
  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromCode(e.code);
    } catch (e) {
      throw AuthFailure(message: 'Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> updatePassword(String newPassword,
      [String? currentPassword]) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthFailure(
          message: 'No authenticated user');
      }

      // Enhanced password update logic
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
          throw const AuthFailure(
            message: 'User email not available');
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

  @override
  Future<void> assignAdminRole(String userId, {bool isAdmin = true}) async {
    try {
      if (isAdmin) {
        await _firestore.collection('admins').doc(userId).set(
            {'assignedAt': DateTime.now()});
      } else {
        await _firestore.collection('admins').doc(userId).delete();
      }
    } catch (e) {
      throw AuthFailure(
          message: 'Failed to update admin role: ${e.toString()}');
    }
  }

  @override
  Future<void> assignSubAdminRole(String userId,
      {bool isSubAdmin = true}) async {
    try {
      if (isSubAdmin) {
        await _firestore.collection('subAdmins').doc(userId).set(
            {'assignedAt': DateTime.now()});
      } else {
        await _firestore.collection('subAdmins').doc(userId).delete();
      }
    } catch (e) {
      throw AuthFailure(
          message: 'Failed to update sub-admin role: ${e.toString()}');
    }
  }
}