class CategoryEntity {
  final String id;
  final String name;
  final String image;
  final String? parentId;
  final bool? isFeatured;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.image,
    this.parentId,
    this.isFeatured,
  });

  bool get isRoot => parentId == null || parentId!.isEmpty;

  CategoryEntity copyWith({
    String? id,
    String? name,
    String? image,
    String? parentId,
    bool? isFeatured,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      parentId: parentId ?? this.parentId,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
}