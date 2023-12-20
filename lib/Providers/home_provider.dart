import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class HomeProvider extends ChangeNotifier {
  final fireStore = FirebaseFirestore.instance;
  DateTime selectedDate = DateTime.now();
  double todaySale = 0;
  int todayOrder = 0;
  int itemCount = 0;
  int totalStock = 0;
  double stockValue = 0;
  int customerCount = 0;
  int categoryCount = 0;
  var format = intl.DateFormat("dd-MM-yyyy");

  disposeData() {
    selectedDate = DateTime.now();
    todaySale = 0;
    todayOrder = 0;
    itemCount = 0;
    totalStock = 0;
    stockValue = 0;
    customerCount = 0;
    categoryCount = 0;
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

  getData() async {
    final sales = await fireStore
        .collection("orders")
        .where("orderDate", isEqualTo: format.format(selectedDate))
        .get();
    todayOrder = sales.docs.length;
    var snap = sales.docs;
    for (var e in snap) {
      todaySale = todaySale + double.parse(e.data()["orderAmount"]);
    }

    final products = await fireStore.collection("product").get();
    itemCount = products.docs.length;
    var snapshot = products.docs;
    for (var i in snapshot) {
      totalStock = totalStock + (int.parse(i.data()["stock"]));
      stockValue = stockValue +
          (double.parse(i.data()["product_price"]) *
              double.parse(i.data()["stock"]));
    }

    final customer = await fireStore.collection("customer").get();
    var shot = customer.docs;
    customerCount = shot.length;

    final category = await fireStore.collection("category").get();
    categoryCount = category.docs.length;

    notifyListeners();
  }
}
