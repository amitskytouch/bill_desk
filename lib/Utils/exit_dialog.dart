import 'package:bill_desk/Constants/color_const.dart';
import 'package:bill_desk/Constants/textstyle_const.dart';
import 'package:bill_desk/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

exitDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(
            "${appLocale?.exitDialog}",
            style: customTextStyle(
                size: 18, fontWeight: FontWeight.bold, color: purpleColor),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: ElevatedButton(
                style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(purpleColor)),
                onPressed: () => SystemNavigator.pop(),
                child: Text(
                  "${appLocale?.yes}",
                  style: customTextStyle(
                      size: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: ElevatedButton(
                style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(purpleColor)),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "${appLocale?.no}",
                  style: customTextStyle(
                      size: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      });
}
