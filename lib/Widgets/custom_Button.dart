import 'package:bill_desk/Constants/color_const.dart';
import 'package:bill_desk/Constants/textstyle_const.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomButton extends StatelessWidget {
  String? text;
  void Function()? onTap;

  CustomButton({super.key, this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Container(
          width: 170,
          height: 50,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: purpleColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text("$text",
            style: customTextStyle(
                size: 17,
                color: whiteColor, fontWeight: FontWeight.w600),),
        ),
      ),
    );
  }
}
