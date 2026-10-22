class CategoryModel {
  final int id;
  final String name;

  const CategoryModel({required this.id, required this.name});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: int.parse(json['id'].toString()),
      name: json['name'].toString(),
    );
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}