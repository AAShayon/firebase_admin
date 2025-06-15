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
}