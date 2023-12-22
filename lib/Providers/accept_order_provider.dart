import 'dart:convert';
import 'dart:developer';
import 'package:bill_desk/Models/category_model.dart';
import 'package:bill_desk/Models/customer_model.dart';
import 'package:bill_desk/Models/product_model.dart';
import 'package:bill_desk/Widgets/custom_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AcceptOrderProvider extends ChangeNotifier {
  List<CustomerModel> customerList = [];
  List<CategoryModel> categoryList = [];
  List<CategoryModel> categoryMainList = [];
  List<AddCategoryItemModel> addCategoryList = [];
  double totalAmount = 0;
  DateTime selectedDate = DateTime.now();
  int count = 0;

  oninit() {
    addCategoryList = [
      AddCategoryItemModel(
        category: null,
        categoryId: null,
        product: [],
        productList: [],
      )
    ];
  }

  setCategory(String value, int index) {
    addCategoryList[index].product.clear();
    int i = categoryList.indexWhere((element) => element.category == value);
    if (i != -1) {
      addCategoryList[index].category = value;
      addCategoryList[index].categoryId = categoryList[i].id;
      addNewEmptyProduct(index);
    }

    notifyListeners();
  }

  bool addNewCategory() {
    if (categoryList.isNotEmpty) {
      addCategoryList.add(
        AddCategoryItemModel(
            category: null, categoryId: null, product: [], productList: []),
      );
      notifyListeners();

      return true;
    } else {
      notifyListeners();

      return false;
    }
  }

  addNewEmptyProduct(int index) {
    addCategoryList[index].product.add(Product(
        name: "", qty: 0, price: 0, searchController: TextEditingController()));
  }

  filterCategory() {
    categoryList = categoryMainList
        .where((element) =>
            addCategoryList
                .indexWhere((emt) => emt.category == element.category) ==
            -1)
        .toList();
  }

  filterProduct(int i) {
    addCategoryList[i].productList = addCategoryList[i]
        .productList
        .where((element) =>
            addCategoryList[i]
                .product
                .indexWhere((ele) => ele.name == element.productName) ==
            -1)
        .toList();
  }

  getCount(String id) async {
    await FirebaseFirestore.instance
        .collection("users")
        .where("id", isEqualTo: id)
        .get()
        .then((value) {
      count = value.docs[0]["billNo"];
    });
    notifyListeners();
  }

  updateCount(String id) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .update({"billNo": count + 1});
  }

  Future<void> getCustomer() async {
    List<CustomerModel> temp = [];
    await FirebaseFirestore.instance.collection("customer").get().then((value) {
      for (var i = 0; i < value.docs.length; i++) {
        CustomerModel newModel = CustomerModel.fromMap(value.docs[i].data());
        temp.add(newModel);
      }
    });
    customerList = temp;
    notifyListeners();
  }

  Future<void> getCategory() async {
    List<CategoryModel> temp = [];
    await FirebaseFirestore.instance.collection("category").get().then((value) {
      for (var i = 0; i < value.docs.length; i++) {
        CategoryModel newModel = CategoryModel.fromMap(value.docs[i].data());
        temp.add(newModel);
      }
    });
    categoryList = temp;
    categoryMainList = temp;
    notifyListeners();
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
    }
    notifyListeners();
  }

  disposeData() {
    selectedDate = DateTime.now();
    // productController.clear();
    totalAmount = 0;
  }

  Future<void> getProduct(String category, int index) async {
    List<ProductModel> temp = [];
    await FirebaseFirestore.instance
        .collection("product")
        .where("category", isEqualTo: category)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        for (var i = 0; i < value.docs.length; i++) {
          ProductModel newModel = ProductModel.fromMap(value.docs[i].data());
          temp.add(newModel);
        }
      }
    });
    addCategoryList[index].productList = temp;
    notifyListeners();
  }

  increaseQuantity(int index, BuildContext context, int subIndex) {
    if (addCategoryList[index].product[subIndex].qty! <
        addCategoryList[index].product[subIndex].productStock!) {
      addCategoryList[index].product[subIndex].qty =
          addCategoryList[index].product[subIndex].qty! + 1;
      addCategoryList[index].product[subIndex].updateStock =
          addCategoryList[index].product[subIndex].updateStock! - 1;
      addCategoryList[index].product[subIndex].totalPrice =
          addCategoryList[index].product[subIndex].totalPrice! +
              addCategoryList[index].product[subIndex].price!;
      totalAmount =
          totalAmount + addCategoryList[index].product[subIndex].price!;
    } else {
      customSnackBar(context,
          color: Colors.red, message: "No More Stock Available");
    }
    notifyListeners();
  }

  decreaseQuantity(int index, int subIndex) {
    if (addCategoryList[index].product[subIndex].qty! > 0) {
      addCategoryList[index].product[subIndex].qty =
          addCategoryList[index].product[subIndex].qty! - 1;
      addCategoryList[index].product[subIndex].updateStock =
          addCategoryList[index].product[subIndex].updateStock! + 1;
      addCategoryList[index].product[subIndex].totalPrice =
          addCategoryList[index].product[subIndex].totalPrice! -
              addCategoryList[index].product[subIndex].price!;
      totalAmount =
          totalAmount - addCategoryList[index].product[subIndex].price!;
    }
    if (addCategoryList[index].product[subIndex].qty == 0) {
      String productName =
          addCategoryList[index].product[subIndex].name.toString();
      addCategoryList[index].product.removeAt(subIndex);
      getRemovedProduct(
          index, addCategoryList[index].category.toString(), productName);
    }

    notifyListeners();
  }

  getRemovedProduct(int index, String category, String productName) async {
    await FirebaseFirestore.instance
        .collection("product")
        .where("category", isEqualTo: category)
        .where("product_name", isEqualTo: productName)
        .get()
        .then((value) => addCategoryList[index]
            .productList
            .add(ProductModel.fromMap(value.docs[0].data())));

    notifyListeners();
  }

  getPrice(String name, int index, int subIndex) async {
    await FirebaseFirestore.instance
        .collection("product")
        .where("product_name", isEqualTo: name)
        .get()
        .then((value) {
      addCategoryList[index].product[subIndex].price =
          double.parse(value.docs[0]["product_price"]);
      addCategoryList[index].product[subIndex].qty = 1;
      addCategoryList[index].product[subIndex].totalPrice =
          double.parse(value.docs[0]["product_price"]);
      addCategoryList[index].product[subIndex].productId = value.docs[0]["id"];
      addCategoryList[index].product[subIndex].productStock =
          int.parse(value.docs[0]["stock"]);
      addCategoryList[index].product[subIndex].updateStock =
          int.parse(value.docs[0]["stock"]) > 0
              ? int.parse(value.docs[0]["stock"]) - 1
              : 0;
      totalAmount =
          totalAmount + addCategoryList[index].product[subIndex].price!;
    });

    notifyListeners();
  }
}

