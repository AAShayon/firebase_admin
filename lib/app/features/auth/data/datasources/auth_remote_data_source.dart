import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/firebase_provider.dart';

abstract class AuthRemoteDataSource {
  Future<void> signInWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Future<bool> isAdmin();
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
  Future<bool> isAdmin() async {
    final user = FirebaseProvider.auth.currentUser;
    if (user == null) return false;

    final doc = await FirebaseProvider.firestore
        .collection('admins')
        .doc(user.uid)
        .get();

    return doc.exists;
  }
}