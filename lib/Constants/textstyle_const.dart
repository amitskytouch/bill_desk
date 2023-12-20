import 'package:bill_desk/Constants/color_const.dart';
import 'package:flutter/material.dart';

TextStyle customTextStyle(
    {FontWeight fontWeight = FontWeight.w500,
    double size = 15,
    Color color = blackColor}) {
  return TextStyle(
    fontWeight: fontWeight,
    fontSize: size,
    color: color,
  );
}
