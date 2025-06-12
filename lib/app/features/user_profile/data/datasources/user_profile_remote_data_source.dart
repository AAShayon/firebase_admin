import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../models/user_profile_model.dart';

abstract class UserProfileRemoteDataSource {
  Stream<UserProfileEntity> watchUserProfile(String userId);
  Future<UserProfileEntity> getUserProfile(String userId);
  Future<void> updateUserProfile(UserProfileEntity user);
  Future<void> addUserAddress(String userId, UserAddress address);
  Future<void> updateUserAddress(String userId, UserAddress address);
  Future<void> removeUserAddress(String userId, String addressId);
  Future<void> setDefaultAddress(String userId, String addressId);
  Future<void> updateContactNo(String userId, String addressId, String contactNo);
}

class UserProfileRemoteDataSourceImpl implements UserProfileRemoteDataSource {
  final FirebaseFirestore _firestore;

  UserProfileRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;
  @override
  Stream<UserProfileEntity> watchUserProfile(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots() // This returns a Stream<DocumentSnapshot>
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        throw Exception('User document does not exist.');
      }
      // For each event in the stream, convert the snapshot to your model
      return UserProfileModel.fromJson(snapshot.data()!);
    });
  }

  @override
  Future<UserProfileEntity> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) {
      throw Exception('User not found');
    }
    return UserProfileModel.fromJson(doc.data()!);

  }

  @override
  Future<void> updateUserProfile(UserProfileEntity user) async {
    await _firestore.collection('users').doc(user.id).update({
      'displayName': user.displayName,
      'photoUrl': user.photoUrl,
    });
  }
  @override
  Future<void> updateContactNo(String userId, String addressId, String contactNo) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      throw Exception('User not found');
    }

    // Retrieve the list of addresses
    final addresses = List<Map<String, dynamic>>.from(userDoc['addresses'] ?? []);

    // Find the address that needs to be updated by its 'id'
    final addressIndex = addresses.indexWhere((a) => a['id'] == addressId);

    if (addressIndex == -1) {
      throw Exception('Address not found');
    }

    // Update the contactNo for the specific address
    addresses[addressIndex]['contactNo'] = contactNo;

    // Save the updated list of addresses back to Firestore
    await _firestore.collection('users').doc(userId).update({
      'addresses': addresses,
    });
  }

  @override
  Future<void> addUserAddress(String userId, UserAddress address) async {
    await _firestore.collection('users').doc(userId).update({
      'addresses': FieldValue.arrayUnion([_addressToMap(address)]),
    });
  }

  @override
  Future<void> updateUserAddress(String userId, UserAddress address) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final addresses = List<Map<String, dynamic>>.from(userDoc['addresses'] ?? []);

    final index = addresses.indexWhere((a) => a['id'] == address.id);
    if (index == -1) throw Exception('Address not found');

    addresses[index] = _addressToMap(address);

    await _firestore.collection('users').doc(userId).update({
      'addresses': addresses,
    });
  }

  @override
  Future<void> removeUserAddress(String userId, String addressId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final addresses = List<Map<String, dynamic>>.from(userDoc['addresses'] ?? []);

    addresses.removeWhere((a) => a['id'] == addressId);

    await _firestore.collection('users').doc(userId).update({
      'addresses': addresses,
    });
  }

  @override
  Future<void> setDefaultAddress(String userId, String addressId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final addresses = List<Map<String, dynamic>>.from(userDoc['addresses'] ?? []);

    // Reset all defaults
    for (var addr in addresses) {
      addr['isDefault'] = false;
    }

    // Set new default
    final index = addresses.indexWhere((a) => a['id'] == addressId);
    if (index == -1) throw Exception('Address not found');

    addresses[index]['isDefault'] = true;

    await _firestore.collection('users').doc(userId).update({
      'addresses': addresses,
    });
  }

  Map<String, dynamic> _addressToMap(UserAddress address) {
    return {
      'id': address.id,
      'type': address.type,
      'addressLine1': address.addressLine1,
      'area': address.area,
      'contactNo': address.contactNo,
      'city': address.city,
      'state': address.state,
      'postalCode': address.postalCode,
      'country': address.country,
      'isDefault': address.isDefault,
    };
  }
}