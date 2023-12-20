import 'package:bill_desk/Constants/textstyle_const.dart';
import 'package:flutter/material.dart';

customSnackBar(BuildContext context,
    {required Color color, required String message}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        content: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
      message,
      style: customTextStyle(color: Colors.white),
    ),
        )),
  );
}
