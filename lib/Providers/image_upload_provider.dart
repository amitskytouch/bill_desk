import 'dart:io';
import 'package:bill_desk/Constants/textstyle_const.dart';
import 'package:bill_desk/Models/category_model.dart';
import 'package:bill_desk/Widgets/custom_snackbar.dart';
import 'package:bill_desk/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadProvider extends ChangeNotifier {
  File? productImageFile;
  String productImageUrl = "";
  File? customerImageFile;
  String customerImageUrl = "";
  List<CategoryModel> categoryList = [];
  List<CategoryModel> categoryMainList = [];
  String? selectedCategory;

  getAllCategory() async {
    categoryList.clear();
    categoryMainList.clear();
    selectedCategory = null;
    await FirebaseFirestore.instance.collection("category").get().then((value) {
      for (int i = 0; i < value.docs.length; i++) {
        CategoryModel category = CategoryModel(
          id: value.docs[i]["id"],
          category: value.docs[i]["category"],
        );
        categoryList.add(category);
        categoryMainList.add(category);
      }
    });

    notifyListeners();
  }

  filterCategory() {
    // categoryList.clear();
    categoryList = categoryMainList
        .where((element) => element.category != selectedCategory)
        .toList();
    notifyListeners();
  }

  changeCategory(String value) {
    selectedCategory = value;
    notifyListeners();
  }

  editCategory(
      {required String docId,
      required String oldCategory,
      required String newCategory,
      required BuildContext ctx}) async {
    await FirebaseFirestore.instance.collection("category").get().then(
      (value) async {
        int index = value.docs
            .indexWhere((element) => element["category"] == newCategory);

        if (index == -1) {
          await FirebaseFirestore.instance
              .collection("product")
              .where("category", isEqualTo: oldCategory)
              .get()
              .then((value) {
            for (int i = 0; i < value.docs.length; i++) {
              FirebaseFirestore.instance
                  .collection("product")
                  .doc(value.docs[i].id)
                  .update({"category": newCategory});
            }
          });

          await FirebaseFirestore.instance
              .collection("category")
              .doc(docId)
              .update({"category": newCategory});
        } else {
          customSnackBar(
            ctx,
            color: Colors.red,
            message: appLocale!.categorymsg,
          );
        }
      },
    );

    notifyListeners();
  }

  selectProductImage({required ImageSource source}) async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: source, imageQuality: 50);
    if (file == null) return;
    productImageFile = File(file.path);
    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference referenceRoot =
        FirebaseStorage.instance.ref().child("ProductImage");
    Reference referenceImageUpload = referenceRoot.child(uniqueFileName);
    await referenceImageUpload.putFile(File(file.path));
    productImageUrl = await referenceImageUpload.getDownloadURL();

    notifyListeners();
  }

  selectCustomerImage({required ImageSource source}) async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: source, imageQuality: 50);
    if (file == null) return;
    customerImageFile = File(file.path);
    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference referenceRoot =
        FirebaseStorage.instance.ref().child("CustomerImage");
    Reference referenceImageUpload = referenceRoot.child(uniqueFileName);
    await referenceImageUpload.putFile(File(file.path));
    customerImageUrl = await referenceImageUpload.getDownloadURL();

    notifyListeners();
  }

  customerImageUpload(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(
              "Select Image Source",
              style: customTextStyle(size: 18, fontWeight: FontWeight.bold),
            ),
            actions: [
              TextButton.icon(
                onPressed: () {
                  selectCustomerImage(source: ImageSource.camera);
                  Navigator.pop(context);
                },
                icon: Icon(Icons.camera_alt),
                label: Text(
                  "Camera",
                  style: customTextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  selectCustomerImage(source: ImageSource.gallery);
                  Navigator.pop(context);
                },
                icon: Icon(Icons.image),
                label: Text(
                  "Gallery",
                  style: customTextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          );
        });
    notifyListeners();
  }

  productImageUpload(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(
              "Select Image Source",
              style: customTextStyle(size: 18, fontWeight: FontWeight.bold),
            ),
            actions: [
              TextButton.icon(
                onPressed: () {
                  selectProductImage(source: ImageSource.camera);
                  Navigator.pop(context);
                },
                icon: Icon(Icons.camera_alt),
                label: Text(
                  "Camera",
                  style: customTextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  selectProductImage(source: ImageSource.gallery);
                  Navigator.pop(context);
                },
                icon: Icon(Icons.image),
                label: Text(
                  "Gallery",
                  style: customTextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          );
        });
    notifyListeners();
  }
}
