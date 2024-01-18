import 'package:bill_desk/Models/category_model.dart';
import 'package:bill_desk/Models/new_order_model.dart';
import 'package:bill_desk/Widgets/custom_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Models/product_model.dart';

class EditOrderProvider extends ChangeNotifier {
  DateTime selectedDate = DateTime.now();
  final firestore = FirebaseFirestore.instance.collection("product");
  double totalAmount = 0;
  List<ProductModel> productList = [];

  //
  List<AddCategoryItemModel> productData = [];
  List<CategoryModel> categoryList = [];
  List<CategoryModel> categoryMainList = [];
  List<Products> dummyList = [];
  bool isLoading = true;

  addValueToController(NewOrdersModel orders) async {
    productData.clear();
    dummyList.clear();
    isLoading = true;
    totalAmount = double.parse(orders.orderAmount.toString());

    for (var i = 0; i < orders.products!.length; i++) {
      productData.add(orders.products![i]);
      await getProduct(orders.products![i].category.toString(), i);

      filterProduct(i);
      if (productData[i].productList!.isNotEmpty) {
        addNewEmptyProduct(i);
      }
      filterCategory();
      await getProductStock(i);
    }

    isLoading = false;

    notifyListeners();
  }

  filterCategory() {
    categoryList = categoryMainList
        .where((element) =>
            productData.indexWhere((emt) => emt.category == element.category) ==
            -1)
        .toList();
    notifyListeners();
  }

  filterProduct(int i) {
    productData[i].productList = productData[i]
        .productMainList!
        .where((element) =>
            productData[i]
                .product
                .indexWhere((ele) => ele.productName == element.productName) ==
            -1)
        .toList();
  }

  getProductStock(int index) async {
    for (var i = 0; i < productData[index].product.length; i++) {
      await FirebaseFirestore.instance
          .collection("product")
          .where("id", isEqualTo: productData[index].product[i].productId)
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          productData[index].product[i].productStock =
              int.parse(value.docs[0]["stock"]);
          productData[index].product[i].updatedStock =
              int.parse(value.docs[0]["stock"]);
        }
      });
    }
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
    filterCategory();
    notifyListeners();
  }

  bool addNewCategory() {
    if (categoryList.isNotEmpty) {
      productData.add(
        AddCategoryItemModel(category: null, categoryId: null, product: [
          Products(
              productName: "",
              quantity: 0,
              price: 0,
              searchController: TextEditingController())
        ], productList: []),
      );
      notifyListeners();
      return true;
    } else {
      notifyListeners();
      return false;
    }
  }

  addNewEmptyProduct(int index) {
    productData[index].product.add(Products(
        productName: "",
        quantity: 0,
        price: 0,
        searchController: TextEditingController()));
  }

  setCategory(String value, int index) {
    productData[index].product.clear();
    int i = categoryList.indexWhere((element) => element.category == value);
    if (i != -1) {
      productData[index].category = value;
      productData[index].categoryId = categoryList[i].id;
      addNewEmptyProduct(index);
    }

    notifyListeners();
  }

  disposeData() {
    productData.clear();
  }

  getPrice(String name, int index, int subIndex) async {
    if (subIndex != (productData[index].product.length - 1)) {
      totalAmount =
          totalAmount - productData[index].product[subIndex].totalPrice!;
    }
    await FirebaseFirestore.instance
        .collection("product")
        .where("product_name", isEqualTo: name)
        .get()
        .then((value) {
      productData[index].product[subIndex].price =
          double.parse(value.docs[0]["product_price"]);
      productData[index].product[subIndex].quantity = 1;
      productData[index].product[subIndex].totalPrice =
          double.parse(value.docs[0]["product_price"]);
      productData[index].product[subIndex].productId = value.docs[0]["id"];
      productData[index].product[subIndex].productStock =
          int.parse(value.docs[0]["stock"]);
      productData[index].product[subIndex].updatedStock =
          int.parse(value.docs[0]["stock"]) - 1;

      totalAmount = totalAmount + double.parse(value.docs[0]["product_price"]);
    });

    notifyListeners();
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
          if (int.parse(newModel.stock.toString()) > 0) {
            temp.add(newModel);
          }
        }
      }
    });
    productData[index].productList = temp;
    productData[index].productMainList = temp;

    notifyListeners();
  }

  increaseQuantity(int index, int subIndex, BuildContext context) {
    if (productData[index].product[subIndex].updatedStock! > 0) {
      productData[index].product[subIndex].quantity =
          productData[index].product[subIndex].quantity! + 1;
      productData[index].product[subIndex].updatedStock =
          productData[index].product[subIndex].updatedStock! - 1;
      productData[index].product[subIndex].totalPrice =
          productData[index].product[subIndex].totalPrice! +
              productData[index].product[subIndex].price!;
      totalAmount = totalAmount + productData[index].product[subIndex].price!;
    } else {
      customSnackBar(context,
          color: Colors.red, message: "No More Stock Available");
    }
    notifyListeners();
  }

  decreaseQuantity(int index, int subIndex) async {
    if (productData[index].product[subIndex].quantity! > 0) {
      productData[index].product[subIndex].quantity =
          productData[index].product[subIndex].quantity! - 1;
      productData[index].product[subIndex].updatedStock =
          productData[index].product[subIndex].updatedStock! + 1;
      productData[index].product[subIndex].totalPrice =
          productData[index].product[subIndex].totalPrice! -
              productData[index].product[subIndex].price!;
      totalAmount = totalAmount - productData[index].product[subIndex].price!;
    }

    if (productData[index].product[subIndex].quantity! == 0) {
      dummyList.add(productData[index].product[subIndex]);
      String productName =
          productData[index].product[subIndex].productName.toString();
      productData[index].product.removeAt(subIndex);
      getRemovedProduct(
          index, productData[index].category.toString(), productName);
    }
    notifyListeners();
  }

  getRemovedProduct(int index, String category, String productName) async {
    await FirebaseFirestore.instance
        .collection("product")
        .where("category", isEqualTo: category)
        .where("product_name", isEqualTo: productName)
        .get()
        .then((value) => productData[index]
            .productList!
            .add(ProductModel.fromMap(value.docs[0].data())));
    if (productData[index].product.length ==
        productData[index].productList?.length) {
      addNewEmptyProduct(index);
    }
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
}
