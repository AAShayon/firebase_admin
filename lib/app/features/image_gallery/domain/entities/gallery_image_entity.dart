// This entity represents a single image URL entry in our gallery.
class GalleryImageEntity {
  final String id; // The Firestore document ID
  final String url;
  final String? name; // An optional name for the image
  final DateTime? createdAt;

  GalleryImageEntity({
    required this.id,
    required this.url,
    this.name,
    required this.createdAt,
  });
}