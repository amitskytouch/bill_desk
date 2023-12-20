import 'package:bill_desk/Models/category_model.dart';
import 'package:bill_desk/Widgets/custom_snackbar.dart';
import 'package:bill_desk/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoryProvider extends ChangeNotifier {
  final firestore = FirebaseFirestore.instance;
  int productCount = 0;

  addCategory({required String category, required BuildContext ctx}) async {
    await firestore.collection("category").get().then((value) {
      int index =
          value.docs.indexWhere((element) => element["category"] == category);
      if (index == -1) {
        CollectionReference ref = firestore.collection('category');
        String docId = ref.doc().id;
        CategoryModel newCategory = CategoryModel(
          id: docId,
          category: category,
        );
        ref.doc(docId).set(newCategory.toMap());
      } else {
        customSnackBar(
          ctx,
          color: Colors.red,
          message: appLocale!.categorymsg,
        );
      }
    });

    notifyListeners();
  }

  Future<String> getCategoryviseProduct(String category) async {
    return await firestore
        .collection("product")
        .where("category", isEqualTo: category)
        .get()
        .then((value) {
      return value.docs.length.toString();
    });
  }

}
