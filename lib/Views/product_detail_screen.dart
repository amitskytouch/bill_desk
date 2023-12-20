import 'dart:developer';
import 'dart:io';
import 'package:bill_desk/Constants/color_const.dart';
import 'package:bill_desk/Constants/textstyle_const.dart';
import 'package:bill_desk/FirebaseServices/product_services.dart';
import 'package:bill_desk/Models/product_model.dart';
import 'package:bill_desk/Providers/image_upload_provider.dart';
import 'package:bill_desk/Providers/product_detail_provider.dart';
import 'package:bill_desk/Widgets/custom_textfield.dart';
import 'package:bill_desk/Widgets/theme_button.dart';
import 'package:bill_desk/main.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  TextEditingController productNameController = TextEditingController();
  TextEditingController productPriceController = TextEditingController();
  TextEditingController productStockController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late int currentStock;
  List<int> temp = [0];

  void _addValueToController() {
    productNameController.text = "${widget.product.productName}";
    productPriceController.text = "${widget.product.productPrice}";
    // categoryController.text = "${widget.product.category}";
  }

  @override
  void initState() {
    final productDetailProvider =
        Provider.of<ProductDetailProvider>(context, listen: false);
    currentStock = int.parse(widget.product.stock.toString());
    productDetailProvider.updatedStock =
        int.parse(widget.product.stock.toString());
    productDetailProvider.productImageFile = null;
    productDetailProvider.productImageUrl = "";
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
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.8,
              maxChildSize: 0.9,
              builder: (_, controller) {
                return Consumer2<ProductDetailProvider, ImageUploadProvider>(
                    builder: (context, detail, provi, child) {
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
                            DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                items: provi.categoryList.map((e) {
                                  return DropdownMenuItem<String>(
                                    value: e.category,
                                    child: Text(e.category.toString()),
                                  );
                                }).toList(),
                                hint: Text(
                                  provi.selectedCategory == null
                                      ? categoryController.text.isEmpty ||
                                              categoryController.text == ""
                                          ? widget.product.category.toString()
                                          : categoryController.text
                                      : provi.selectedCategory.toString(),
                                ),
                                onChanged: (value) {
                                  provi.changeCategory(value.toString());
                                  provi.filterCategory();
                                  log("${provi.selectedCategory}");
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 155,
                                  child: CustomTextField(
                                    hint: "${appLocale?.stock}",
                                    controller: productStockController,
                                    keyBoardType: TextInputType.number,
                                    onChange: (val) {
                                      val != ""
                                          ? temp.add(int.parse(val))
                                          : temp.add(0);
                                      detail.updateStock(temp);
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 155,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${appLocale?.currentStock} : $currentStock",
                                        style: customTextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        "${appLocale?.updatedStock} : ${detail.updatedStock}",
                                        style: customTextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
                                    child: detail.productImageFile != null
                                        ? Image.file(
                                            File(detail.productImageFile!.path),
                                            fit: BoxFit.cover,
                                          )
                                        : widget.product.image != ""
                                            ? Image.network(
                                                "${widget.product.image}",
                                                fit: BoxFit.cover,
                                              )
                                            : const SizedBox(),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      detail.productImageUpload(
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
                                  ProductServices.editProduct(
                                    uid: widget.product.id.toString(),
                                    productName: productNameController.text,
                                    productPrice: productPriceController.text,
                                    stock: detail.updatedStock.toString(),
                                    image: detail.productImageUrl == ""
                                        ? widget.product.image.toString()
                                        : detail.productImageUrl,
                                    category: provi.selectedCategory == null
                                        ? categoryController.text.isEmpty ||
                                                categoryController.text == ""
                                            ? widget.product.category.toString()
                                            : categoryController.text
                                        : provi.selectedCategory.toString(),
                                  );
                                  currentStock = detail.updatedStock;
                                  productStockController.clear();
                                  temp = [0];
                                  Navigator.pop(context);
                                  categoryController.text =
                                      provi.selectedCategory == null
                                          ? widget.product.category.toString()
                                          : provi.selectedCategory.toString();

                                  setState(() {});
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                });
              },
            ),
          );
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
                  ProductServices.deleteProduct(
                      uid: widget.product.id.toString());
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
        title: Text("${appLocale?.productDetail}"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:
          Consumer<ImageUploadProvider>(builder: (context, p, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            FloatingActionButton(
              heroTag: "button1",
              backgroundColor: purpleColor,
              elevation: 0,
              onPressed: () {
                p.getAllCategory();
                _openBottomSheet(context);
              },
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
        );
      }),
      body:
          Consumer<ProductDetailProvider>(builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Center(
                child: provider.productImageUrl != ""
                    ? Image.network(
                        provider.productImageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      )
                    : widget.product.image != ""
                        ? Image.network(
                            "${widget.product.image}",
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            "assets/images/products.png",
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
                            text: "${appLocale?.categoryName} : ",
                            style: customTextStyle(
                              size: 17,
                              fontWeight: FontWeight.w600,
                              color: purpleColor,
                            ),
                          ),
                          TextSpan(
                            text: categoryController.text == "" ||
                                    categoryController.text.isEmpty
                                ? widget.product.category
                                : categoryController.text,
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
                            text: "${appLocale?.productName} : ",
                            style: customTextStyle(
                              size: 17,
                              fontWeight: FontWeight.w600,
                              color: purpleColor,
                            ),
                          ),
                          TextSpan(
                            text: productNameController.text,
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
                            text: "${appLocale?.productPrice} : ",
                            style: customTextStyle(
                              size: 17,
                              fontWeight: FontWeight.w600,
                              color: purpleColor,
                            ),
                          ),
                          TextSpan(
                            text: productPriceController.text,
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
                            text: "${appLocale?.productStock} : ",
                            style: customTextStyle(
                              size: 17,
                              fontWeight: FontWeight.w600,
                              color: purpleColor,
                            ),
                          ),
                          TextSpan(
                            text: "$currentStock",
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
