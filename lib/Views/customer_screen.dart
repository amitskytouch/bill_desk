import 'dart:io';
import 'package:bill_desk/Constants/color_const.dart';
import 'package:bill_desk/Constants/textstyle_const.dart';
import 'package:bill_desk/Models/customer_model.dart';
import 'package:bill_desk/Providers/image_upload_provider.dart';
import 'package:bill_desk/Utils/global_handler.dart';
import 'package:bill_desk/Views/customer_detail_screen.dart';
import 'package:bill_desk/Widgets/custom_textfield.dart';
import 'package:bill_desk/Widgets/theme_button.dart';
import 'package:bill_desk/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../FirebaseServices/customer_services.dart';

class CustomerScreen extends StatefulWidget {
  CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController shopNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _clearController({required ImageUploadProvider provider}) {
    nameController.clear();
    shopNameController.clear();
    phoneNumberController.clear();
    addressController.clear();
    provider.customerImageFile = null;
    provider.customerImageUrl = "";
  }

  void _openBottomSheet(BuildContext ctx) {
    showModalBottomSheet(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.97),
        isScrollControlled: true,
        useSafeArea: true,
        shape: const OutlineInputBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25),
          ),
        ),
        context: ctx,
        builder: (context) {
          return Consumer<ImageUploadProvider>(
              builder: (context, provider, child) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.8,
                maxChildSize: 0.9,
                builder: (_, controller) {
                  return GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: Container(
                      padding:
                          const EdgeInsets.only(left: 10, right: 10, top: 30),
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          shrinkWrap: true,
                          controller: controller,
                          children: [
                            CustomTextField(
                              hint: "${appLocale?.customerName}",
                              controller: nameController,
                              validator: (String? value) {
                                if (value!.isEmpty || value == "") {
                                  return "${appLocale?.validator}";
                                } else {
                                  return null;
                                }
                              },
                            ),
                            const SizedBox(height: 10),
                            CustomTextField(
                              hint: "${appLocale?.shopName}",
                              controller: shopNameController,
                              validator: (String? value) {
                                if (value!.isEmpty || value == "") {
                                  return "${appLocale?.validator}";
                                } else {
                                  return null;
                                }
                              },
                            ),
                            const SizedBox(height: 10),
                            CustomTextField(
                              hint: "${appLocale?.phoneNumber}",
                              controller: phoneNumberController,
                              keyBoardType: TextInputType.number,
                              validator: (String? value) {
                                if (value!.isEmpty || value == "") {
                                  return "${appLocale?.validator}";
                                } else {
                                  return null;
                                }
                              },
                            ),
                            const SizedBox(height: 10),
                            CustomTextField(
                              hint: "${appLocale?.address}",
                              controller: addressController,
                              validator: (String? value) {
                                if (value!.isEmpty || value == "") {
                                  return "${appLocale?.validator}";
                                } else {
                                  return null;
                                }
                              },
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: Column(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: purpleColor),
                                    ),
                                    child: provider.customerImageFile != null
                                        ? Image.file(
                                            File(provider
                                                .customerImageFile!.path),
                                            fit: BoxFit.cover,
                                          )
                                        : const SizedBox(),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        provider.customerImageUpload(context),
                                    child: Text(
                                      "${appLocale?.imageUpload}",
                                      style: customTextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                            ThemeButton(
                              image: "assets/images/noun-profile-1975487.svg",
                              text: "${appLocale?.addCustomer}",
                              onTap: () {
                                if (_formKey.currentState!.validate()) {
                                  CustomerServices.addCustomer(
                                    name: nameController.text,
                                    shopName: shopNameController.text,
                                    phoneNumber: phoneNumberController.text,
                                    address: addressController.text,
                                    image: provider.customerImageUrl,
                                  );
                                  Navigator.of(context).pop();
                                  _clearController(provider: provider);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("${appLocale?.customer}"),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: purpleColor,
        elevation: 0,
        onPressed: () => _openBottomSheet(context),
        child: SvgPicture.asset(
          "assets/images/noun-add-5852019 1.svg",
          width: 33,
          height: 33,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("customer")
              .orderBy("shop_name", descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.data!.docs.isEmpty) {
              return Center(
                  child: Text(
                "No Data Found...",
                style: customTextStyle(
                    size: 16, fontWeight: FontWeight.w600, color: Colors.grey),
              ));
            } else {
              QuerySnapshot data = snapshot.data as QuerySnapshot;
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: data.docs.length,
                itemBuilder: (context, index) {
                  CustomerModel customer = CustomerModel.fromMap(
                      data.docs[index].data() as Map<String, dynamic>);
                  return Card(
                    margin: const EdgeInsets.only(top: 10),
                    elevation: 1,
                    shape: OutlineInputBorder(
                      borderSide: const BorderSide(color: purpleColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: whiteColor,
                          backgroundImage: customer.image != ""
                              ? NetworkImage("${customer.image}")
                              : AssetImage("assets/images/profile.png")
                                  as ImageProvider,
                        ),
                        title: Text(
                          "${customer.shopName}",
                          overflow: TextOverflow.ellipsis,
                          style: customTextStyle(fontWeight: FontWeight.w600),
                        ),
                        trailing: SizedBox(
                          width: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SvgPicture.asset(
                                "assets/images/noun-report-1252473 1.svg",
                                width: 30,
                                height: 30,
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: purpleColor,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                        onTap: () => navigatorPush(
                          context,
                          CustomerDetailScreen(customer: customer),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
