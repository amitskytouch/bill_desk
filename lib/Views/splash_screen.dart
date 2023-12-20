import 'dart:async';
import 'package:bill_desk/Constants/color_const.dart';
import 'package:bill_desk/Constants/textstyle_const.dart';
import 'package:bill_desk/Utils/global_handler.dart';
import 'package:bill_desk/Views/bottomnavbar_screen.dart';
import 'package:bill_desk/Views/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;

  checkUser() {
    auth.currentUser == null
        ? navigatorPushReplace(context, LoginScreen())
        : navigatorPushReplace(context, const BottomNavBarScreen());
  }

  @override
  void initState() {
    Timer(
      const Duration(seconds: 3),
          () => checkUser(),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Image.asset(
              "assets/images/Group 36.png",
              fit: BoxFit.fill,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.62,
            child: Text(
              "Stock Management",
              style: customTextStyle(
                  size: 25, fontWeight: FontWeight.w900, color: whiteColor),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.69,
            child: Text(
              "This app will manage your inventory management",
              style: customTextStyle(color: whiteColor, size: 14),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.72,
            child: Text(
              "easy and enjoyable",
              style: customTextStyle(color: whiteColor, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}
