class CategoryModel {
  String? id;
  String? category;

  CategoryModel({
    this.id,
    this.category,
  });

  CategoryModel.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    category = map["category"];
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "category": category,
    };
  }
}
