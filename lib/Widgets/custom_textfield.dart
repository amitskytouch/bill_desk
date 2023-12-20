import 'package:bill_desk/Constants/color_const.dart';
import 'package:bill_desk/Constants/textstyle_const.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomTextField extends StatelessWidget {
  TextEditingController? controller;
  TextInputType? keyBoardType;
  String? hint;
  void Function(String)? onChange;
  String? Function(String?)? validator;
  CustomTextField({
    super.key,
    this.controller,
    this.keyBoardType,
    this.hint,
    this.onChange,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      onChanged: onChange,
      controller: controller,
      keyboardType: keyBoardType,
      decoration: InputDecoration(
        isDense: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: purpleColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: purpleColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        labelText: hint,
        hintStyle: customTextStyle(),
      ),
    );
  }
}
