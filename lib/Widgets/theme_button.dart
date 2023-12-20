import 'package:bill_desk/Constants/color_const.dart';
import 'package:bill_desk/Constants/textstyle_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


// ignore: must_be_immutable
class ThemeButton extends StatelessWidget {
  String? image, text;
  void Function()? onTap;

  ThemeButton({super.key, this.image, this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: purpleColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                "$image",
                width: 25,
                height: 25,
                colorFilter: const ColorFilter.mode(whiteColor, BlendMode.srcIn),
              ),
              const SizedBox(width: 15),
              Text(
                text.toString(),
                style: customTextStyle(
                    color: whiteColor, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
