import 'package:bill_desk/Models/new_order_model.dart';
import 'package:bill_desk/Constants/color_const.dart';
import 'package:bill_desk/Constants/textstyle_const.dart';
import 'package:bill_desk/FirebaseServices/order_services.dart';
import 'package:bill_desk/Providers/edit_order_provider.dart';
import 'package:bill_desk/Providers/report_provider.dart';
import 'package:bill_desk/Utils/global_handler.dart';
import 'package:bill_desk/Views/bottomnavbar_screen.dart';
import 'package:bill_desk/Views/order_detail_screen.dart';
import 'package:bill_desk/Widgets/custom_appbar.dart';
import 'package:bill_desk/Widgets/custom_snackbar.dart';
import 'package:bill_desk/Widgets/theme_button.dart';
import 'package:bill_desk/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

class OrderEditScreen extends StatefulWidget {
  const OrderEditScreen({
    super.key,
  });

  @override
  State<OrderEditScreen> createState() => _OrderEditScreenState();
}

class _OrderEditScreenState extends State<OrderEditScreen> {
  var format = intl.DateFormat("dd-MM-yyyy");
  late EditOrderProvider providerEditOrder;
  String? selectedCategory;
  TextEditingController categoryController = TextEditingController();

  editOrder(EditOrderProvider provider) async {
    List<AddCategoryItemModel> myData = [];

    for (var i = 0; i < provider.productData.length; i++) {
      List<Products> productList = provider.productData[i].product
          .where(
            (element) =>
                element.quantity != null &&
                element.quantity! > 0 &&
                element.productName != null &&
                element.productName != "",
          )
          .toList();
      if (productList.isNotEmpty) {
        myData.add(
          AddCategoryItemModel(
            category: provider.productData[i].category,
            categoryId: provider.productData[i].categoryId,
            product: productList
                .map((e) => Products(
                      category: provider.productData[i].category,
                      productName: e.productName,
                      productId: e.productId,
                      quantity: e.quantity,
                      price: e.price,
                      totalPrice: e.totalPrice,
                      productStock: e.productStock,
                      updatedStock: e.updatedStock,
                    ))
                .toList(),
            // product: productList,
          ),
        );
      }
    }
    if (myData.isNotEmpty) {
      await OrderServices.editNewOrder(
        billNumber: orders!.billNumber,
        orderId: orders!.orderId.toString(),
        orderDate: format.format(provider.selectedDate),
        customerName: orders!.customerName.toString(),
        customerId: orders!.customerId.toString(),
        shopName: orders!.shopName.toString(),
        orderAmount: provider.totalAmount.toStringAsFixed(2),
        products: myData,
      );

      for (var i = 0; i < provider.productData.length; i++) {
        for (var j = 0; j < provider.productData[i].product.length; j++) {
          if (provider.productData[i].product[j].productId != null) {
            await FirebaseFirestore.instance
                .collection("product")
                .doc(provider.productData[i].product[j].productId.toString())
                .update({
              "stock":
                  provider.productData[i].product[j].updatedStock.toString(),
            });
          }
        }
      }
    }

    if (provider.productData.isEmpty) {
      OrderServices.deleteNewOrder(docId: orders!.orderId.toString());
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const BottomNavBarScreen()),
            (route) => false);
      }
    } else {
      await FirebaseFirestore.instance
          .collection("orders")
          .doc(orders!.orderId.toString())
          .get()
          .then((value) {
        Provider.of<ReportProvider>(context, listen: false)
            .setSelectOrderData(NewOrdersModel.fromMap(value.data()!));
      });
      if (context.mounted) {
        navigatorPushReplace(context, OrderDetailScreen());
      }
    }
  }

  NewOrdersModel? orders;
  @override
  void initState() {
    orders =
        Provider.of<ReportProvider>(context, listen: false).selectedOrderData!;

    providerEditOrder = Provider.of<EditOrderProvider>(context, listen: false);
    providerEditOrder.disposeData();
    DateTime temp =
        intl.DateFormat("dd-MM-yyyy").parse(orders!.orderDate.toString());
    providerEditOrder.selectedDate = temp;

    providerEditOrder.addValueToController(orders!);
    providerEditOrder.getCategory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("${appLocale?.orderEdit}"),
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 10, right: 20),
              child: GestureDetector(
                onTap: () {
                  editOrder(providerEditOrder);
                },
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
        body: Consumer<EditOrderProvider>(
          builder: (context, provider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomAppBar(
                  isOrderScreen: true,
                  date: format.format(provider.selectedDate),
                  changeDate: () => provider.selectDate(context),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.67,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "${orders!.shopName}",
                              style: customTextStyle(
                                  size: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        provider.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : Column(
                                children: List.generate(
                                  provider.productData.length,
                                  (index) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Column(
                                      children: [
                                        DropdownButtonHideUnderline(
                                          child: DropdownButton2<String>(
                                            items:
                                                provider.categoryList.map((e) {
                                              return DropdownMenuItem<String>(
                                                value: e.category,
                                                child:
                                                    Text(e.category.toString()),
                                              );
                                            }).toList(),
                                            hint: Text(provider
                                                    .productData[index]
                                                    .category ??
                                                "${appLocale?.selectCategory}"),
                                            onChanged: (value) {
                                              if (provider.productData[index]
                                                      .category ==
                                                  null) {
                                                selectedCategory =
                                                    value.toString();

                                                provider.setCategory(
                                                    value!, index);
                                                provider.filterCategory();
                                                provider.getProduct(
                                                    value.toString(), index);

                                                setState(() {});
                                              } else {
                                                showDialog<String>(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) =>
                                                          AlertDialog(
                                                    title: const Text('Alert!'),
                                                    content: const Text(
                                                        'Are you sure want to change category'),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context,
                                                                'Cancel'),
                                                        child: const Text(
                                                            'Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context, 'ok');
                                                          selectedCategory =
                                                              value.toString();
                                                          provider.setCategory(
                                                              value!, index);
                                                          provider.getProduct(
                                                              value.toString(),
                                                              index);
                                                          provider
                                                              .filterCategory();
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              decoration: BoxDecoration(
                                                color: purpleColor
                                                    .withOpacity(0.2),
                                                border: Border.all(
                                                    color: purpleColor),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            dropdownSearchData:
                                                DropdownSearchData(
                                              searchController:
                                                  categoryController,
                                              searchMatchFn: (a, searchValue) {
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
                                                  controller:
                                                      categoryController,
                                                  decoration:
                                                      const InputDecoration(
                                                          hintText:
                                                              "Search here..."),
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
                                              provider.productData[index]
                                                  .product.length, (subIndex) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  DropdownButtonHideUnderline(
                                                    child:
                                                        DropdownButton2<String>(
                                                      isExpanded: true,
                                                      items: provider
                                                          .productData[index]
                                                          .productList!
                                                          .map((e) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: e.productName,
                                                          child: Text(
                                                            e.productName
                                                                .toString(),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        );
                                                      }).toList(),
                                                      hint: Text(provider
                                                              .productData[
                                                                  index]
                                                              .product[subIndex]
                                                              .productName!
                                                              .isNotEmpty
                                                          ? provider
                                                              .productData[
                                                                  index]
                                                              .product[subIndex]
                                                              .productName!
                                                          : "${appLocale?.selectProduct}"),
                                                      onChanged: (value) {
                                                        provider
                                                                .productData[index]
                                                                .product[subIndex]
                                                                .productName =
                                                            value.toString();
                                                        provider.getPrice(
                                                            value.toString(),
                                                            index,
                                                            subIndex);
                                                        provider.filterProduct(
                                                            index);
                                                        if (provider
                                                            .productData[index]
                                                            .productList!
                                                            .isNotEmpty) {
                                                          provider
                                                              .addNewEmptyProduct(
                                                                  index);
                                                        }
                                                      },
                                                      buttonStyleData:
                                                          ButtonStyleData(
                                                        elevation: 0,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 10),
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.45,
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              color:
                                                                  purpleColor),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                      ),
                                                      dropdownSearchData:
                                                          DropdownSearchData(
                                                        searchController: provider
                                                            .productData[index]
                                                            .product[subIndex]
                                                            .searchController,
                                                        searchMatchFn:
                                                            (a, searchValue) {
                                                          return a.value
                                                              .toString()
                                                              .toLowerCase()
                                                              .contains(
                                                                  searchValue);
                                                        },
                                                        searchInnerWidgetHeight:
                                                            40,
                                                        searchInnerWidget:
                                                            Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: TextFormField(
                                                            controller: provider
                                                                .productData[
                                                                    index]
                                                                .product[
                                                                    subIndex]
                                                                .searchController,
                                                            decoration:
                                                                const InputDecoration(
                                                                    hintText:
                                                                        "Search here..."),
                                                          ),
                                                        ),
                                                      ),
                                                      onMenuStateChange:
                                                          (isOpen) {
                                                        if (!isOpen) {
                                                          provider
                                                              .productData[
                                                                  index]
                                                              .product[subIndex]
                                                              .searchController!
                                                              .clear();
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                  const SizedBox(width: 15),
                                                  provider
                                                          .productData[index]
                                                          .product[subIndex]
                                                          .productName!
                                                          .isNotEmpty
                                                      ? Container(
                                                          height: 49,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.45,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5),
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                                color:
                                                                    purpleColor),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              // IconButton(
                                                              //   padding:
                                                              //       EdgeInsets
                                                              //           .zero,
                                                              //   constraints:
                                                              //       const BoxConstraints(),
                                                              //   onPressed: () {
                                                              //     provider.decreaseQuantity(
                                                              //         index,
                                                              //         subIndex);
                                                              //   },
                                                              //   icon:
                                                              //       const Icon(
                                                              //     Icons
                                                              //         .remove_circle_outline,
                                                              //     size: 20,
                                                              //   ),
                                                              // ),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  provider.decreaseQuantity(
                                                                      index,
                                                                      subIndex);
                                                                },
                                                                child:
                                                                    const Icon(
                                                                  Icons
                                                                      .remove_circle_outline,
                                                                  size: 20,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 5),
                                                              provider
                                                                          .productData[
                                                                              index]
                                                                          .product
                                                                          .length >
                                                                      subIndex
                                                                  ? Text(provider
                                                                      .productData[
                                                                          index]
                                                                      .product[
                                                                          subIndex]
                                                                      .quantity
                                                                      .toString())
                                                                  : const SizedBox(),
                                                              const SizedBox(
                                                                  width: 5),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  provider
                                                                      .increaseQuantity(
                                                                    index,
                                                                    subIndex,
                                                                    context,
                                                                  );
                                                                },
                                                                child:
                                                                    const Icon(
                                                                  Icons
                                                                      .add_circle_outline,
                                                                  size: 20,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 5),

                                                              // IconButton(
                                                              //   padding:
                                                              //       EdgeInsets
                                                              //           .zero,
                                                              //   constraints:
                                                              //       const BoxConstraints(),
                                                              //   onPressed: () {
                                                              //     provider
                                                              //         .increaseQuantity(
                                                              //       index,
                                                              //       subIndex,
                                                              //       context,
                                                              //     );
                                                              //   },
                                                              //   icon:
                                                              //       const Icon(
                                                              //     Icons
                                                              //         .add_circle_outline,
                                                              //     size: 20,
                                                              //   ),
                                                              // ),
                                                              const Spacer(),
                                                              provider
                                                                          .productData[
                                                                              index]
                                                                          .product
                                                                          .length >
                                                                      subIndex
                                                                  ? Text(
                                                                      provider
                                                                          .productData[
                                                                              index]
                                                                          .product[
                                                                              subIndex]
                                                                          .totalPrice!
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
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                ThemeButton(
                    image: "assets/images/noun-add-product-2675922 1.svg",
                    text: "${appLocale?.addCategory}",
                    onTap: () {
                      bool isCatAvaible = provider.addNewCategory();
                      if (!isCatAvaible) {
                        customSnackBar(context,
                            color: Colors.red,
                            message: "No More Category Available");
                      }
                    }),
                const SizedBox(height: 5),
              ],
            );
          },
        ),
      ),
    );
  }
}
