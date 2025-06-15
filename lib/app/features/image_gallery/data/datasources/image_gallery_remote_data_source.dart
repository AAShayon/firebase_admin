import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ImageGalleryRemoteDataSource {
  Stream<QuerySnapshot> getGalleryImages();
  Future<void> addImageUrl({required String url, String? name});
  Future<void> deleteImageUrl(String imageId);
}

class ImageGalleryRemoteDataSourceImpl implements ImageGalleryRemoteDataSource {
  final FirebaseFirestore _firestore;
  ImageGalleryRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Stream<QuerySnapshot> getGalleryImages() {
    return _firestore
        .collection('image_gallery')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Future<void> addImageUrl({required String url, String? name}) {
    return _firestore.collection('image_gallery').add({
      'url': url,
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteImageUrl(String imageId) {
    return _firestore.collection('image_gallery').doc(imageId).delete();
  }
}