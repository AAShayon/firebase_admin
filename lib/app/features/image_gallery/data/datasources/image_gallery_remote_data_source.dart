import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

abstract class ImageGalleryRemoteDataSource {
  Stream<QuerySnapshot> getGalleryImages();
  Future<void> addImageUrl({required String url, String? name});
  Future<void> deleteImageUrl(String imageId);
  Future<Response> fetchApiImages({int page, int limit});
}

class ImageGalleryRemoteDataSourceImpl implements ImageGalleryRemoteDataSource {
  final FirebaseFirestore _firestore;
  final Dio _dio;
  ImageGalleryRemoteDataSourceImpl({required FirebaseFirestore firestore,required Dio dio})
      : _firestore = firestore,_dio = dio;

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
  @override
  Future<Response> fetchApiImages({int page = 1, int limit = 30}) {
    return _dio.get('/v2/list', queryParameters: {'page': page, 'limit': limit});
  }
}