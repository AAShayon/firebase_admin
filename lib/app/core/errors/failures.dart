// lib/core/errors/failures.dart
abstract class Failure {
  final String message;

  const Failure({this.message = 'An unexpected error occurred'});
}

// Auth failures
class AuthFailure extends Failure {
  const AuthFailure({super.message});

  factory AuthFailure.fromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return const AuthFailure(message: 'Email is not valid');
      case 'user-disabled':
        return const AuthFailure(message: 'This user has been disabled');
      case 'user-not-found':
        return const AuthFailure(message: 'No user found with this email');
      case 'wrong-password':
        return const AuthFailure(message: 'Incorrect password');
      case 'email-already-in-use':
        return const AuthFailure(message: 'Email already in use');
      case 'operation-not-allowed':
        return const AuthFailure(message: 'Operation not allowed');
      case 'weak-password':
        return const AuthFailure(message: 'Password is too weak');
      default:
        return const AuthFailure();
    }
  }
}

// Product failures
class ProductFailure extends Failure {
  const ProductFailure({super.message});

  factory ProductFailure.fromCode(String code) {
    switch (code) {
      case 'permission-denied':
        return const ProductFailure(message: 'You don\'t have permission');
      case 'not-found':
        return const ProductFailure(message: 'Product not found');
      default:
        return const ProductFailure();
    }
  }
}

// Store failures
class StoreFailure extends Failure {
  const StoreFailure({super.message});

  factory StoreFailure.fromCode(String code) {
    switch (code) {
      case 'permission-denied':
        return const StoreFailure(message: 'You don\'t have permission');
      case 'not-found':
        return const StoreFailure(message: 'Store not found');
      default:
        return const StoreFailure();
    }
  }
}