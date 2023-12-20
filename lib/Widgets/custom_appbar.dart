import 'package:bill_desk/Constants/color_const.dart';
import 'package:bill_desk/Constants/textstyle_const.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomAppBar extends StatelessWidget {
  final String? date, text;
  void Function()? changeDate, onTap;
  bool isOrderScreen;
  CustomAppBar(
      {super.key,
      this.date,
      this.text,
      this.changeDate,
      this.onTap,
      this.isOrderScreen = false});

  @override
  Widget build(BuildContext context) {
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
              onTap: changeDate,
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
                  date ?? "",
                  style: customTextStyle(
                      color: purpleColor, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          isOrderScreen
              ? const SizedBox()
              : Positioned(
                  bottom: 0,
                  right: 20,
                  child: GestureDetector(
                    onTap: onTap,
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
                        text ?? "",
                        style: customTextStyle(
                            color: purpleColor, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
