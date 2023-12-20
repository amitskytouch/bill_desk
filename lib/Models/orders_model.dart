
class OrdersModel {
  String? orderId;
  String? orderDate;
  String? customerName;
  String? customerId;
  String? shopName;
  String? orderAmount;
  int? billNumber;
  List<Products>? products;

  OrdersModel({
    this.orderId,
    this.orderDate,
    this.customerName,
    this.customerId,
    this.shopName,
    this.orderAmount,
    this.billNumber,
    this.products,
});

  OrdersModel.fromMap(Map<String, dynamic> map) {
    orderId = map["orderId"];
    orderDate = map["orderDate"];
    customerName = map["customerName"];
    customerId = map["customerId"];
    shopName = map["shopName"];
    orderAmount = map["orderAmount"];
    billNumber = map["billNumber"];
    products = map["products"].map<Products>((x) => Products.fromMap(x)).toList();
  }

  Map<String, dynamic> toMap() {
    return {
      "orderId": orderId,
      "orderDate": orderDate,
      "customerName": customerName,
      "customerId": customerId,
      "shopName": shopName,
      "orderAmount": orderAmount,
      "billNumber": billNumber,
      "products" : products?.map((e) => e.toMap()).toList(),
    };
  }
}

class Products {
  String? productName;
  String? productId;
  String? quantity;
  String? price;
  String? totalPrice;
  String? category;

  Products({
    this.productName,
    this.productId,
    this.quantity,
    this.price,
    this.totalPrice,
    this.category,
});

  Products.fromMap(Map<String, dynamic> map) {
    productName = map["productName"];
    productId = map["productId"];
    quantity = map["quantity"];
    price = map["price"];
    totalPrice = map["totalPrice"];
    category = map["category"];
  }

  Map<String, dynamic> toMap() {
    return {
      "productName": productName,
      "productId": productId,
      "quantity": quantity,
      "price": price,
      "totalPrice": totalPrice,
      "category": category,
    };
  }
}