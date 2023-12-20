import 'package:bill_desk/Models/product_model.dart';
import 'package:flutter/material.dart';

class NewOrdersModel {
  String? orderId;
  String? orderDate;
  String? customerName;
  String? customerId;
  String? shopName;
  String? orderAmount;
  int? billNumber;
  List<AddCategoryItemModel>? products;

  NewOrdersModel({
    this.orderId,
    this.orderDate,
    this.customerName,
    this.customerId,
    this.shopName,
    this.orderAmount,
    this.billNumber,
    this.products,
  });

  NewOrdersModel.fromMap(Map<String, dynamic> map) {
    orderId = map["orderId"];
    orderDate = map["orderDate"];
    customerName = map["customerName"];
    customerId = map["customerId"];
    shopName = map["shopName"];
    orderAmount = map["orderAmount"];
    billNumber = map["billNumber"];
    products = map["products"]
        .map<AddCategoryItemModel>((x) => AddCategoryItemModel.fromJson(x))
        .toList();
  }

  Map<String, dynamic> toMap() {
    return {
      "orderId": orderId,
      "orderDate": orderDate,
      "customerName": customerName,
      "customerId": customerId,
      "shopName": shopName,
      "orderAmount": orderAmount,
      "billNumber": billNumber,
      "products": products?.map((e) => e.toJson()).toList(),
    };
  }
}

class AddCategoryItemModel {
  String? category;
  String? categoryId;
  List<Products> product;
  List<ProductModel>? productList;
  List<ProductModel>? productMainList;

  AddCategoryItemModel(
      {this.category,
      required this.product,
      required this.categoryId,
      this.productList,
      this.productMainList,
      });

  factory AddCategoryItemModel.fromJson(Map<String, dynamic> json) =>
      AddCategoryItemModel(
        category: json["category"],
        categoryId: json["categoryId"],
        product: json["product"] == null
            ? []
            : List<Products>.from(
                json["product"]!.map((x) => Products.fromMap(x))),
      );

  Map<String, dynamic> toJson() => {
        "category": category,
        "categoryId": categoryId,
        "product": List<dynamic>.from(product.map((x) => x.toMap())),
      };
}

class Products {
  String? productName;
  String? productId;
  int? quantity;
  double? price;
  double? totalPrice;
  String? category;
  int? productStock;
  int? updatedStock;
  TextEditingController? searchController;

  Products({
    this.productName,
    this.productId,
    this.quantity,
    this.price,
    this.totalPrice,
    this.category,
    this.searchController,
    this.productStock,
    this.updatedStock,
  });

  Products.fromMap(Map<String, dynamic> map) {
    productName = map["productName"];
    productId = map["productId"];
    quantity = int.tryParse(map["quantity"]) ?? 0;
    price = double.tryParse(map["price"]) ?? 0.0;
    totalPrice = double.tryParse(map["totalPrice"]) ?? 0.0;
    productStock = 0;
    updatedStock = 0;
    category = map["category"];
    searchController = TextEditingController();
  }

  Map<String, dynamic> toMap() {
    return {
      "productName": productName,
      "productId": productId,
      "quantity": quantity.toString(),
      "price": price.toString(),
      "totalPrice": totalPrice.toString(),
      "category": category,
      "productStock": productStock,
      "updatedStock": updatedStock
    };
  }
}
