import 'package:bill_desk/Models/customer_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerServices {
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Future addCustomer({
    required String name,
    required String shopName,
    required String phoneNumber,
    required String address,
    required String image,
  }) async {
    CollectionReference ref = firestore.collection('customer');
    String docId = ref.doc().id;
    CustomerModel customer = CustomerModel(
      name: name,
      shopName: shopName,
      phoneNumber: phoneNumber,
      address: address,
      id: docId,
      image: image,
    );
    return await ref.doc(docId).set(customer.toMap());
  }

  static Future editCustomer({
    required String uid,
    required String name,
    required String shopName,
    required String phoneNumber,
    required String address,
    required String image,
  }) async {
    CustomerModel customer = CustomerModel(
      name: name,
      shopName: shopName,
      phoneNumber: phoneNumber,
      address: address,
      id: uid,
      image: image,
    );
    return await firestore
        .collection("customer")
        .doc(uid)
        .update(customer.toMap());
  }

  static Future deleteCustomer({required String uid}) async {
    return await firestore.collection("customer").doc(uid).delete();
  }
}
