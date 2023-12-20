import 'package:bill_desk/Models/new_order_model.dart' as ne;
import 'package:bill_desk/Models/new_order_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderServices {
  static FirebaseFirestore firestore = FirebaseFirestore.instance;


  static deleteNewOrder({required String docId}) {
    firestore.collection("orders").doc(docId).delete();
  }

  static editNewOrder({
    required int? billNumber,
    required String orderId,
    required String orderDate,
    required String customerName,
    required String customerId,
    required String shopName,
    required String orderAmount,
    required List<AddCategoryItemModel> products,
}) async {
    NewOrdersModel order = NewOrdersModel(
      billNumber: billNumber,
      orderId: orderId,
      orderDate: orderDate,
      customerName: customerName,
      customerId: customerId,
      shopName: shopName,
      orderAmount: orderAmount,
      products: products,
    );
    return await firestore.collection("orders").doc(orderId).update(order.toMap());
  }

  static Future addNewOrder({
    required int billNumber,
    required String orderDate,
    required String customerName,
    required String customerId,
    required String shopName,
    required String orderAmount,
    required List<ne.AddCategoryItemModel> products,
  }) async {
    CollectionReference ref = firestore.collection("orders");
    String docId = ref.doc().id;
   ne. NewOrdersModel orders =ne. NewOrdersModel(
      orderId: docId,
      billNumber: billNumber,
      orderDate: orderDate,
      customerName: customerName,
      customerId: customerId,
      shopName: shopName,
      orderAmount: orderAmount,
      products: products,
    );
    return await ref.doc(docId).set(orders.toMap());
  }
}
