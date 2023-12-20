import 'package:bill_desk/Constants/color_const.dart';
import 'package:bill_desk/Constants/textstyle_const.dart';
import 'package:bill_desk/Models/new_order_model.dart';
import 'package:bill_desk/Providers/report_provider.dart';
import 'package:bill_desk/Utils/global_handler.dart';
import 'package:bill_desk/Views/accept_order_screen.dart';
import 'package:bill_desk/Views/order_detail_screen.dart';
import 'package:bill_desk/Views/view_report_screen.dart';
import 'package:bill_desk/Widgets/custom_appbar.dart';
import 'package:bill_desk/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  var format = intl.DateFormat("dd-MM-yyyy");

  @override
  void initState() {
    final providerReport = Provider.of<ReportProvider>(context, listen: false);
    providerReport.disposeData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${appLocale?.orders}"),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: purpleColor,
        elevation: 0,
        onPressed: () => navigatorPush(context, const AcceptOrderScreen()),
        child: SvgPicture.asset(
          "assets/images/noun-add-5852019 1.svg",
          width: 33,
          height: 33,
        ),
      ),
      body: Consumer<ReportProvider>(builder: (context, provider, child) {
        return Column(
          children: [
            CustomAppBar(
              date: format.format(provider.selectedDate),
              text: "${appLocale?.viewReports}",
              changeDate: () => provider.selectDate(context),
              onTap: () => navigatorPush(
                  context, ViewReportScreen(date: provider.selectedDate)),
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
                    flex: 3,
                    child: Text(
                      "${appLocale?.partyName}",
                      style: customTextStyle(
                          fontWeight: FontWeight.w600, color: whiteColor),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "${appLocale?.sales}",
                      style: customTextStyle(
                          fontWeight: FontWeight.w600, color: whiteColor),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      "${appLocale?.reports}",
                      textAlign: TextAlign.end,
                      style: customTextStyle(
                          fontWeight: FontWeight.w600, color: whiteColor),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("orders")
                    .where("orderDate",
                        isEqualTo: format.format(provider.selectedDate))
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.data!.docs.isEmpty) {
                    return Center(
                        child: Text(
                      "No Data Found...",
                      style: customTextStyle(
                          size: 16,
                          fontWeight: FontWeight.w600,
                          color: purpleColor),
                    ));
                  } else {
                    return ListView.builder(
                        itemCount: snapshot.data?.docs.length,
                        itemBuilder: (context, index) {
                          NewOrdersModel orders = NewOrdersModel.fromMap(
                            snapshot.data!.docs[index].data(),
                          );
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
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
                                  flex: 3,
                                  child: Text(
                                    "${orders.shopName}",
                                    style: customTextStyle(),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "${orders.orderAmount}",
                                    style: customTextStyle(),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: GestureDetector(
                                    onTap: () {
                                      Provider.of<ReportProvider>(context,
                                              listen: false)
                                          .setSelectOrderData(orders);
                                      navigatorPush(
                                          context, OrderDetailScreen());
                                    },
                                    child:
                                        Image.asset("assets/images/pdf 1.png"),
                                  ),
                                ),
                              ],
                            ),
                          );
                        });
                  }
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
