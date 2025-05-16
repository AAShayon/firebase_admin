import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/firebase_provider.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<void> signInWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Future<UserModel> signInWithGoogle();
  Future<bool> isAdmin(String userId);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await FirebaseProvider.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
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
      await FirebaseProvider.auth.signOut();
    } catch (_) {
      throw const AuthFailure(message: 'Unable to sign out');
    }
  }
  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) throw const AuthFailure(message: 'Cancelled');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseProvider.auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) throw const AuthFailure(message: 'User not found');

      final isAdmin = await this.isAdmin(user.uid);
      return UserModel(id: user.uid, isAdmin: isAdmin);
    } catch (e) {
      throw const AuthFailure(message: 'Google Sign-In Failed');
    }
  }

  @override
  Future<bool> isAdmin(String userId) async {
    final doc = await FirebaseProvider.firestore.collection('admins').doc(userId).get();
    return doc.exists;
  }
}