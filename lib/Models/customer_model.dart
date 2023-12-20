class CustomerModel {
  String? name;
  String? shopName;
  String? phoneNumber;
  String? address;
  String? id;
  String? image;

  CustomerModel({
    this.name,
    this.shopName,
    this.phoneNumber,
    this.address,
    this.id,
    this.image,
  });

  CustomerModel.fromMap(Map<String, dynamic> map) {
    name = map["name"];
    shopName = map["shop_name"];
    phoneNumber = map["phone_number"];
    address = map["address"];
    id = map["id"];
    image = map["image"];
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "shop_name": shopName,
      "phone_number": phoneNumber,
      "address": address,
      "id": id,
      "image": image,
    };
  }
}
