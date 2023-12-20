import 'package:bill_desk/Constants/color_const.dart';
import 'package:bill_desk/Constants/textstyle_const.dart';
import 'package:bill_desk/FirebaseServices/bill_service.dart';
import 'package:bill_desk/FirebaseServices/order_services.dart';
import 'package:bill_desk/Models/new_order_model.dart';
import 'package:bill_desk/Models/product_model.dart';
import 'package:bill_desk/Providers/report_provider.dart';
import 'package:bill_desk/Utils/global_handler.dart';
import 'package:bill_desk/Views/order_edit_screen.dart';
import 'package:bill_desk/Widgets/custom_appbar.dart';
import 'package:bill_desk/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class OrderDetailScreen extends StatelessWidget {
  OrderDetailScreen({
    super.key,
  });

  stockUpdate(NewOrdersModel orders) async {
    for (var i = 0; i < orders.products!.length; i++) {
      for (var j = 0; j < orders.products![i].product.length; j++) {
        await FirebaseFirestore.instance
            .collection("product")
            .doc(orders.products?[i].product[j].productId.toString())
            .get()
            .then((value) async {
          ProductModel product = ProductModel(
            id: orders.products![i].product[j].productId.toString(),
            productName: orders.products![i].product[j].productName.toString(),
            productPrice: orders.products![i].product[j].price.toString(),
            stock: (int.parse(value.data()!["stock"]) +
                    int.parse(
                        orders.products![i].product[j].quantity.toString()))
                .toString(),
          );

          await FirebaseFirestore.instance
              .collection("product")
              .doc(
                product.id.toString(),
              )
              .update({
            "stock": product.stock,
          });
        });
      }
    }
  }

  Future<void> _openDialog(BuildContext context, NewOrdersModel orders) {
    return showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(
              "${appLocale?.areYouSure}",
              style: customTextStyle(size: 18, fontWeight: FontWeight.w700),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  stockUpdate(orders);
                  OrderServices.deleteNewOrder(
                      docId: orders.orderId.toString());
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text(
                  "${appLocale?.yes}",
                  style: customTextStyle(size: 16, fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "${appLocale?.no}",
                  style: customTextStyle(size: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          );
        });
  }

  BillService billService = BillService();

  @override
  Widget build(BuildContext context) {
    final NewOrdersModel orders =
        Provider.of<ReportProvider>(context, listen: false).selectedOrderData!;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("${appLocale?.orderDetail}"),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15, top: 10),
              child: GestureDetector(
                onTap: () {
                  billService.generateBill(order: orders);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/pdf 1.png",
                      width: 20,
                      height: 20,
                      color: whiteColor,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "${appLocale?.print}",
                      style: customTextStyle(
                          color: whiteColor, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            FloatingActionButton(
              heroTag: "button1",
              backgroundColor: purpleColor,
              elevation: 0,
              onPressed: () => navigatorPushReplace(context, OrderEditScreen()),
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
              onPressed: () => _openDialog(context, orders),
              child: SvgPicture.asset(
                "assets/images/noun-delete-4778235 1.svg",
                width: 25,
                height: 25,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            CustomAppBar(
              date: "${orders.orderDate}",
              text: "${appLocale?.billNumber} ${orders.billNumber}",
            ),
            const SizedBox(height: 20),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.all(10),
              alignment: Alignment.center,
              color: purpleColor,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "${appLocale?.item}",
                      style: customTextStyle(
                          fontWeight: FontWeight.w600, color: whiteColor),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      "${appLocale?.quantity}",
                      style: customTextStyle(
                          fontWeight: FontWeight.w600, color: whiteColor),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      "${appLocale?.price}",
                      textAlign: TextAlign.center,
                      style: customTextStyle(
                          fontWeight: FontWeight.w600, color: whiteColor),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      "${appLocale?.amount}",
                      textAlign: TextAlign.center,
                      style: customTextStyle(
                          fontWeight: FontWeight.w600, color: whiteColor),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: orders.products?.length,
                itemBuilder: (context, index) {
                  final data = orders.products?[index];
                  return Column(
                    children: [
                      data!.category == null
                          ? SizedBox()
                          : Container(
                              width: MediaQuery.of(context).size.width,
                              height: 40,
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(
                                left: 10,
                                right: 10,
                                top: 10,
                              ),
                              color: purpleColor.withOpacity(0.7),
                              child: Text(
                                "${data.category}",
                                style: customTextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: whiteColor),
                              ),
                            ),
                      ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: data.product.length,
                          itemBuilder: (context, subIndex) {
                            final newData = data.product[subIndex];
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              height: 50,
                              margin: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                              ),
                              padding: const EdgeInsets.all(10),
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                border: BorderDirectional(
                                  bottom: BorderSide(color: purpleColor),
                                  start: BorderSide(color: purpleColor),
                                  end: BorderSide(color: purpleColor),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      "${newData.productName}",
                                      overflow: TextOverflow.ellipsis,
                                      style: customTextStyle(),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      "${newData.quantity}",
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: customTextStyle(),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      "${newData.price}",
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: customTextStyle(),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      "${newData.totalPrice}",
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: customTextStyle(),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
