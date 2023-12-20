import 'package:bill_desk/Models/new_order_model.dart';
import 'package:bill_desk/Providers/view_report_provider.dart';
import 'package:bill_desk/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;

class BillService {
  FirebaseAuth auth = FirebaseAuth.instance;
  var format = intl.DateFormat("dd-MM-yyyy");

  generateReport({required ViewReportProvider provider}) async {
    var data =
        await rootBundle.load("assets/fonts/NotoSerifGujarati-Regular.ttf");
    var font = p.Font.ttf(data);
    final pdf = p.Document();
    final outPut = await getTemporaryDirectory();
    final file =
        File("${outPut.path}/${format.format(provider.selectedDate)}.pdf");

    final headers = <p.Text>[
      p.Text("${appLocale?.item}", style: p.TextStyle(font: font)),
      p.Text("${appLocale?.quantity}", style: p.TextStyle(font: font)),
    ];

    List<List<dynamic>> dataList = [];
    for (int i = 0; i < provider.productData.length; i++) {
      var temp = provider.productData[i].product.map((e) {
        return <p.Text>[
          p.Text("${e.productName}", style: p.TextStyle(font: font)),
          p.Text("${e.quantity}", style: p.TextStyle(font: font)),
        ];
      }).toList();
      dataList.addAll(temp);
    }

    pdf.addPage(
      p.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const p.EdgeInsets.all(10),
        crossAxisAlignment: p.CrossAxisAlignment.center,
        build: (p.Context context) {
          return [
            p.Align(
              alignment: p.Alignment.topRight,
              child: p.Text(
                "${appLocale?.date} : ${format.format(provider.selectedDate)}",
                style: p.TextStyle(
                    font: font, fontSize: 20, fontWeight: p.FontWeight.bold),
              ),
            ),
            p.SizedBox(height: 20),
            p.Container(
              width: double.maxFinite,
              height: 40,
              padding: const p.EdgeInsets.all(10),
              margin: const p.EdgeInsets.only(bottom: 5),
              alignment: p.Alignment.center,
              decoration: const p.BoxDecoration(
                color: PdfColors.grey,
                border: p.Border(
                  top: p.BorderSide(color: PdfColors.grey),
                  bottom: p.BorderSide(color: PdfColors.grey),
                  left: p.BorderSide(color: PdfColors.grey),
                  right: p.BorderSide(color: PdfColors.grey),
                ),
              ),
              child: p.Row(
                crossAxisAlignment: p.CrossAxisAlignment.center,
                children: [
                  p.Expanded(
                    flex: 2,
                    child: p.Text(
                      appLocale!.item,
                      style: p.TextStyle(
                        font: font,
                        fontSize: 18,
                        fontWeight: p.FontWeight.bold,
                      ),
                    ),
                  ),
                  p.Expanded(
                    flex: 1,
                    child: p.Text(
                      appLocale!.quantity,
                      textAlign: p.TextAlign.center,
                      style: p.TextStyle(
                        font: font,
                        fontSize: 18,
                        fontWeight: p.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            p.ListView.builder(
              itemCount: provider.productData.length,
              itemBuilder: (context, index) {
                return p.Column(
                  children: [
                    provider.productData[index].category == null
                        ? p.SizedBox()
                        : p.Container(
                            width: double.maxFinite,
                            height: 40,
                            alignment: p.Alignment.center,
                            decoration: const p.BoxDecoration(
                              color: PdfColors.grey,
                              border: p.Border(
                                top: p.BorderSide(color: PdfColors.grey),
                                bottom: p.BorderSide(color: PdfColors.grey),
                                left: p.BorderSide(color: PdfColors.grey),
                                right: p.BorderSide(color: PdfColors.grey),
                              ),
                            ),
                            child: p.Text(
                              "${provider.productData[index].category}",
                              softWrap: true,
                              style: p.TextStyle(
                                font: font,
                                fontSize: 18,
                                fontWeight: p.FontWeight.bold,
                              ),
                            ),
                          ),
                    p.ListView.builder(
                      itemCount: provider.productData[index].product.length,
                      itemBuilder: (context, subIndex) {
                        return p.Container(
                          width: double.maxFinite,
                          height: 40,
                          padding: const p.EdgeInsets.all(10),
                          alignment: p.Alignment.center,
                          decoration: const p.BoxDecoration(
                            border: p.Border(
                              top: p.BorderSide(color: PdfColors.grey),
                              bottom: p.BorderSide(color: PdfColors.grey),
                              left: p.BorderSide(color: PdfColors.grey),
                              right: p.BorderSide(color: PdfColors.grey),
                            ),
                          ),
                          child: p.Row(
                            crossAxisAlignment: p.CrossAxisAlignment.center,
                            children: [
                              p.Expanded(
                                flex: 2,
                                child: p.Text(
                                  "${provider.productData[index].product[subIndex].productName}",
                                  softWrap: true,
                                  style: p.TextStyle(
                                    font: font,
                                    fontSize: 16,
                                    fontWeight: p.FontWeight.bold,
                                  ),
                                ),
                              ),
                              p.Expanded(
                                flex: 1,
                                child: p.Text(
                                  "${provider.productData[index].product[subIndex].quantity}",
                                  textAlign: p.TextAlign.center,
                                  style: p.TextStyle(
                                    font: font,
                                    fontSize: 16,
                                    fontWeight: p.FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            // p.TableHelper.fromTextArray(
            //   headers: headers,
            //   data: dataList,
            //   headerAlignments: {
            //     0: p.Alignment.centerLeft,
            //     1: p.Alignment.center,
            //   },
            //   cellAlignments: {
            //     0: p.Alignment.centerLeft,
            //     1: p.Alignment.center,
            //   },
            //   headerStyle:
            //       p.TextStyle(font: font, fontWeight: p.FontWeight.bold),
            //   headerDecoration: const p.BoxDecoration(color: PdfColors.grey),
            // ),
          ];
        },
      ),
    );
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
  }

  generateBill({required NewOrdersModel order}) async {
    Map<String, dynamic> userdata = {};
    Map<String, dynamic> customerData = {};
    await FirebaseFirestore.instance
        .collection("users")
        .where("id", isEqualTo: auth.currentUser?.uid)
        .get()
        .then((value) {
      userdata = value.docs[0].data();
    });
    await FirebaseFirestore.instance
        .collection("customer")
        .where("id", isEqualTo: order.customerId)
        .get()
        .then((value) {
      customerData = value.docs[0].data();
    });

    var data =
        await rootBundle.load("assets/fonts/NotoSerifGujarati-Regular.ttf");
    var font = p.Font.ttf(data);
    final pdf = p.Document();
    final outPut = await getTemporaryDirectory();
    final file =
        File("${outPut.path}/${order.shopName}-${order.billNumber}.pdf");

    final headers = <p.Text>[
      p.Text("Sr.", style: p.TextStyle(font: font)),
      p.Text("Item", style: p.TextStyle(font: font)),
      p.Text("Qty", style: p.TextStyle(font: font)),
      p.Text("Price", style: p.TextStyle(font: font)),
      p.Text("Amount", style: p.TextStyle(font: font)),
    ];
    int index = 0;
    List<List<dynamic>> dataList = [];
    for (int i = 0; i < order.products!.length; i++) {
      var temp = order.products![i].product.map((e) {
        index++;
        return <p.Text>[
          p.Text("$index", style: p.TextStyle(font: font)),
          p.Text("${e.productName}", style: p.TextStyle(font: font)),
          p.Text("${e.quantity}", style: p.TextStyle(font: font)),
          p.Text("${e.price}", style: p.TextStyle(font: font)),
          p.Text("${e.totalPrice}", style: p.TextStyle(font: font)),
        ];
      }).toList();
      dataList.addAll(temp);
    }

    pdf.addPage(
      p.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const p.EdgeInsets.all(10),
          crossAxisAlignment: p.CrossAxisAlignment.center,
          build: (p.Context context) {
            return [
              p.Text(
                "${userdata["businessName"]}",
                style: p.TextStyle(
                    font: font, fontSize: 25, fontWeight: p.FontWeight.bold),
              ),
              p.Text(
                "${userdata["address"]}",
                style: p.TextStyle(
                    font: font, fontSize: 15, fontWeight: p.FontWeight.bold),
              ),
              p.Text(
                "${userdata["name"]}, Mobile : ${userdata["phoneNumber"]}",
                style: p.TextStyle(
                    font: font, fontSize: 15, fontWeight: p.FontWeight.bold),
              ),
              p.Divider(height: 20),
              p.Row(
                mainAxisAlignment: p.MainAxisAlignment.spaceBetween,
                children: [
                  p.Expanded(
                    flex: 2,
                    child: p.Container(
                      child: p.Column(
                        crossAxisAlignment: p.CrossAxisAlignment.start,
                        children: [
                          p.Text(
                            "${appLocale?.shopName} : ${order.shopName}",
                            style: p.TextStyle(
                              font: font,
                              fontSize: 15,
                              fontWeight: p.FontWeight.bold,
                            ),
                          ),
                          p.Text(
                            "${appLocale?.address} : ${customerData["address"]}",
                            style: p.TextStyle(
                              font: font,
                              fontSize: 15,
                              fontWeight: p.FontWeight.bold,
                            ),
                          ),
                          p.Text(
                            "${appLocale?.phoneNumber} : ${customerData["phone_number"]}",
                            style: p.TextStyle(
                              font: font,
                              fontSize: 15,
                              fontWeight: p.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  p.Expanded(
                    flex: 1,
                    child: p.Container(
                      child: p.Column(
                        crossAxisAlignment: p.CrossAxisAlignment.end,
                        children: [
                          p.Text(
                            "${appLocale?.date} : ${order.orderDate}",
                            style: p.TextStyle(
                              font: font,
                              fontSize: 15,
                              fontWeight: p.FontWeight.bold,
                            ),
                          ),
                          p.Text(
                            "${appLocale?.pBillNumber} ${order.billNumber}",
                            style: p.TextStyle(
                              font: font,
                              fontSize: 15,
                              fontWeight: p.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              p.Divider(height: 20),
              p.TableHelper.fromTextArray(
                headers: headers,
                data: dataList,
                headerAlignments: {
                  0: p.Alignment.center,
                  1: p.Alignment.center,
                  2: p.Alignment.center,
                  3: p.Alignment.center,
                  4: p.Alignment.center,
                },
                cellAlignments: {
                  0: p.Alignment.center,
                  1: p.Alignment.centerLeft,
                  2: p.Alignment.center,
                  3: p.Alignment.center,
                  4: p.Alignment.center,
                },
                headerStyle:
                    p.TextStyle(font: font, fontWeight: p.FontWeight.bold),
                headerDecoration: const p.BoxDecoration(color: PdfColors.grey),
              ),
              p.Spacer(),
              p.Divider(height: 20),
              p.Align(
                alignment: p.Alignment.bottomRight,
                child: p.Text(
                  "${appLocale?.total} : ${order.orderAmount}",
                  style: p.TextStyle(
                      font: font, fontSize: 20, fontWeight: p.FontWeight.bold),
                ),
              ),
              p.Divider(height: 20),
              p.Row(
                crossAxisAlignment: p.CrossAxisAlignment.end,
                mainAxisAlignment: p.MainAxisAlignment.spaceBetween,
                children: [
                  p.Expanded(
                    flex: 2,
                    child: p.Column(
                      crossAxisAlignment: p.CrossAxisAlignment.start,
                      children: [
                        p.Text(
                          "- ${appLocale?.warning}",
                          style: p.TextStyle(font: font, fontSize: 12),
                        ),
                        p.Text(
                          "- ${appLocale?.exchange}",
                          style: p.TextStyle(font: font, fontSize: 12),
                        ),
                        p.Text(
                          "- ${appLocale?.delevery}",
                          style: p.TextStyle(font: font, fontSize: 12),
                        ),
                        p.Text(
                          "- ${appLocale?.bakiBill}",
                          style: p.TextStyle(font: font, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  p.Expanded(
                    flex: 1,
                    child: p.Column(
                      crossAxisAlignment: p.CrossAxisAlignment.end,
                      children: [
                        p.Divider(height: 10),
                        p.Text(
                          "${appLocale?.authorised}",
                          style: p.TextStyle(
                              font: font,
                              fontSize: 15,
                              fontWeight: p.FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ];
          }),
    );
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
  }
}
