import 'category_model.dart';

class ProductModel {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final String? imageUrl;
  final CategoryModel? category;

  const ProductModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    this.imageUrl,
    this.category,
  });

  bool get inStock => stock > 0;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final cat = json['category'];
    return ProductModel(
      id: int.parse(json['id'].toString()),
      name: json['name'].toString(),
      description: json['description']?.toString(),
      price: double.parse(json['price'].toString()),
      stock: int.tryParse(json['stock']?.toString() ?? '') ?? 0,
      imageUrl: json['image_url']?.toString(),
      category: cat is Map
          ? CategoryModel.fromJson(Map<String, dynamic>.from(cat))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'stock': stock,
    'image_url': imageUrl,
    'category': category?.toJson(),
  };
}