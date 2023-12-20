import 'package:bill_desk/Constants/color_const.dart';
import 'package:bill_desk/Constants/textstyle_const.dart';
import 'package:bill_desk/FirebaseServices/login_service.dart';
import 'package:bill_desk/Providers/app_language_provider.dart';
import 'package:bill_desk/Utils/global_handler.dart';
import 'package:bill_desk/Views/login_screen.dart';
import 'package:bill_desk/Widgets/custom_textfield.dart';
import 'package:bill_desk/Widgets/custom_Button.dart';
import 'package:bill_desk/Widgets/custom_snackbar.dart';
import 'package:bill_desk/Widgets/theme_button.dart';
import 'package:bill_desk/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  TextEditingController businessNameController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController currentPassController = TextEditingController();
  TextEditingController newPassController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  FirebaseAuth auth = FirebaseAuth.instance;

  changePassDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            titlePadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Container(
              padding: const EdgeInsets.all(10),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      hint: "${appLocale?.currentPass}",
                      controller: currentPassController,
                      validator: (String? value) {
                        if (value!.isEmpty || value == "") {
                          return "${appLocale?.validator}";
                        } else {
                          return null;
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      hint: "${appLocale?.newPass}",
                      controller: newPassController,
                      validator: (String? value) {
                        if (value!.isEmpty || value == "") {
                          return "${appLocale?.validator}";
                        } else {
                          return null;
                        }
                      },
                    ),
                    const SizedBox(height: 60),
                    ThemeButton(
                      image: "assets/images/Vector (3).svg",
                      text: "${appLocale?.save}",
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          _changePassword(
                            currentPassController.text.trim(),
                            newPassController.text.trim(),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void _changePassword(String currentPassword, String newPassword) async {
    final user = auth.currentUser;
    final cred = EmailAuthProvider.credential(
        email: user!.email.toString(), password: currentPassword);
    user.reauthenticateWithCredential(cred).then((value) {
      user.updatePassword(newPassword).then((_) {
        FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .update({"password": newPassword}).then((_) {
          Navigator.of(context).pop();
          currentPassController.clear();
          newPassController.clear();
          customSnackBar(context,
              color: greenColor, message: "Successfully changed password");
        }).catchError((e) {
          customSnackBar(context,
              color: Colors.redAccent, message: e.toString());
        });
      });
    });
  }

  addValueToController() async {
    await FirebaseFirestore.instance
        .collection("users")
        .where("id", isEqualTo: auth.currentUser?.uid)
        .get()
        .then((value) {
      final data = value.docs[0];
      businessNameController.text = data["businessName"].toString();
      nameController.text = data["name"].toString();
      phoneNumberController.text = data["phoneNumber"].toString();
      addressController.text = data["address"].toString();
    });
  }

  Widget bodyContainer({String? image, String? text, void Function()? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 60,
        alignment: Alignment.center,
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: purpleColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              "$image",
              width: 25,
              height: 25,
              colorFilter: const ColorFilter.mode(purpleColor, BlendMode.srcIn),
            ),
            const SizedBox(width: 30),
            Text(
              "$text",
              style: customTextStyle(),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: purpleColor,
            ),
          ],
        ),
      ),
    );
  }

  void _openBottomSheet(BuildContext ctx) {
    showModalBottomSheet(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.97),
      isScrollControlled: true,
      useSafeArea: true,
      shape: const OutlineInputBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      context: ctx,
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.9,
            maxChildSize: 0.9,
            builder: (_, controller) {
              return GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Container(
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 30),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      shrinkWrap: true,
                      controller: controller,
                      children: [
                        CustomTextField(
                          hint: "${appLocale?.businessName}",
                          controller: businessNameController,
                          validator: (String? value) {
                            if (value!.isEmpty || value == "") {
                              return "${appLocale?.validator}";
                            } else {
                              return null;
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          hint: "${appLocale?.name}",
                          controller: nameController,
                          validator: (String? value) {
                            if (value!.isEmpty || value == "") {
                              return "${appLocale?.validator}";
                            } else {
                              return null;
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          hint: "${appLocale?.phoneNumber}",
                          controller: phoneNumberController,
                          keyBoardType: TextInputType.number,
                          validator: (String? value) {
                            if (value!.isEmpty || value == "") {
                              return "${appLocale?.validator}";
                            } else {
                              return null;
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          hint: "${appLocale?.address}",
                          controller: addressController,
                          validator: (String? value) {
                            if (value!.isEmpty || value == "") {
                              return "${appLocale?.validator}";
                            } else {
                              return null;
                            }
                          },
                        ),
                        const SizedBox(height: 80),
                        CustomButton(
                          text: "${appLocale?.save}",
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              LoginService.editUser(
                                id: auth.currentUser!.uid,
                                businessName: businessNameController.text,
                                name: nameController.text,
                                phoneNumber: phoneNumberController.text,
                                address: addressController.text,
                              );
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  logOutDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(
              "${appLocale?.areYouSure}",
              style: customTextStyle(
                  size: 20, fontWeight: FontWeight.bold, color: purpleColor),
            ),
            actions: [
              TextButton(
                child: Text(
                  "${appLocale?.yes}",
                  style: customTextStyle(fontWeight: FontWeight.w600),
                ),
                onPressed: () async {
                  await auth.signOut().then((value) {
                    navigatorRemove(context, LoginScreen());
                  });
                },
              ),
              TextButton(
                child: Text(
                  "${appLocale?.no}",
                  style: customTextStyle(fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  openDialog(BuildContext context, AppLanguage provider) {
    showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(
              "${appLocale?.chooseLanguage}",
              style: customTextStyle(
                  size: 20, fontWeight: FontWeight.bold, color: purpleColor),
            ),
            actions: [
              TextButton(
                child: Text(
                  "${appLocale?.english}",
                  style: customTextStyle(fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  provider.changeLanguage(Locale("en"));
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text(
                  "${appLocale?.gujarati}",
                  style: customTextStyle(fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  provider.changeLanguage(Locale("gu"));
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  @override
  void initState() {
    addValueToController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppLanguage>(builder: (context, provider, child) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("${appLocale?.setting}"),
          actions: [
            TextButton(
              onPressed: () {
                logOutDialog(context);
              },
              child: Text(
                "${appLocale?.logout}",
                style: customTextStyle(
                    color: whiteColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                bodyContainer(
                  image: "assets/images/noun-add-5852019 1.svg",
                  text: "${appLocale?.addAccountDetail}",
                  onTap: () => _openBottomSheet(context),
                ),
                bodyContainer(
                  image: "assets/images/noun-language-5388796 1.svg",
                  text: "${appLocale?.language}",
                  onTap: () => openDialog(context, provider),
                ),
                bodyContainer(
                  image: "assets/images/noun-rate-3323095 1.svg",
                  text: "${appLocale?.rateUs}",
                ),
                bodyContainer(
                  image: "assets/images/noun-privacy-6119927 1.svg",
                  text: "${appLocale?.privacyPolicy}",
                ),
                bodyContainer(
                  image: "assets/images/noun-note-5276192 1.svg",
                  text: "${appLocale?.termsAndCondition}",
                ),
                bodyContainer(
                  image:
                      "assets/images/c0e55c82-e042-40a9-8e53-e24a28d0ca68_pixelied-log-truck.svg",
                  text: "${appLocale?.changePass}",
                  onTap: () => changePassDialog(context),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
