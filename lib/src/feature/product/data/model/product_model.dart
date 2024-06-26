class ProductModel {
  final int id;
  final String name;
  final String? description;
  final String imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double price;
  final int categoryId;

  ProductModel({
    required this.id,
    required this.name,
    this.description,
    required this.imageUrl,
    this.createdAt,
    this.updatedAt,
    required this.price,
    required this.categoryId,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json, {bool isFromTable = true}) {
    if (isFromTable) {
      return ProductModel(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        imageUrl: json['photo_url'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
        price: double.parse(json['price'].toString()),
        categoryId: json['category_id'],
      );
    } else {
      return ProductModel(
        id: json['product_id'],
        name: json['product_name'],
        description: json['product_description'],
        imageUrl: json['product_photo_url'],
        price: json['product_price'],
        categoryId: json['category_info']['category_id'],
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'photo_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'price': price,
      'category_id': categoryId,
    };
  }

  ProductModel copyWith({
    int? id,
    String? name,
    String? description,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVisible,
    double? price,
    int? categoryId,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}
