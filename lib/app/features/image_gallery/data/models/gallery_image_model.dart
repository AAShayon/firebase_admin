import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/gallery_image_entity.dart';

class GalleryImageModel extends GalleryImageEntity {
  GalleryImageModel({
    required super.id,
    required super.url,
    super.name,
    required super.createdAt,
  });

  factory GalleryImageModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GalleryImageModel(
      id: doc.id,
      url: data['url'] ?? '',
      name: data['name'],
      createdAt: (data['createdAt'] as Timestamp? ?? Timestamp.now()).toDate(),
    );
  }
  factory GalleryImageModel.fromApi(Map<String, dynamic> json) {
    final String id = json['id'] ?? 'unknown';
    return GalleryImageModel(
      id: id,
      // Construct the optimized URL directly
      url: 'https://picsum.photos/id/$id/500/500',
      name: 'By ${json['author'] ?? 'Unknown Artist'}',
      // API data doesn't have a creation date, so we can leave it null
      createdAt: null,
    );
  }
}