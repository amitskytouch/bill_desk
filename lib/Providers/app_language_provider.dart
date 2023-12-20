import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage extends ChangeNotifier {

  Locale? languageCode;

  void changeLanguage(Locale type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(type == Locale("en")) {
      await prefs.setString("language_code", "en");
      languageCode = Locale("en");
      notifyListeners();
    } else {
      await prefs.setString("language_code", "gu");
      languageCode = Locale("gu");
      notifyListeners();
    }
  }




}