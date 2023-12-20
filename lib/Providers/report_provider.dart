import 'package:bill_desk/Models/new_order_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class ReportProvider extends ChangeNotifier {
  DateTime selectedDate = DateTime.now();
  var format = intl.DateFormat("dd-MM-yyyy");
  NewOrdersModel? selectedOrderData;
  disposeData() {
    selectedDate = DateTime.now();
  }

  setSelectOrderData(NewOrdersModel order) {
    selectedOrderData = order;
    notifyListeners();
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
    }
    notifyListeners();
  }
}
