import 'dart:io';
import 'package:bill_desk/Constants/color_const.dart';
import 'package:bill_desk/Constants/textstyle_const.dart';
import 'package:bill_desk/Models/customer_model.dart';
import 'package:bill_desk/Providers/product_detail_provider.dart';
import 'package:bill_desk/Widgets/custom_textfield.dart';
import 'package:bill_desk/Widgets/theme_button.dart';
import 'package:bill_desk/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../FirebaseServices/customer_services.dart';

class CustomerDetailScreen extends StatefulWidget {
  final CustomerModel customer;
  CustomerDetailScreen({super.key, required this.customer});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController shopNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _addValueToController() {
    nameController.text = "${widget.customer.name}";
    shopNameController.text = "${widget.customer.shopName}";
    phoneNumberController.text = "${widget.customer.phoneNumber}";
    addressController.text = "${widget.customer.address}";
  }

  @override
  void initState() {
    final productDetailProvider =
        Provider.of<ProductDetailProvider>(context, listen: false);
    productDetailProvider.customerImageFile = null;
    productDetailProvider.customerImageUrl = "";
    _addValueToController();
    super.initState();
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
          return Consumer<ProductDetailProvider>(
              builder: (context, detail, child) {
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
                                    child: detail.customerImageFile != null
                                        ? Image.file(
                                            File(
                                                detail.customerImageFile!.path),
                                            fit: BoxFit.cover,
                                          )
                                        : widget.customer.image != ""
                                            ? Image.network(
                                                "${widget.customer.image}",
                                                fit: BoxFit.cover,
                                              )
                                            : const SizedBox(),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      detail.customerImageUpload(
                                        context,
                                      );
                                    },
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
                              image: "assets/images/Vector (3).svg",
                              text: "${appLocale?.save}",
                              onTap: () {
                                if (_formKey.currentState!.validate()) {
                                  CustomerServices.editCustomer(
                                    uid: widget.customer.id.toString(),
                                    name: nameController.text,
                                    shopName: shopNameController.text,
                                    phoneNumber: phoneNumberController.text,
                                    address: addressController.text,
                                    image: detail.customerImageUrl == ""
                                        ? widget.customer.image.toString()
                                        : detail.customerImageUrl,
                                  );
                                  Navigator.pop(context);
                                  setState(() {});
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

  openDeleteDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(
              "${appLocale?.areYouSure}",
              style: customTextStyle(
                  size: 18, color: purpleColor, fontWeight: FontWeight.w700),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  CustomerServices.deleteCustomer(
                      uid: widget.customer.id.toString());
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text(
                  "${appLocale?.yes}",
                  style: customTextStyle(
                      size: 18, color: blackColor, fontWeight: FontWeight.w700),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  "${appLocale?.no}",
                  style: customTextStyle(
                      size: 18, color: blackColor, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("${appLocale?.customerDetail}"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FloatingActionButton(
            heroTag: "button1",
            backgroundColor: purpleColor,
            elevation: 0,
            onPressed: () => _openBottomSheet(context),
            child: SvgPicture.asset(
              "assets/images/noun-edit-4528904 1.svg",
              width: 25,
              height: 25,
            ),
          ),
          FloatingActionButton(
            heroTag: "button2",
            backgroundColor: purpleColor,
            elevation: 0,
            onPressed: () {
              openDeleteDialog(context);
            },
            child: SvgPicture.asset(
              "assets/images/noun-delete-4778235 1.svg",
              width: 25,
              height: 25,
            ),
          ),
        ],
      ),
      body:
          Consumer<ProductDetailProvider>(builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Center(
                child: provider.customerImageUrl != ""
                    ? Image.network(
                        provider.customerImageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      )
                    : widget.customer.image != ""
                        ? Image.network(
                            "${widget.customer.image}",
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : SvgPicture.asset(
                            "assets/images/noun-profile-1975487.svg",
                            width: 100,
                            height: 100,
                          ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                decoration: BoxDecoration(
                  border: Border.all(color: purpleColor),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "${appLocale?.customerName} : ",
                            style: customTextStyle(
                              size: 17,
                              fontWeight: FontWeight.w600,
                              color: purpleColor,
                            ),
                          ),
                          TextSpan(
                            text: nameController.text,
                            style: customTextStyle(
                              size: 17,
                              fontWeight: FontWeight.w600,
                              color: blackColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "${appLocale?.shopName} : ",
                            style: customTextStyle(
                              size: 17,
                              fontWeight: FontWeight.w600,
                              color: purpleColor,
                            ),
                          ),
                          TextSpan(
                            text: shopNameController.text,
                            style: customTextStyle(
                              size: 17,
                              fontWeight: FontWeight.w600,
                              color: blackColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "${appLocale?.phoneNumber} : ",
                            style: customTextStyle(
                              size: 17,
                              fontWeight: FontWeight.w600,
                              color: purpleColor,
                            ),
                          ),
                          TextSpan(
                            text: phoneNumberController.text,
                            style: customTextStyle(
                              size: 17,
                              fontWeight: FontWeight.w600,
                              color: blackColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "${appLocale?.address} : ",
                            style: customTextStyle(
                              size: 17,
                              fontWeight: FontWeight.w600,
                              color: purpleColor,
                            ),
                          ),
                          TextSpan(
                            text: addressController.text,
                            style: customTextStyle(
                              size: 17,
                              fontWeight: FontWeight.w600,
                              color: blackColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
