import 'package:bill_desk/Models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductServices {
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Future addProduct({
    required String productName,
    required String productPrice,
    required String stock,
    required String image,
    required String category,
  }) async {
    CollectionReference ref = firestore.collection('product');
    String docId = ref.doc().id;
    ProductModel product = ProductModel(
      id: docId,
      productName: productName,
      productPrice: productPrice,
      stock: stock,
      image: image,
      category: category,
    );
    await ref.doc(docId).set(product.toMap());
  }



  static Future editProduct({
    required String uid,
    required String productName,
    required String productPrice,
    required String stock,
    required String image,
    required String category,
  }) async {
    ProductModel product = ProductModel(
      id: uid,
      productName: productName,
      productPrice: productPrice,
      stock: stock,
      image: image,
      category: category,
    );
    await firestore.collection("product").doc(uid).update(product.toMap());
  }

  static Future deleteProduct({required String uid}) async {
    return await firestore.collection("product").doc(uid).delete();
  }

    deleteCategory({required String docId, required String category}) async {
    await firestore
        .collection("product")
        .where("category", isEqualTo: category)
        .get()
        .then((value) {
      for (int i = 0; i < value.docs.length; i++) {
        firestore.collection("product").doc(value.docs[i].id).delete();
      }
    });
    await firestore.collection("category").doc(docId).delete();

    

  }

}
