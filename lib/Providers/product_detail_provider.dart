import 'dart:io';
import 'package:bill_desk/Constants/textstyle_const.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProductDetailProvider extends ChangeNotifier {
  int updatedStock = 0;
  File? productImageFile;
  String productImageUrl = "";
  File? customerImageFile;
  String customerImageUrl = "";

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

  updateStock(List<int> val) {
    updatedStock = updatedStock - val[(val.length - 2)];
    updatedStock = updatedStock + val[(val.length - 1)];

    notifyListeners();
  }
}
