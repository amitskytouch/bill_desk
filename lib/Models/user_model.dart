class UserModel {
  String? id;
  String? businessName;
  String? name;
  String? phoneNumber;
  String? address;
  String? email;
  String? password;
  String? logo;
  int? billNo;

  UserModel({
    this.id,
    this.businessName,
    this.name,
    this.phoneNumber,
    this.address,
    this.email,
    this.password,
    this.logo,
    this.billNo,
  });

  UserModel.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    businessName = map["businessName"];
    name = map["name"];
    phoneNumber = map["phoneNumber"];
    address = map["address"];
    email = map["email"];
    password = map["password"];
    logo = map["logo"];
    billNo = map["billNo"];
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "businessName": businessName,
      "name": name,
      "phoneNumber": phoneNumber,
      "address": address,
      "email": email,
      "password": password,
      "logo": logo,
      "billNo": billNo,
    };
  }
}
