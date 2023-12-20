import 'package:bill_desk/Models/user_model.dart';
import 'package:bill_desk/Utils/global_handler.dart';
import 'package:bill_desk/Views/bottomnavbar_screen.dart';
import 'package:bill_desk/Widgets/custom_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginService {
  static FirebaseFirestore fireStore = FirebaseFirestore.instance;
  static FirebaseAuth auth = FirebaseAuth.instance;

  static editUser({
    required String? id,
    required String? businessName,
    required String? name,
    required String? phoneNumber,
    required String? address,
  }) async {
    Map<String, dynamic> user = {
      "businessName": businessName ?? "",
      "name": name ?? "",
      "phoneNumber": phoneNumber ?? "",
      "address": address ?? "",
    };
    await fireStore.collection("users").doc(id).update(user);
  }

  static loginUser(BuildContext context,
      {required String email, required String password}) async {
    try {
      final credential = await auth.signInWithEmailAndPassword(
          email: email, password: password);

      if (credential.user != null) {
        QuerySnapshot snap = await fireStore
            .collection("users")
            .where("id", isEqualTo: credential.user!.uid)
            .get();
        if (snap.docs.isEmpty) {
          UserModel newUser = UserModel(
            id: credential.user?.uid,
            businessName: "",
            name: "",
            phoneNumber: "",
            address: "",
            email: email,
            password: password,
            logo: "",
            billNo: 1,
          );

          await fireStore
              .collection("users")
              .doc(credential.user?.uid)
              .set(newUser.toMap());
        }
        if (context.mounted) {
          customSnackBar(context,
              color: Colors.green, message: "Login Successfull");
        }
        if (context.mounted) {
          navigatorPushReplace(context, BottomNavBarScreen());
        }
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        customSnackBar(context, color: Colors.redAccent, message: e.code);
      }
    }
  }
}
