class StoreEntity {
  final String id;
  final String name;
  final List<String> productIds;
  final DateTime createdAt;

  StoreEntity({
    required this.id,
    required this.name,
    required this.productIds,
    required this.createdAt,
  });
}