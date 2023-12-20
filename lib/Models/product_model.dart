class ProductModel {
  String? id;
  String? productName;
  String? productPrice;
  String? stock;
  String? image;
  String? category;

  ProductModel({
    this.id,
    this.productName,
    this.productPrice,
    this.stock,
    this.image,
    this.category,
  });

  ProductModel.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    productName = map["product_name"];
    productPrice = map["product_price"];
    stock = map["stock"];
    image = map["image"];
    category = map["category"];
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "product_name": productName,
      "product_price": productPrice,
      "stock": stock,
      "image": image,
      "category": category,
    };
  }
}
