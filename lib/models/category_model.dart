class CategoryModel {
  final int? id;
  final String name;
  final String type; // 'income' o 'expense'

  CategoryModel({this.id, required this.name, required this.type});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'type': type};
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(id: map['id'], name: map['name'], type: map['type']);
  }
}
