import 'dart:developer';

import 'package:bill_desk/Constants/color_const.dart';
import 'package:bill_desk/Constants/textstyle_const.dart';
import 'package:bill_desk/FirebaseServices/order_services.dart';
import 'package:bill_desk/Providers/accept_order_provider.dart';
import 'package:bill_desk/Widgets/custom_appbar.dart';
import 'package:bill_desk/Widgets/custom_snackbar.dart';
import 'package:bill_desk/Widgets/theme_button.dart';
import 'package:bill_desk/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;
import 'package:bill_desk/Models/new_order_model.dart' as newordermodel;

class AcceptOrderScreen extends StatefulWidget {
  const AcceptOrderScreen({super.key});

  @override
  State<AcceptOrderScreen> createState() => _AcceptOrderScreenState();
}

class _AcceptOrderScreenState extends State<AcceptOrderScreen> {
  TextEditingController customerController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  String? selectedCustomer;
  String? selectedCategory;
  String? customerId;
  String? customerName;
  var format = intl.DateFormat("dd-MM-yyyy");
  late AcceptOrderProvider providerAcceptOrder;

  @override
  void initState() {
    super.initState();
    providerAcceptOrder =
        Provider.of<AcceptOrderProvider>(context, listen: false);
    providerAcceptOrder.oninit();
    providerAcceptOrder.getCustomer();
    providerAcceptOrder.getCategory();

    providerAcceptOrder.getCount(FirebaseAuth.instance.currentUser!.uid);
    providerAcceptOrder.disposeData();
  }

