import 'dart:developer';
import 'dart:io';
import 'package:bill_desk/Providers/image_upload_provider.dart';
import 'package:bill_desk/Constants/color_const.dart';
import 'package:bill_desk/Constants/textstyle_const.dart';
import 'package:bill_desk/FirebaseServices/product_services.dart';
import 'package:bill_desk/Models/product_model.dart';
import 'package:bill_desk/Utils/global_handler.dart';
import 'package:bill_desk/Views/category_screen.dart';
import 'package:bill_desk/Views/product_detail_screen.dart';
import 'package:bill_desk/Widgets/custom_textfield.dart';
import 'package:bill_desk/Widgets/theme_button.dart';
import 'package:bill_desk/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class ProductScreen extends StatefulWidget {
  ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  TextEditingController productNameController = TextEditingController();
  TextEditingController productPriceController = TextEditingController();
  TextEditingController productStockController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _clearController({required ImageUploadProvider provider}) {
    productNameController.clear();
    productPriceController.clear();
    productStockController.clear();
    categoryController.clear();
    provider.productImageFile = null;
    provider.productImageUrl = "";
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
                builder: (_, scrollController) {
                  return GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: Container(
                      padding:
                          const EdgeInsets.only(left: 10, right: 10, top: 30),
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          shrinkWrap: true,
                          controller: scrollController,
                          children: [
                            DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                items: provider.categoryList.map((e) {
                                  return DropdownMenuItem<String>(
                                    value: e.category,
                                    child: Text(e.category.toString()),
                                  );
                                }).toList(),
                                hint: Text(provider.selectedCategory ??
                                    "Select Category"),
                                onChanged: (value) {
                                  provider.changeCategory(value.toString());
                                  provider.filterCategory();
                                  log("${provider.selectedCategory}");
                                },
                                buttonStyleData: ButtonStyleData(
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: purpleColor),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                dropdownSearchData: DropdownSearchData(
                                  searchController: categoryController,
                                  searchMatchFn: (a, searchValue) {
                                    return a.value
                                        .toString()
                                        .toLowerCase()
                                        .contains(searchValue);
                                  },
                                  searchInnerWidgetHeight: 40,
                                  searchInnerWidget: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      controller: categoryController,
                                      decoration: const InputDecoration(
                                          hintText: "Search here..."),
                                    ),
                                  ),
                                ),
                                onMenuStateChange: (isOpen) {
                                  if (!isOpen) {
                                    categoryController.clear();
                                  }
                                },
                              ),
                            ),
                           
                            // CustomTextField(
                            //   hint: "${appLocale?.category}",
                            //   controller: categoryController,
                            //   validator: (String? value) {
                            //     if (value!.isEmpty || value == "") {
                            //       return "${appLocale?.validator}";
                            //     } else {
                            //       return null;
                            //     }
                            //   },
                            // ),
                            const SizedBox(height: 10),
                            CustomTextField(
                              hint: "${appLocale?.productName}",
                              controller: productNameController,
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
                              hint: "${appLocale?.price}",
                              controller: productPriceController,
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
                              hint: "${appLocale?.stock}",
                              controller: productStockController,
                              keyBoardType: TextInputType.number,
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
                                    child: provider.productImageFile != null
                                        ? Image.file(
                                            File(provider
                                                .productImageFile!.path),
                                            fit: BoxFit.cover,
                                          )
                                        : const SizedBox(),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        provider.productImageUpload(context),
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
                              image:
                                  "assets/images/noun-add-product-2675922 1.svg",
                              text: "${appLocale?.addProduct}",
                              onTap: () async {
                                if (_formKey.currentState!.validate()) {
                                  await ProductServices.addProduct(
                                    productName: productNameController.text,
                                    productPrice: productPriceController.text,
                                    stock: productStockController.text,
                                    image: provider.productImageUrl,
                                    category:
                                        provider.selectedCategory.toString(),
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
        title: Text("${appLocale?.products}"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10, top: 5),
            child: GestureDetector(
              onTap: () {
                navigatorPush(context, CategoryScreen());
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/search.png",
                    width: 22,
                    height: 22,
                    color: whiteColor,
                  ),
                  Text(appLocale!.addCategory),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton:
          Consumer<ImageUploadProvider>(builder: (context, prov, child) {
        return FloatingActionButton(
          backgroundColor: purpleColor,
          elevation: 0,
          onPressed: () {
            prov.getAllCategory();
            _openBottomSheet(context);
          },
          child: SvgPicture.asset(
            "assets/images/noun-add-5852019 1.svg",
            width: 33,
            height: 33,
          ),
        );
      }),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("product")
              .orderBy("category", descending: false)
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
                  ProductModel product = ProductModel.fromMap(
                      data.docs[index].data() as Map<String, dynamic>);
                  return Card(
                    margin: const EdgeInsets.only(top: 10),
                    elevation: 1,
                    shape: OutlineInputBorder(
                      borderSide: const BorderSide(color: purpleColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: SizedBox(
                        width: 40,
                        height: 40,
                        child: product.image != ""
                            ? Image.network(
                                "${product.image}",
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                "assets/images/products.png",
                                width: 40,
                                height: 40,
                              ),
                      ),
                      title: Text(
                        "${product.productName}",
                        overflow: TextOverflow.ellipsis,
                        style: customTextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        "${appLocale?.stock}. ${product.stock}",
                        style: customTextStyle(),
                      ),
                      trailing: SizedBox(
                        width: 130,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 110,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${product.category}",
                                    overflow: TextOverflow.ellipsis,
                                    style: customTextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    "Rs. ${product.productPrice}",
                                    style: customTextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
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
                        ProductDetailScreen(product: product),
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
