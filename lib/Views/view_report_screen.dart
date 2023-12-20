import 'package:bill_desk/Constants/color_const.dart';
import 'package:bill_desk/Constants/textstyle_const.dart';
import 'package:bill_desk/FirebaseServices/bill_service.dart';
import 'package:bill_desk/Providers/view_report_provider.dart';
import 'package:bill_desk/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;

// ignore: must_be_immutable
class ViewReportScreen extends StatefulWidget {
  DateTime date;

  ViewReportScreen({super.key, required this.date});

  @override
  State<ViewReportScreen> createState() => _ViewReportScreenState();
}

class _ViewReportScreenState extends State<ViewReportScreen> {
  var format = intl.DateFormat("dd-MM-yyyy");
  BillService service = BillService();

  Widget dateWidget(ViewReportProvider provider) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 45,
      child: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 20,
            color: purpleColor,
          ),
          Positioned(
            bottom: 0,
            left: 20,
            child: GestureDetector(
              onTap: () async {
                await provider.selectDate(context);
                provider.getData(date: format.format(provider.selectedDate));
              },
              child: Container(
                width: 115,
                height: 45,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: purpleColor),
                ),
                child: Text(
                  format.format(provider.selectedDate),
                  style: customTextStyle(
                      color: purpleColor, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 20,
            child: GestureDetector(
              onTap: () => service.generateReport(provider: provider),
              child: Container(
                width: 115,
                height: 45,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: purpleColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "${appLocale?.print}",
                      style: customTextStyle(
                          color: purpleColor, fontWeight: FontWeight.w600),
                    ),
                    Image.asset(
                      "assets/images/pdf 1.png",
                      width: 25,
                      height: 25,
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    final viewReportProvider =
        Provider.of<ViewReportProvider>(context, listen: false);
    viewReportProvider.selectedDate = widget.date;
    viewReportProvider.getData(
        date: format.format(viewReportProvider.selectedDate));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("${appLocale?.viewReport}"),
        ),
        body: Consumer<ViewReportProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                dateWidget(provider),
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
                          overflow: TextOverflow.ellipsis,
                          style: customTextStyle(
                              fontWeight: FontWeight.w600, color: whiteColor),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          "${appLocale?.quantity}",
                          textAlign: TextAlign.center,
                          style: customTextStyle(
                              fontWeight: FontWeight.w600, color: whiteColor),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: provider.productData.isEmpty
                      ? Center(
                          child: Text(
                            "No Data Found...",
                            style: customTextStyle(
                                size: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: provider.productData.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                provider.productData[index].category == null
                                    ? SizedBox()
                                    : Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 40,
                                        alignment: Alignment.center,
                                        margin: EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                          top: 10,
                                        ),
                                        color: purpleColor.withOpacity(0.7),
                                        child: Text(
                                          "${provider.productData[index].category}",
                                          style: customTextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: whiteColor),
                                        ),
                                      ),
                                ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: provider
                                        .productData[index].product.length,
                                    itemBuilder: (context, subIndex) {
                                      return Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 50,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        padding: const EdgeInsets.all(10),
                                        alignment: Alignment.center,
                                        decoration: const BoxDecoration(
                                          border: BorderDirectional(
                                            bottom:
                                                BorderSide(color: purpleColor),
                                            start:
                                                BorderSide(color: purpleColor),
                                            end: BorderSide(color: purpleColor),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                "${provider.productData[index].product[subIndex].productName}",
                                                style: customTextStyle(),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Text(
                                                "${provider.productData[index].product[subIndex].quantity}",
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
                          }),
                ),
              ],
            );
          },
        ),
        // body: Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        //   child: Consumer<ViewReportProvider>(
        //     builder: (context, provider, child) {
        //       return Column(
        //         children: [
        //           GestureDetector(
        //             onTap: () async {
        //               await provider.selectDate(context);
        //               provider.getData(
        //                   date: format.format(provider.selectedDate));
        //             },
        //             child: Container(
        //               width: MediaQuery.of(context).size.width,
        //               height: 45,
        //               alignment: Alignment.center,
        //               color: Colors.grey[300],
        //               padding: const EdgeInsets.symmetric(horizontal: 10),
        //               child: Row(
        //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                 children: [
        //                   Text(format.format(provider.selectedDate)),
        //                   Text("Select Date", style: customTextStyle()),
        //                 ],
        //               ),
        //             ),
        //           ),
        //           Expanded(
        //             child: provider.productData.isEmpty
        //                 ? Center(
        //                     child: Text(
        //                       "No Data Found...",
        //                       style: customTextStyle(
        //                           size: 16,
        //                           fontWieght: FontWeight.bold,
        //                           color: Colors.grey),
        //                     ),
        //                   )
        //                 : ListView.builder(
        //                     itemCount: provider.productData.length,
        //                     itemBuilder: (context, index) {
        //                       Map<String, dynamic> data =
        //                           provider.productData[index];
        //                       return Padding(
        //                         padding: const EdgeInsets.only(top: 10),
        //                         child: Card(
        //                           elevation: 2,
        //                           shape: RoundedRectangleBorder(
        //                             borderRadius: BorderRadius.circular(5),
        //                           ),
        //                           child: ListTile(
        //                             leading: Text(
        //                               "${data["productName"]}",
        //                               style: customTextStyle(),
        //                             ),
        //                             trailing: Text(
        //                               "${data["quantity"]}",
        //                               style: customTextStyle(),
        //                             ),
        //                           ),
        //                         ),
        //                       );
        //                     }),
        //           ),
        //         ],
        //       );
        //     },
        //   ),
        // ),
      ),
    );
  }
}
