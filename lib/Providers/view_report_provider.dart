import 'package:bill_desk/Models/new_order_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class ViewReportProvider extends ChangeNotifier {
  DateTime selectedDate = DateTime.now();
  var format = intl.DateFormat("dd-MM-yyyy");
  List<AddCategoryItemModel> productData = [];
  List<AddCategoryItemModel> mainProductData = [];

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

  getData({required String date}) async {
    productData.clear();
    mainProductData.clear();

    await FirebaseFirestore.instance
        .collection("orders")
        .where("orderDate", isEqualTo: date)
        .get()
        .then((value) {
      final snapshot = value.docs;

      for (var i = 0; i < snapshot.length; i++) {
        mainProductData.addAll(List.from(
            (snapshot[i].data()["products"] as List)
                .map((e) => AddCategoryItemModel.fromJson(e))));
      }
    });

 for (var j = 0; j < mainProductData.length; j++) {
        int catIndex = productData.indexWhere(
            (element) => element.category == mainProductData[j].category);
        if (catIndex != -1) {
          for (var k = 0; k < mainProductData[j].product.length; k++) {
            int index = productData[catIndex].product.indexWhere((element) =>
                element.productName ==
                mainProductData[j].product[k].productName);
            if (index != -1) {
              productData[catIndex].product[index].quantity =
                  productData[catIndex].product[index].quantity! +
                      mainProductData[j].product[k].quantity!;
            } else {
              productData[catIndex].product.add(mainProductData[j].product[k]);
            }
          }
        } else {
          productData.add(mainProductData[j]);
        }
      }

      // for (var i = 0; i < snapshot.length; i++) {
      //   for (var j = 0; j < snapshot[i].data()["products"].length; j++) {
      //     for (var k = 0;
      //         k < snapshot[i].data()["products"][j]["product"].length;
      //         k++) {
      //       int index = productData.indexWhere((element) =>
      //           element["productName"] ==
      //           snapshot[i].data()["products"][j]["product"][k]["productName"]);
      //       if (index != -1) {
      //         productData[index]["quantity"] = productData[index]["quantity"] +
      //             int.parse(snapshot[i].data()["products"][j]["product"][k]
      //                 ["quantity"]);
      //       } else {
      //         Map<String, dynamic> temp = {
      //           "productName": snapshot[i].data()["products"][j]["product"][k]
      //               ["productName"],
      //           "quantity": int.parse(snapshot[i].data()["products"][j]
      //               ["product"][k]["quantity"]),
      //         };
      //         productData.add(temp);
      //       }
      //     }
      //   }
      // }

    notifyListeners();
  }
}