AddCategoryItemModel addCategoryItemModelFromJson(String str) =>
    AddCategoryItemModel.fromJson(json.decode(str));

String addCategoryItemModelToJson(AddCategoryItemModel data) =>
    json.encode(data.toJson());

class AddCategoryItemModel {
  String? category;
  String? categoryId;
  List<Product> product;
  List<ProductModel> productList;

  AddCategoryItemModel({
    required this.category,
    required this.product,
    required this.productList,
    required this.categoryId,
  });

  factory AddCategoryItemModel.fromJson(Map<String, dynamic> json) =>
      AddCategoryItemModel(
        category: json["category"],
        categoryId: json["categoryId"],
        productList: json["productList"] == null
            ? []
            : List<ProductModel>.from(
                json["productList"]!.map((x) => ProductModel.fromMap(x))),
        product: json["product"] == null
            ? []
            : List<Product>.from(
                json["product"]!.map((x) => Product.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "category": category,
        "categoryId": categoryId,
        "product": List<dynamic>.from(product.map((x) => x.toJson())),
      };
}

class Product {
  String? name;
  String? productId;
  int? qty;
  int? productStock;
  double? price;
  int? updateStock;
  double? totalPrice;
  TextEditingController? searchController;

  Product(
      {this.name,
      this.productId,
      this.productStock,
      this.qty,
      this.price,
      this.updateStock,
      this.totalPrice,
      this.searchController});

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        name: json["name"],
        productId: json["productId"],
        qty: json["qty"],
        productStock: json["productStock"],
        price: json["total"],
        updateStock: json["updateStock"],
        totalPrice: json["updatePrice"],
        searchController: TextEditingController(),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "qty": qty,
        "total": price,
      };
}