  saveOrder(AcceptOrderProvider provider) async {
    if (selectedCustomer == null) {
      customSnackBar(context,
          color: Colors.red, message: "Select Customer Please");
    } else {
      List<newordermodel.AddCategoryItemModel> myData = [];
      for (var i = 0; i < provider.addCategoryList.length; i++) {
        List<Product> productList = provider.addCategoryList[i].product
            .where(
              (element) =>
                  element.productId != null &&
                  element.qty != null &&
                  element.qty! > 0 &&
                  element.name != null &&
                  element.name != "",
            )
            .toList();

        if (productList.isNotEmpty) {
          myData.add(
            newordermodel.AddCategoryItemModel(
              category: provider.addCategoryList[i].category,
              categoryId: provider.addCategoryList[i].categoryId,
              product: productList
                  .map((e) => newordermodel.Products(
                        category: provider.addCategoryList[i].category,
                        productName: e.name,
                        productId: e.productId,
                        quantity: e.qty,
                        price: e.price!.toDouble(),
                        totalPrice: e.totalPrice,
                        productStock: e.productStock,
                        updatedStock: e.updateStock,
                      ))
                  .toList(),
            ),
          );
        }
      }

      if (myData.isNotEmpty) {
        await OrderServices.addNewOrder(
          billNumber: provider.count,
          orderDate: format.format(provider.selectedDate),
          customerName: customerName.toString(),
          customerId: customerId.toString(),
          shopName: selectedCustomer.toString(),
          orderAmount: provider.totalAmount.toStringAsFixed(2),
          products: myData,
        );

        for (var i = 0; i < provider.addCategoryList.length; i++) {
          for (var j = 0; j < provider.addCategoryList[i].product.length; j++) {
            if (provider.addCategoryList[i].product[j].productId != null) {
              await FirebaseFirestore.instance
                  .collection("product")
                  .doc(provider.addCategoryList[i].product[j].productId
                      .toString())
                  .update({
                "stock": provider.addCategoryList[i].product[j].updateStock
                    .toString(),
              });
            }
          }
        }
        provider.updateCount(FirebaseAuth.instance.currentUser!.uid);
        if (context.mounted) {
          Navigator.pop(context);
        }
      } else {
        customSnackBar(context, color: Colors.red, message: "No Order Created");
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("${appLocale?.acceptOrder}"),
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 10, right: 20),
              child: GestureDetector(
                onTap: () => saveOrder(providerAcceptOrder),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      "assets/images/Vector (3).svg",
                      width: 22,
                      height: 22,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "${appLocale?.save}",
                      style: customTextStyle(
                          color: whiteColor,
                          size: 13,
                          fontWeight: FontWeight.w600),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        body:
            Consumer<AcceptOrderProvider>(builder: (context, provider, child) {
          return Column(
            children: [
              CustomAppBar(
                date: format.format(provider.selectedDate),
                changeDate: () => provider.selectDate(context),
                text: "Bill No. ${provider.count}",
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.67,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                            items: provider.customerList.map((e) {
                              return DropdownMenuItem<String>(
                                value: e.shopName,
                                child: Text(e.shopName.toString()),
                              );
                            }).toList(),
                            hint: Text(selectedCustomer ??
                                "${appLocale?.selectCustomer}"),
                            onChanged: (value) {
                              setState(() {
                                selectedCustomer = value.toString();
                                for (var i = 0;
                                    i < provider.customerList.length;
                                    i++) {
                                  if (selectedCustomer ==
                                      provider.customerList[i].shopName) {
                                    customerId = provider.customerList[i].id;
                                    customerName =
                                        provider.customerList[i].name;
                                  }
                                }
                              });
                            },
                            buttonStyleData: ButtonStyleData(
                              elevation: 0,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                border: Border.all(color: purpleColor),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            dropdownSearchData: DropdownSearchData(
                              searchController: customerController,
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
                                  controller: customerController,
                                  decoration: const InputDecoration(
                                      hintText: "Search here..."),
                                ),
                              ),
                            ),
                            onMenuStateChange: (isOpen) {
                              if (!isOpen) {
                                customerController.clear();
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: List.generate(
                          provider.addCategoryList.length,
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              children: [
                                DropdownButtonHideUnderline(
                                  child: DropdownButton2<String>(
                                    items: provider.categoryList.map((e) {
                                      return DropdownMenuItem<String>(
                                        value: e.category,
                                        child: Text(e.category.toString()),
                                      );
                                    }).toList(),
                                    hint: Text(provider
                                            .addCategoryList[index].category ??
                                        "${appLocale?.selectCategory}"),
                                    onChanged: (value) {
                                      if (provider.addCategoryList[index]
                                              .category ==
                                          null) {
                                        selectedCategory = value.toString();

                                        provider.setCategory(value!, index);
                                        provider.getProduct(
                                            value.toString(), index);
                                        provider.filterCategory();
                                        setState(() {});
                                      } else {
                                        showDialog<String>(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                            title: const Text('Alert!'),
                                            content: const Text(
                                                'Are you sure want to change category'),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, 'Cancel'),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context, 'ok');
                                                  selectedCategory =
                                                      value.toString();
                                                  provider.setCategory(
                                                      value!, index);
                                                  provider.getProduct(
                                                      value.toString(), index);
                                                  provider.filterCategory();
                                                  setState(() {});
                                                },
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    },
                                    buttonStyleData: ButtonStyleData(
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        color: purpleColor.withOpacity(0.2),
                                        border: Border.all(color: purpleColor),
                                        borderRadius: BorderRadius.circular(10),
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
                                Column(
                                  children: List.generate(
                                      provider.addCategoryList[index].product
                                          .length, (subIndex) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          DropdownButtonHideUnderline(
                                            child: DropdownButton2<String>(
                                              isExpanded: true,
                                              items: provider
                                                  .addCategoryList[index]
                                                  .productList
                                                  .map((e) {
                                                return DropdownMenuItem<String>(
                                                  value: e.productName,
                                                  child: Text(
                                                    e.productName.toString(),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                );
                                              }).toList(),
                                              hint: Text(provider
                                                      .addCategoryList[index]
                                                      .product[subIndex]
                                                      .name!
                                                      .isNotEmpty
                                                  ? provider
                                                      .addCategoryList[index]
                                                      .product[subIndex]
                                                      .name!
                                                  : "${appLocale?.selectProduct}"),
                                              onChanged: (value) {
                                                setState(() {
                                                  provider
                                                      .addCategoryList[index]
                                                      .product[subIndex]
                                                      .name = value.toString();
                                                });
                                                provider.getPrice(
                                                    value.toString(),
                                                    index,
                                                    subIndex);
                                                provider.filterProduct(index);
                                                provider
                                                    .addNewEmptyProduct(index);
                                              },
                                              buttonStyleData: ButtonStyleData(
                                                elevation: 0,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.45,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: purpleColor),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              dropdownSearchData:
                                                  DropdownSearchData(
                                                searchController: provider
                                                    .addCategoryList[index]
                                                    .product[subIndex]
                                                    .searchController,
                                                searchMatchFn:
                                                    (a, searchValue) {
                                                  return a.value
                                                      .toString()
                                                      .toLowerCase()
                                                      .contains(searchValue);
                                                },
                                                searchInnerWidgetHeight: 40,
                                                searchInnerWidget: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: TextFormField(
                                                    controller: provider
                                                        .addCategoryList[index]
                                                        .product[subIndex]
                                                        .searchController,
                                                    decoration:
                                                        const InputDecoration(
                                                            hintText:
                                                                "Search here..."),
                                                  ),
                                                ),
                                              ),
                                              onMenuStateChange: (isOpen) {
                                                if (!isOpen) {
                                                  provider
                                                      .addCategoryList[index]
                                                      .product[subIndex]
                                                      .searchController!
                                                      .clear();
                                                }
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 15),
                                          provider
                                                  .addCategoryList[index]
                                                  .product[subIndex]
                                                  .name!
                                                  .isNotEmpty
                                              ? Container(
                                                  height: 49,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.45,
                                                  padding:
                                                      const EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: purpleColor),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          provider
                                                              .decreaseQuantity(
                                                                  index,
                                                                  subIndex);
                                                        },
                                                        child: const Icon(
                                                          Icons
                                                              .remove_circle_outline,
                                                          size: 20,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 5),
                                                      provider
                                                                  .addCategoryList[
                                                                      index]
                                                                  .product
                                                                  .length >
                                                              subIndex
                                                          ? Text(provider
                                                              .addCategoryList[
                                                                  index]
                                                              .product[subIndex]
                                                              .qty
                                                              .toString())
                                                          : const SizedBox(),
                                                      const SizedBox(width: 5),
                                                      GestureDetector(
                                                        onTap: () {
                                                          provider
                                                              .increaseQuantity(
                                                                  index,
                                                                  context,
                                                                  subIndex);
                                                        },
                                                        child: const Icon(
                                                          Icons
                                                              .add_circle_outline,
                                                          size: 20,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 5),
                                                      // IconButton(
                                                      //   padding:
                                                      //       EdgeInsets.zero,
                                                      //   constraints:
                                                      //       const BoxConstraints(),
                                                      //   onPressed: () {
                                                      //     provider
                                                      //         .decreaseQuantity(
                                                      //             index,
                                                      //             subIndex);
                                                      //   },
                                                      //   icon: const Icon(
                                                      //     Icons
                                                      //         .remove_circle_outline,
                                                      //     size: 20,
                                                      //   ),
                                                      // ),

                                                      // IconButton(
                                                      //   padding:
                                                      //       EdgeInsets.zero,
                                                      //   constraints:
                                                      //       const BoxConstraints(),
                                                      //   onPressed: () {
                                                      //     provider
                                                      //         .increaseQuantity(
                                                      //             index,
                                                      //             context,
                                                      //             subIndex);
                                                      //   },
                                                      //   icon: const Icon(
                                                      //     Icons
                                                      //         .add_circle_outline,
                                                      //     size: 20,
                                                      //   ),
                                                      // ),
                                                      const Spacer(),
                                                      provider
                                                                  .addCategoryList[
                                                                      index]
                                                                  .product
                                                                  .length >
                                                              subIndex
                                                          ? Text(
                                                              provider
                                                                  .addCategoryList[
                                                                      index]
                                                                  .product[
                                                                      subIndex]
                                                                  .totalPrice
                                                                  .toString(),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            )
                                                          : const SizedBox(),
                                                    ],
                                                  ),
                                                )
                                              : const SizedBox(),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: purpleColor),
                          ),
                          child: Text(
                            "${appLocale?.total} : ${provider.totalAmount}",
                            style: customTextStyle(
                                fontWeight: FontWeight.w600,
                                color: purpleColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              ThemeButton(
                image: "assets/images/noun-add-product-2675922 1.svg",
                text: "${appLocale?.addCategory}",
                onTap: () {
                  bool isCatAvailable = provider.addNewCategory();
                  if (!isCatAvailable) {
                    customSnackBar(context,
                        color: Colors.red,
                        message: "No More Category Available");
                  }
                },
              ),
              const SizedBox(height: 5),
            ],
          );
        }),
      ),
    );
  }
}
