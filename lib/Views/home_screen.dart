import 'package:bill_desk/Constants/color_const.dart';
import 'package:bill_desk/Constants/textstyle_const.dart';
import 'package:bill_desk/Providers/home_provider.dart';
import 'package:bill_desk/Utils/global_handler.dart';
import 'package:bill_desk/Views/category_screen.dart';
import 'package:bill_desk/Views/customer_screen.dart';
import 'package:bill_desk/Views/product_screen.dart';
import 'package:bill_desk/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var format = intl.DateFormat("dd-MM-yyyy");

  @override
  void initState() {
    final providerHome = Provider.of<HomeProvider>(context, listen: false);
    providerHome.disposeData();
    providerHome.getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${appLocale?.reports}"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Consumer<HomeProvider>(builder: (context, provider, child) {
          return Column(
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${appLocale?.storeReports}",
                    style: customTextStyle(
                        size: 18,
                        fontWeight: FontWeight.w700,
                        color: blackColor),
                  ),
                  Text(
                    "${appLocale?.today}",
                    style: customTextStyle(color: greyColor),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 80,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: goldenColor.withOpacity(0.30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      "assets/images/noun-rupee-4782460 1.svg",
                      width: 40,
                      height: 40,
                    ),
                    const SizedBox(width: 40),
                    SizedBox(
                      width: 120,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${appLocale?.sales}",
                            style: customTextStyle(),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "₹ ${provider.todaySale.toStringAsFixed(2)}",
                            overflow: TextOverflow.ellipsis,
                            style: customTextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 110,
                      child: RichText(
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "${appLocale?.orders}  ",
                              style: customTextStyle(color: greyColor),
                            ),
                            TextSpan(
                              text: "${provider.todayOrder}",
                              style:
                                  customTextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  navigatorPush(context, ProductScreen());
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 80,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: greenColor.withOpacity(0.30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        "assets/images/Vector (2).svg",
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 40),
                      SizedBox(
                        width: 120,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${appLocale?.stockValue}",
                              style: customTextStyle(),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "₹ ${provider.stockValue}",
                              overflow: TextOverflow.ellipsis,
                              style:
                                  customTextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 110,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RichText(
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "${appLocale?.products}  ",
                                    style: customTextStyle(color: greyColor),
                                  ),
                                  TextSpan(
                                    text: "${provider.itemCount}",
                                    style: customTextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            RichText(
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "${appLocale?.stock}  ",
                                    style: customTextStyle(color: greyColor),
                                  ),
                                  TextSpan(
                                    text: "${provider.totalStock}",
                                    style: customTextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  navigatorPush(context, CustomerScreen());
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 80,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: pinkColor.withOpacity(0.30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        "assets/images/noun-view-1606941 1.svg",
                        width: 25,
                        height: 25,
                      ),
                      const SizedBox(width: 40),
                      SizedBox(
                        width: 120,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${appLocale?.customer}",
                              style: customTextStyle(),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "${provider.customerCount}",
                              overflow: TextOverflow.ellipsis,
                              style:
                                  customTextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  navigatorPush(context, CategoryScreen());
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 80,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: purpleColor.withOpacity(0.30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/images/search.png",
                        width: 40,
                        height: 40,
                        color: purpleColor,
                      ),
                      const SizedBox(width: 40),
                      SizedBox(
                        width: 120,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${appLocale?.category}",
                              style: customTextStyle(),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "${provider.categoryCount}",
                              overflow: TextOverflow.ellipsis,
                              style:
                                  customTextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
